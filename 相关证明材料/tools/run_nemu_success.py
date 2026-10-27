#!/usr/bin/env python3






from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_CASES = 939


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--nemu-root', type=Path, required=True)
    parser.add_argument('--library', type=Path, required=True)
    parser.add_argument('--out', type=Path, default=ROOT / 'results/current/nemu_success.json')
    parser.add_argument('--cc', default=os.environ.get('CC', 'gcc'))
    args = parser.parse_args()
    output = args.out.resolve()
    if ROOT not in output.parents:
        parser.error('--out must point inside the supplied program directory')
    nm = args.nemu_root.resolve()
    library = args.library.resolve()
    if not library.is_file():
        parser.error('NEMU library does not exist: ' + str(library))

    patch_path = ROOT / 'nemu/apply_nemu_patch.py'
    spec = importlib.util.spec_from_file_location('vdot_source_patch', patch_path)
    patch = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(patch)
    if patch.HELPER_NEW not in (nm / 'src/isa/riscv64/instr/rvv/vcompute.h').read_text():
        raise SystemExit('NEMU source does not contain the supplied vdot helper')
    if patch.VCOMMON_INSERT not in (nm / 'src/isa/riscv64/instr/rvv/vcommon.c').read_text():
        raise SystemExit('NEMU source lacks the supplied vector CSR export update')

    build = ROOT / 'build/instruction_cosim'
    build.mkdir(parents=True, exist_ok=True)
    output.parent.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    if os.name == 'nt':
        env['PATH'] += ';' + str(Path(args.cc).resolve().parent)
    msys = os.name == 'nt' and '/usr/bin/' in args.cc.replace('\\', '/')
    records = {}

    def host_arg(value):
        value = value.as_posix() if isinstance(value, Path) else str(value)
        if msys:
            value = re.sub(r'^(-I)?([A-Za-z]):/',
                           lambda match: (match[1] or '') + '/' + match[2].lower() + '/',
                           value)
        return value

    def execute(name, command):
        native_python = str(command[0]) == sys.executable
        command = [str(command[0])] + [
            (part.as_posix() if isinstance(part, Path) else str(part))
            if native_python else host_arg(part) for part in command[1:]]
        result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True,
                                text=True, errors='replace', timeout=120)
        path = output.parent / (name + '.txt')
        path.write_text(result.stdout + result.stderr, encoding='utf-8')
        records[name] = {'return_code': result.returncode,
                         'file': path.relative_to(ROOT).as_posix(),
                         'content_id': digest(path)}
        if result.returncode:
            raise SystemExit(name + ' did not complete; see ' + str(path))
        return result.stdout

    suffix = '.exe' if os.name == 'nt' else ''
    offsets = build / ('probe_offsets' + suffix)
    includes = ['include', 'lib-include', 'src/isa/riscv64/include',
                'src/engine/interpreter', 'resource/softfloat/repo/source/include',
                'resource/softfloat/repo/source/RISCV']
    command = [args.cc, '-O0', '-o', offsets, ROOT / 'nemu/cosim/probe_offsets.c']
    command += ['-I' + (nm / name).as_posix() for name in includes]
    command += ['-D__ISA__=riscv64', '-D__ISA_riscv64__=1', '-D_SHARE=1',
                '-include', nm / 'include/generated/autoconf.h']
    execute('layout_compile', command)
    raw_layout = execute('layout_read', [offsets])
    match = re.search(r'LAYOUT_BEGIN\s*\n(.*?)LAYOUT_END', raw_layout, re.S)
    if not match:
        raise SystemExit('NEMU headers did not provide a complete register layout')
    layout = dict(line.split() for line in match[1].strip().splitlines())
    required = {'OFF_GPR', 'OFF_PC', 'OFF_MODE', 'OFF_MSTATUS', 'OFF_VR',
                'VR_STRIDE', 'OFF_VSTART', 'OFF_VTYPE', 'OFF_VL', 'OFF_END', 'STATE_SIZE'}
    if not required <= layout.keys() or int(layout['VR_STRIDE']) != 16:
        raise SystemExit('NEMU must export all required states with VLEN=128')
    header = '#ifndef COSIM_LAYOUT_H\n#define COSIM_LAYOUT_H\n'
    header += ''.join('#define %s %d\n' % (key, int(value))
                      for key, value in layout.items())
    (build / 'cosim_layout.h').write_text(header + '#endif\n', encoding='ascii')

    cases = build / 'cases.txt'
    execute('case_conversion', [sys.executable,
                               ROOT / 'nemu/cosim/rtl_vectors_to_cosim.py', cases])
    count = sum(1 for line in cases.read_text().splitlines()
                if line.strip() and not line.lstrip().startswith('#'))
    if count != EXPECTED_CASES:
        raise SystemExit('Expected 939 supplied cases; found ' + str(count))

    comparison = build / ('cosim_baseline' + suffix)
    source = ROOT / 'nemu/cosim/cosim_baseline.c'




    comparison_source = build / 'cosim_success.c'
    source_text = source.read_text(encoding='utf-8')
    init_anchor = '  phase("difftest_init");\n'
    if source_text.count(init_anchor) != 1:
        raise SystemExit('Cannot locate the NEMU initialization call exactly once')
    memory_setup = (
        '  void (*set_ramsize)(size_t) = (void (*)(size_t))dlsym(h, "difftest_set_ramsize");\n'
        '  if (!set_ramsize) { printf("NEMU memory setup API is unavailable\\n"); return 2; }\n'
        '  set_ramsize((size_t)128 * 1024 * 1024);\n'
        '  printf("NEMU guest memory=128 MiB\\n");\n')
    comparison_source.write_text(source_text.replace(init_anchor, memory_setup + init_anchor),
                                 encoding='utf-8')
    command = [args.cc, '-O2', '-Wall', '-I' + build.as_posix(),
               '-o', comparison, comparison_source]
    if os.name != 'nt':
        command += ['-ldl']
    execute('comparison_compile', command)

    results = []
    pattern = (r'^cases=(\d+) mismatches=(\d+) variant=(\S+) n_inst=(\d+) '
               r'nonzero_upper_lanes=(\d+) low_mismatches=(\d+) '
               r'tail_mismatches=(\d+) compare_bits=(\d+)$')
    for variant, instructions in (('vwred', 4), ('vwred-g', 4), ('vdot', 1)):
        text = execute(variant, [comparison, library, cases, variant])
        match = re.search(pattern, text, re.M)
        if not match:
            raise SystemExit('Missing complete-register result for ' + variant)
        measured = (int(match[1]), int(match[2]), match[3], int(match[4]),
                    int(match[5]), int(match[6]), int(match[7]), int(match[8]))
        if measured != (EXPECTED_CASES, 0, variant, instructions, 0, 0, 0, 128):
            raise SystemExit('Complete-register comparison differs for ' + variant)
        size = re.search(r'library DIFFTEST_REG_SIZE=(\d+), header OFF_END=(\d+)', text)
        if not size or int(size[1]) != int(size[2]) or int(size[1]) != int(layout['OFF_END']):
            raise SystemExit('NEMU library and source headers expose different state sizes')
        results.append({'name': variant, 'cases': EXPECTED_CASES, 'mismatches': 0,
                        'compare_bits': 128, 'instructions': instructions, 'passed': True})
        print('%s PASS cases=939 mismatches=0 compare_bits=128 instructions=%d'
              % (variant, instructions), flush=True)

    report = {'passed': True, 'cases_per_comparison': EXPECTED_CASES,
              'compare_bits': 128, 'guest_memory_mib': 128, 'library': str(library),
              'library_content_id': digest(library), 'results': results,
              'source_content_ids': {str(path.relative_to(ROOT)).replace('\\', '/'): digest(path)
                                     for path in [patch_path, source, comparison_source, Path(__file__)]},
              'outputs': records}
    output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print('NEMU_SUCCESS_PASS', flush=True)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
