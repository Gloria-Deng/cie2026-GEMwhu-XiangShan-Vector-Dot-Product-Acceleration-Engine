#!/usr/bin/env python3

from __future__ import annotations
import argparse
import csv
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'tools'))
from runtime_common import new_output


def find_prefix(explicit):
    if explicit:
        return explicit
    assembler = shutil.which('riscv64-unknown-elf-as')
    if assembler:
        return str(Path(assembler).parent / 'riscv64-unknown-elf-')
    directories = []
    if os.environ.get('RISCV_XPACK'):
        directories.append(Path(os.environ['RISCV_XPACK']) / 'bin')
    if os.name == 'nt':
        directories.extend(Path(f'{drive}:/msys64/ucrt64/bin') for drive in 'CDEFGHIJKLMNOPQRSTUVWXYZ')
    for directory in directories:
        if (directory / 'riscv64-unknown-elf-as.exe').is_file():
            return str(directory / 'riscv64-unknown-elf-')
    return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, help='new external output directory; default: system temporary directory')
    parser.add_argument('--prefix', help='RISC-V tool prefix; auto-detect PATH, RISCV_XPACK, or MSYS2')
    parser.add_argument('--timeout', type=int, default=600, help='maximum seconds per check')
    args = parser.parse_args()
    if args.timeout <= 0:
        parser.error('--timeout must be positive')
    out = new_output(args.out) if args.out else Path(tempfile.mkdtemp(prefix='xiangshan_programs_'))
    prefix = find_prefix(args.prefix)
    checks = [
        ('environment', ['check_environment.py', '--out', str(out / 'environment')]),
        ('inputs', ['scripts/check_materials.py']),
        ('recorded_results', ['scripts/check_recorded_results.py']),
        ('reference_model', ['sim/golden_vdot.py']),
        ('basic_rtl', ['scripts/check_basic.py', '--out', str(out / 'basic_rtl')]),
        ('latency_replay', ['run_latency.py', 'replay', '--out', str(out / 'latency_replay')]),
        ('vadd_original_wave', ['reproduce_vadd.py', '--mode', 'fst', '--out', str(out / 'vadd_original_wave')]),
        ('vadd_invalid_inputs', ['reproduce_vadd.py', '--mode', 'invalid', '--out', str(out / 'vadd_invalid_inputs')]),
        ('full_suite_parser', ['scripts/run_full.py', '--selftest']),
        ('cluster_parser', ['cluster/run_suite.py', '--selftest']),
    ]
    if prefix:
        checks += [
            ('vadd_rebuild', ['build_vadd.py', '--prefix', prefix, '--out', str(out / 'vadd_rebuild')]),
            ('basic_program_build', ['scripts/prepare_tests.py', '--prefix', prefix, '--out', str(out / 'basic_program_build')]),
        ]
    env = os.environ.copy()
    env.update(PYTHONIOENCODING='utf-8', PYTHONDONTWRITEBYTECODE='1')
    records = []
    print('output:', out, flush=True)
    for name, command in checks:
        started = time.monotonic()
        path = out / (name + '.txt')
        try:
            result = subprocess.run([sys.executable, '-B', str(ROOT / command[0]), *command[1:]],
                                    cwd=out, env=env, capture_output=True, text=True,
                                    encoding='utf-8', errors='replace', timeout=args.timeout)
            text = result.stdout + result.stderr
            status = 'PASS' if result.returncode == 0 else 'FAIL'
            code = result.returncode
        except (OSError, subprocess.TimeoutExpired) as error:
            text, status, code = str(error), 'FAIL', -1
        path.write_text(text, encoding='utf-8')
        records.append([name, status, code, f'{time.monotonic() - started:.2f}', str(path)])
        print(name, status, flush=True)
        if status != 'PASS':
            print(text[-1600:], flush=True)
    if not prefix:
        records.append(['riscv_compiler', 'UNAVAILABLE', '', '', 'Install RISC-V GNU tools or pass --prefix.'])
        print('RISC-V compilation UNAVAILABLE: install tools or pass --prefix.', flush=True)
    with (out / 'checks.csv').open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.writer(stream)
        writer.writerow(['check', 'status', 'exit_code', 'seconds', 'details'])
        writer.writerows(records)
    failed = sum(row[1] == 'FAIL' for row in records)
    unavailable = sum(row[1] == 'UNAVAILABLE' for row in records)
    print(f'COMPLETE passed={len(records)-failed-unavailable} failed={failed} unavailable={unavailable}', flush=True)
    print('Recorded processor results were rechecked; a new full-processor simulation requires a built XiangShan emulator and NEMU library.', flush=True)
    return 1 if failed else (2 if unavailable else 0)


if __name__ == '__main__':
    raise SystemExit(main())
