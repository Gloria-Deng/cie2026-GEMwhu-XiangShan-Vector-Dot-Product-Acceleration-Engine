#!/usr/bin/env python3

from __future__ import annotations
import argparse
import hashlib
import json
import importlib.util
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--nemu-root', type=Path, required=True)
    ap.add_argument('--library', type=Path, required=True)
    ap.add_argument('--control-library', type=Path)
    ap.add_argument('--cc', default=os.environ.get('CC', 'gcc'))
    ap.add_argument('--out', type=Path, default=ROOT / 'results/current/instruction_cosim.json')
    args = ap.parse_args()
    nm = args.nemu_root.resolve()
    spec=importlib.util.spec_from_file_location('vdot_patch',ROOT/'nemu/apply_nemu_patch.py')
    patch=importlib.util.module_from_spec(spec); spec.loader.exec_module(patch)
    helper=(nm/'src/isa/riscv64/instr/rvv/vcompute.h').read_text()
    if patch.HELPER_NEW not in helper:
        raise SystemExit('NEMU source does not contain the current complete helper')
    if patch.VCOMMON_INSERT not in (nm/'src/isa/riscv64/instr/rvv/vcommon.c').read_text():
        raise SystemExit('NEMU source lacks the vector CSR export fix')
    build = ROOT / 'build/instruction_cosim'
    build.mkdir(parents=True, exist_ok=True)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    if os.name == 'nt':
        env['PATH'] += ';' + str(Path(args.cc).resolve().parent)
    logs = {}
    msys = os.name == 'nt' and '/usr/bin/' in args.cc.replace('\\', '/')

    def host_arg(v):
        value = v.as_posix() if isinstance(v, Path) else str(v)
        if msys:
            value = re.sub(r'^(-I)?([A-Za-z]):/', lambda m:(m[1] or '')+'/'+m[2].lower()+'/', value)
        return value

    def run(name, cmd, timeout=120):
        native_python = str(cmd[0]) == sys.executable
        cmd = [str(cmd[0])] + [(v.as_posix() if isinstance(v, Path) else str(v))
                              if native_python else host_arg(v) for v in cmd[1:]]
        r = subprocess.run(cmd, cwd=ROOT, env=env,
                           capture_output=True, text=True, errors='replace', timeout=timeout)
        path = args.out.parent / (name + '.log')
        path.write_text(r.stdout + r.stderr, encoding='utf-8')
        logs[name] = {'rc': r.returncode, 'path': str(path.relative_to(ROOT)), 'sha256': sha(path)}
        return r

    suffix = '.exe' if os.name == 'nt' else ''
    probe = build / ('probe_offsets' + suffix)
    includes = ['include', 'lib-include', 'src/isa/riscv64/include',
                'src/engine/interpreter', 'resource/softfloat/repo/source/include',
                'resource/softfloat/repo/source/RISCV']
    cmd = [args.cc, '-O0', '-o', probe, ROOT / 'nemu/cosim/probe_offsets.c']
    cmd += ['-I' + (nm / p).as_posix() for p in includes]
    cmd += ['-D__ISA__=riscv64', '-D__ISA_riscv64__=1', '-D_SHARE=1',
            '-include', nm / 'include/generated/autoconf.h']
    r = run('layout_compile', cmd)
    if r.returncode:
        raise SystemExit('layout probe failed; see ' + logs['layout_compile']['path'])
    r = run('layout_probe', [probe])
    m = re.search(r'LAYOUT_BEGIN\s*\n(.*?)LAYOUT_END', r.stdout, re.S)
    if r.returncode or not m:
        raise SystemExit('layout probe produced no valid layout')
    layout = dict(line.split() for line in m[1].strip().splitlines())
    required = {'OFF_GPR', 'OFF_PC', 'OFF_MODE', 'OFF_MSTATUS', 'OFF_VR', 'VR_STRIDE',
                'OFF_VSTART', 'OFF_VTYPE', 'OFF_VL', 'OFF_END', 'STATE_SIZE'}
    if not required <= layout.keys():
        raise SystemExit('layout fields missing: ' + str(required - layout.keys()))
    header = '#ifndef COSIM_LAYOUT_H\n#define COSIM_LAYOUT_H\n'
    header += ''.join('#define %s %d\n' % (k, int(v)) for k, v in layout.items()) + '#endif\n'
    (build / 'cosim_layout.h').write_text(header, encoding='ascii')
    bridge = ROOT / 'nemu/cosim/rtl_vectors_to_cosim.py'
    cases = build / 'cases.txt'
    r = run('case_bridge', [sys.executable, bridge, cases])
    if r.returncode:
        raise SystemExit('case bridge failed')
    expected_cases = sum(1 for line in cases.read_text().splitlines()
                         if line.strip() and not line.lstrip().startswith('#'))
    if not expected_cases:
        raise SystemExit('empty case corpus')
    exe = build / ('cosim_baseline' + suffix)
    source = ROOT / 'nemu/cosim/cosim_baseline.c'
    cmd = [args.cc, '-O2', '-Wall', '-I' + build.as_posix(), '-o', exe, source]
    if os.name != 'nt':
        cmd += ['-ldl']
    if run('baseline_compile', cmd).returncode:
        raise SystemExit('baseline harness compile failed')
    arms = {}
    libraries = [('patched', args.library.resolve())]
    if args.control_library:
        libraries.append(('control', args.control_library.resolve()))
    for label, library in libraries:
        if not library.is_file():
            raise SystemExit('missing library: ' + str(library))
        for variant in ('vwred', 'vwred-g', 'legacy-tail', 'vdot'):
            if label == 'control' and variant == 'vdot':
                continue
            name = label + '_' + variant
            r = run(name, [exe, library, cases, variant])
            m = re.search(r'^cases=(\d+) mismatches=(\d+) variant=(\S+) n_inst=(\d+) '
                          r'nonzero_upper_lanes=(\d+) low_mismatches=(\d+) '
                          r'tail_mismatches=(\d+) compare_bits=(\d+)$', r.stdout, re.M)
            if not m:
                raise SystemExit('missing full-register result: ' + name)
            row = dict(zip(('cases','mismatches','variant','instructions','upper_bytes',
                            'low_mismatches','tail_mismatches','compare_bits'), m.groups()))
            row = {k: v if k == 'variant' else int(v) for k, v in row.items()}
            if variant == 'legacy-tail':
                ok = (r.returncode != 0 and row['cases'] == expected_cases
                      and row['low_mismatches'] == 0 and row['tail_mismatches'] == expected_cases
                      and row['mismatches'] == expected_cases and row['compare_bits'] == 128)
            else:
                ok = (r.returncode == 0 and row['cases'] == expected_cases
                      and row['compare_bits'] == 128 and row['mismatches'] == 0
                      and row['upper_bytes'] == 0 and row['tail_mismatches'] == 0)
            row.update(rc=r.returncode, pass_check=ok, library_sha256=sha(library))
            arms[name] = row
            print(name, 'PASS' if ok else 'FAIL', row)
    data = {'schema': 1, 'compare_bits': 128, 'expected_cases': expected_cases,
            'inputs': {'nemu/cosim/cosim_baseline.c': sha(source),
                       'nemu/apply_nemu_patch.py': sha(ROOT/'nemu/apply_nemu_patch.py'),
                       'tools/run_instruction_cosim.py': sha(Path(__file__)),
                       'nemu/cosim/rtl_vectors_to_cosim.py': sha(bridge),
                       **{str(p.relative_to(ROOT)): sha(p) for p in sorted((ROOT/'tests').glob('cases_*.txt'))}},
            'arms': arms, 'logs': logs, 'all_ok': all(r['pass_check'] for r in arms.values()),
            'control_available': bool(args.control_library),
            'nemu_header_sha256':sha(nm/'include/generated/autoconf.h'),
            'nemu_helper_source_sha256':sha(nm/'src/isa/riscv64/instr/rvv/vcompute.h')}
    args.out.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    return 0 if data['all_ok'] else 1


if __name__ == '__main__':
    raise SystemExit(main())
