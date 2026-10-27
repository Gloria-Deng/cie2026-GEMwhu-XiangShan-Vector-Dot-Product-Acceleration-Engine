#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
ANSI = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")


def tool(prefix, name):
    value = prefix + name
    found = shutil.which(value)
    if found:
        return found
    for candidate in (Path(value), Path(value + '.exe')):
        if candidate.is_file():
            return str(candidate.resolve())
    raise ValueError('missing tool: ' + value)


def build_example(directory, prefix):
    directory.mkdir(parents=True, exist_ok=True)
    source = ROOT / 'examples/minimal_vdot.S'
    obj = directory / 'minimal_vdot.o'
    elf = directory / 'minimal_vdot.elf'
    binary = directory / 'minimal_vdot.bin'
    commands = [
        [tool(prefix, 'as'), '-march=rv64gcv', '-mabi=lp64d', '-o', str(obj), str(source)],
        [tool(prefix, 'ld'), '-m', 'elf64lriscv', '-Ttext=0x80000000',
         '-Tdata=0x80100000', '--no-relax', '-e', '_start', '-o', str(elf), str(obj)],
        [tool(prefix, 'objcopy'), '-O', 'binary', str(elf), str(binary)],
    ]
    for command in commands:
        subprocess.run(command, check=True)
    listing = subprocess.check_output([tool(prefix, 'nm'), '-n', str(elf)], text=True)
    symbols = {parts[2]: int(parts[0], 16) for line in listing.splitlines()
               if len(parts := line.split()) == 3}
    disassembly = subprocess.check_output([tool(prefix, 'objdump'), '-d', str(elf)], text=True)
    (directory / 'minimal_vdot.dis').write_text(disassembly, encoding='utf-8')
    return binary, symbols


def choose_program(run, name, prefix):
    if name == 'minimal_vdot':
        return build_example(run / 'programs', prefix)
    for directory in (run / 'programs', ROOT / 'programs'):
        manifest = directory / 'manifest.json'
        if manifest.is_file():
            rows = json.loads(manifest.read_text(encoding='utf-8'))['programs']
            for row in rows:
                if row['name'] == name:
                    if row['kind'] == 'benchmark':
                        raise ValueError('use cluster/run_suite.py for timing programs')
                    return directory / row['image'], row['symbols']
    raise ValueError('program is not present: ' + name)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--run-root', type=Path, required=True)
    ap.add_argument('--program', default='minimal_vdot')
    ap.add_argument('--prefix', default='riscv64-unknown-elf-')
    ap.add_argument('--backend', choices=('emu', 'nemu'), default='emu')
    ap.add_argument('--library', type=Path)
    ap.add_argument('--nemu-runner', type=Path)
    ap.add_argument('--cycles', type=int, default=300000)
    args = ap.parse_args()
    run = args.run_root.resolve()
    binary, symbols = choose_program(run, args.program, args.prefix)
    if not binary.is_file():
        raise ValueError('missing program: ' + str(binary))
    library = args.library or run / 'NEMU/build/riscv64-nemu-interpreter-so'
    if not library.is_file():
        raise ValueError('missing NEMU reference library: ' + str(library))
    output = run / 'single_program_results'
    output.mkdir(parents=True, exist_ok=True)
    if args.backend == 'emu':
        emulator = run / 'XiangShan/build/emu'
        if not emulator.is_file():
            raise ValueError('missing XiangShan emulator: ' + str(emulator))
        command = [str(emulator), '-i', str(binary), '--diff=' + str(library),
                   '--ram-size=256MB', '--no-squash', '-s', '1', '-C', str(args.cycles)]
    else:
        suffix = '.exe' if os.name == 'nt' else ''
        candidates = [ROOT / ('build/instruction_cosim/' + name + suffix)
                      for name in ('run_image_success', 'run_image')]
        runner = args.nemu_runner or next((p for p in candidates if p.is_file()), candidates[0])
        if not runner.is_file():
            raise ValueError('build the NEMU comparison tools first; missing: ' + str(runner))
        command = [str(runner), str(library.resolve()), str(binary.resolve()),
                   hex(symbols['OK']), hex(symbols['BAD']), '0']
    result = subprocess.run(command, cwd=run, capture_output=True, text=True,
                            errors='replace', timeout=7200)
    text = ANSI.sub('', result.stdout + result.stderr)
    result_path = output / (args.program + '_' + args.backend + '.txt')
    result_path.write_text(text, encoding='utf-8')
    if args.backend == 'emu':
        addresses = re.findall(r'Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = (0x[0-9a-fA-F]+)', text)
        bad = re.search(r'\bABORT\b|\bFAIL(?:ED)?\b|Assertion .*failed|different at pc|AddressSanitizer|Segmentation fault', text, re.I)
        passed = (result.returncode == 0 and not bad and len(addresses) == 1
                  and int(addresses[0], 16) == symbols['OK'])
    else:
        passed = result.returncode == 0 and 'IMAGE PASS' in text
    print('program=' + args.program + ' backend=' + args.backend)
    print('expected_OK=' + hex(symbols['OK']) + ' BAD=' + hex(symbols['BAD']))
    print('output=' + str(result_path))
    print(('SINGLE_PROGRAM_PASS' if passed else 'SINGLE_PROGRAM_FAIL'))
    return 0 if passed else 1


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(str(error), file=sys.stderr)
        raise SystemExit(1)
