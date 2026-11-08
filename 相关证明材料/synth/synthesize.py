#!/usr/bin/env python3
"""Synthesize the supplied circuits with one shared flow; never infer missing results."""
from __future__ import annotations

import argparse
import csv
from datetime import datetime
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
TARGETS = {
    'tree0': ('VDotUnit', [ROOT / 'gen/chisel/VDotUnit_t0_n8_o32_a19.sv']),
    'tree1': ('VDotUnit', [ROOT / 'gen/chisel/VDotUnit_t1_n8_o32_a19.sv']),
    'soc_datapath': ('VDotUnit', [ROOT / 'rtl/xs_soc_generated/VDotUnit.sv']),
    'VDotU': ('VDotU', [ROOT / 'rtl/xs_wrapper_generated/VDotU.sv']),
    'VIMacU': ('VIMacU', sorted((ROOT / 'rtl/xs_soc_generated_vimac').glob('*.sv'))),
    'VIAluFix': ('VIAluFix', sorted((ROOT / 'rtl/xs_soc_generated_vadd').glob('*.sv'))),
}


def quoted(path):
    text = str(path.resolve())
    if any(c in text for c in '\n\r";'):
        raise ValueError('unsupported tool path: ' + text)
    return '"' + text + '"'


def execute(command, output, timeout, cwd=None):
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            text=True, encoding='utf-8', errors='replace', timeout=timeout, cwd=cwd)
    output.write_text(result.stdout, encoding='utf-8')
    if result.returncode:
        raise RuntimeError(f'{command[0]} failed ({result.returncode}): {output}')
    return result.stdout


def register_bits(path, top):
    module = json.loads(path.read_text())['modules'][top]
    return sum(int(c['parameters']['WIDTH'], 2) for c in module['cells'].values()
               if re.fullmatch(r'\$(?:a|s)?dff(?:e|ce)?|\$dlatch', c['type']))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, default=ROOT / 'synth' / ('results_' + datetime.now().strftime('%Y%m%d_%H%M%S')))
    parser.add_argument('--liberty', type=Path, help='optional local standard-cell library')
    parser.add_argument('--clock-ns', type=float, default=10.0)
    parser.add_argument('--target', nargs='+', choices=TARGETS, default=list(TARGETS))
    parser.add_argument('--timeout', type=int, default=600)
    parser.add_argument('--sv2v', help='sv2v executable for generated packed-array SystemVerilog')
    args = parser.parse_args()
    if args.clock_ns <= 0 or args.timeout <= 0:
        parser.error('clock and timeout must be positive')
    if not shutil.which('yosys'):
        parser.error('yosys is missing; Ubuntu: sudo apt-get update && sudo apt-get install yosys opensta')
    if args.liberty and not args.liberty.is_file():
        parser.error('liberty file does not exist')
    out = args.out.resolve()
    if out.exists() and any(out.iterdir()):
        parser.error('--out must be new or empty')
    out.mkdir(parents=True, exist_ok=True)
    execute(['yosys', '-V'], out / 'tool_version.txt', 30)
    sv2v = args.sv2v or shutil.which('sv2v')
    if sv2v:
        execute([sv2v, '--version'], out / 'sv2v_version.txt', 30)
    if shutil.which('sta'):
        execute(['sta', '-version'], out / 'sta_version.txt', 30)
    rows, sources = [], []
    for name in args.target:
        top, files = TARGETS[name]
        target = out / name
        target.mkdir()
        for path in files:
            if not path.is_file():
                raise FileNotFoundError(path)
            sources.append([name, path.relative_to(ROOT).as_posix()])
        read_files = files
        if sv2v:
            execute([sv2v, '-DSYNTHESIS', *map(str, files)], target / 'converted.v', args.timeout)
            read_files = [target / 'converted.v']
        commands = ['read_verilog -sv -DSYNTHESIS ' + ' '.join(quoted(p) for p in read_files),
                    f'hierarchy -check -top {top}', 'proc', 'flatten', 'opt',
                    'write_json ' + quoted(target / 'rtl.json'), f'synth -top {top} -noabc',
                    'ltp -noff']
        if args.liberty:
            commands.extend(['read_liberty -lib ' + quoted(args.liberty),
                             'dfflibmap -liberty ' + quoted(args.liberty),
                             'abc -liberty ' + quoted(args.liberty) + f' -D {args.clock_ns * 1000:g}'])
        else:
            commands.append('abc')
        commands.extend(['clean', 'check -assert',
                         'tee -o stat.json stat -json' +
                         (' -liberty ' + quoted(args.liberty) if args.liberty else ''),
                         'write_json ' + quoted(target / 'mapped.json'),
                         'write_verilog -noattr -noexpr -norename ' + quoted(target / 'mapped.v')])
        ys = target / 'synth.ys'
        ys.write_text('\n'.join(commands) + '\n', encoding='utf-8')
        output = execute(['yosys', '-T', '-s', str(ys)], target / 'synthesis.txt', args.timeout, cwd=target)
        data = json.loads((target / 'stat.json').read_text())['modules']['\\' + top]
        lengths = re.findall(r'longest topological path.*?length=(\d+)', output, re.I)
        row = dict(module=name, cells=data['num_cells'], register_bits=register_bits(target / 'rtl.json', top),
                   area_um2=data.get('area', '') if args.liberty else '',
                   combinational_levels=max(map(int, lengths), default=0),
                   clock_ns=args.clock_ns if args.liberty else '', timing_status='NOT_MEASURED',
                   liberty=str(args.liberty.resolve()) if args.liberty else '')
        if args.liberty and shutil.which('sta'):
            from analyze_timing import analyze
            row.update(analyze(target, top, args.liberty, args.clock_ns, args.timeout))
        rows.append(row)
        print('SYNTH_TARGET_PASS', name, 'cells=' + str(row['cells']), flush=True)
    columns = ['module', 'cells', 'register_bits', 'area_um2', 'combinational_levels',
               'max_reported_arrival_ns', 'clock_ns', 'timing_status', 'liberty',
               'multiply_arrival_ns', 'reduce_arrival_ns']
    with (out / 'summary.csv').open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.DictWriter(stream, columns)
        writer.writeheader()
        writer.writerows(rows)
    with (out / 'inputs.csv').open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.writer(stream)
        writer.writerow(['target', 'source'])
        writer.writerows(sources)
    print(f'SYNTH_PASS targets={len(rows)} output={out}')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
        print('SYNTH_FAIL:', error, file=sys.stderr)
        sys.exit(1)
