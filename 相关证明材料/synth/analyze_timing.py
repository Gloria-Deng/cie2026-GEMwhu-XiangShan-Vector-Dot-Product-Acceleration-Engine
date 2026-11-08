#!/usr/bin/env python3
"""Time a completed mapped design, or add timing to a completed result directory."""
from __future__ import annotations
import argparse
import csv
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys


def analyze(target, top, liberty, clock_ns=10.0, timeout=600):
    design = json.loads((target / 'mapped.json').read_text())
    module = design['modules'][top]
    # Yosys 0.33 emits invalid Unicode escapes in source-location attributes
    # for Chinese paths. Attributes do not affect connectivity or timing.
    def discard_attributes(value):
        if isinstance(value, dict):
            value.pop('attributes', None)
            for child in value.values():
                discard_attributes(child)
        elif isinstance(value, list):
            for child in value:
                discard_attributes(child)
    discard_attributes(design)
    timing_input = target / 'timing_input.json'
    timing_input.write_text(json.dumps(design), encoding='utf-8')
    named_netlist = target / 'timing_mapped.v'
    command = ('read_json "' + str(timing_input) +
               '"; write_verilog -noattr -noexpr -norename "' + str(named_netlist) + '"')
    conversion = subprocess.run(['yosys', '-Q', '-T', '-p', command],
                                capture_output=True, text=True, timeout=timeout)
    (target / 'timing_netlist.txt').write_text(conversion.stdout + conversion.stderr, encoding='utf-8')
    if conversion.returncode:
        raise RuntimeError('cannot prepare timing netlist: ' + str(target))
    stages = {}
    for label, pattern in [('multiply', r'(?:.*\.)?prod_\d+'),
                           ('reduce', r'(?:.*\.)?red')]:
        bits = {b for n, net in module['netnames'].items()
                if re.fullmatch(pattern, n) for b in net['bits'] if isinstance(b, int)}
        pins = [name + '/D' for name, cell in module['cells'].items()
                if cell['type'].startswith('DFF') and
                bits.intersection(cell['connections'].get('Q', []))]
        if pins:
            stages[label] = pins
    script = [
        'read_liberty {' + str(liberty.resolve()) + '}',
        'read_verilog {' + str(named_netlist) + '}', 'link_design ' + top,
        f'create_clock -name core_clock -period {clock_ns:g} [get_ports clock]',
        'set data_inputs {}',
        'foreach port [all_inputs] { if {[get_full_name $port] ne "clock"} { lappend data_inputs $port } }',
        'set_input_delay 0 -clock core_clock $data_inputs',
        'set_output_delay 0 -clock core_clock [all_outputs]',
        'puts {TIMING_SECTION overall}',
        'report_checks -path_delay max -group_path_count 5 -format full_clock_expanded -digits 4',
        'report_wns', 'report_tns']
    for label, pins in stages.items():
        script += ['puts {TIMING_SECTION ' + label + '}',
                   'report_checks -path_delay max -group_path_count 1 -format full_clock_expanded -digits 4 -to [get_pins {' + ' '.join(pins) + '}]']
    script += ['exit']
    path = target / 'timing.tcl'
    path.write_text('\n'.join(script) + '\n', encoding='utf-8')
    result = subprocess.run(['sta', '-exit', str(path)], capture_output=True,
                            text=True, timeout=timeout)
    output = result.stdout + result.stderr
    (target / 'timing.txt').write_text(output, encoding='utf-8')
    if result.returncode or re.search(r'\bError:|not found|No paths found', output, re.I):
        raise RuntimeError('timing analysis failed: ' + str(target / 'timing.txt'))
    values = {}
    for section in re.split(r'TIMING_SECTION ', output)[1:]:
        label = section.splitlines()[0].strip()
        arrivals = re.findall(r'([-+]?\d+\.\d+)\s+data arrival time', section)
        if not arrivals:
            raise RuntimeError('no timed paths in ' + label)
        values[('max_reported_arrival_ns' if label == 'overall' else label + '_arrival_ns')] = max(map(float, arrivals))
    values['timing_status'] = 'ESTIMATED'
    return values


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--results', required=True, type=Path)
    parser.add_argument('--liberty', required=True, type=Path)
    parser.add_argument('--timeout', type=int, default=600)
    args = parser.parse_args()
    if not shutil.which('sta'):
        parser.error('sta executable is missing')
    out = args.results.resolve()
    with (out / 'summary.csv').open(encoding='utf-8-sig', newline='') as stream:
        reader = csv.DictReader(stream)
        columns = list(reader.fieldnames)
        rows = list(reader)
    for column in ['multiply_arrival_ns', 'reduce_arrival_ns']:
        if column not in columns:
            columns.append(column)
    for row in rows:
        target = out / row['module']
        top = row['module'] if row['module'] in ['VDotU', 'VIMacU', 'VIAluFix'] else 'VDotUnit'
        row.update(analyze(target, top, args.liberty, float(row['clock_ns']), args.timeout))
        print('TIMING_TARGET_PASS', row['module'], row['max_reported_arrival_ns'], flush=True)
    with (out / 'summary.csv').open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.DictWriter(stream, columns)
        writer.writeheader()
        writer.writerows(rows)
    result = subprocess.run(['sta', '-version'], capture_output=True, text=True, timeout=30)
    (out / 'sta_version.txt').write_text(result.stdout + result.stderr, encoding='utf-8')
    print('TIMING_PASS targets=' + str(len(rows)))


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
        print('TIMING_FAIL:', error, file=sys.stderr)
        sys.exit(1)
