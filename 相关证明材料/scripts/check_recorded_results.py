#!/usr/bin/env python3

from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'tools'))
from runtime_common import recorded_file, matches_historical_source, historical_source_changes
ANSI = re.compile(r'\x1b\[[0-?]*[ -/]*[@-~]')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    value = hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(block)
    return value.hexdigest()


def read_data(path):
    return json.loads(path.read_text(encoding='utf-8'))


def check_vectors():
    counts = {}
    for group, expected_count in (('pos', 46), ('neg', 48), ('bound', 45), ('rand', 800)):
        count = 0
        for line in (ROOT / 'tests' / ('cases_' + group + '.txt')).read_text(encoding='utf-8').splitlines():
            items = line.split()
            if len(items) != 4:
                continue
            _, first, second, expected = items
            a = int(first, 16).to_bytes(16, 'little')
            b = int(second, 16).to_bytes(16, 'little')
            signed = lambda value: value if value < 128 else value - 256
            result = sum(signed(a[i]) * signed(b[i]) for i in range(8)) & 0xffffffff
            require(int(expected, 16) == result, 'Incorrect mathematical result in ' + group)
            count += 1
        require(count == expected_count, 'Unexpected input count in ' + group)
        counts[group] = count
    require(sum(counts.values()) == 939, 'Expected 939 input cases')
    text = (ROOT / 'results/recorded_nemu/patched_vdot.log').read_text(encoding='utf-8')
    pattern = (r'^cases=939 mismatches=0 variant=vdot n_inst=1 '
               r'nonzero_upper_lanes=0 low_mismatches=0 tail_mismatches=0 compare_bits=128$')
    require(re.search(pattern, text, re.M), 'The original NEMU comparison did not pass')
    require('BASELINE vdot PASS' in text, 'Missing original NEMU success conclusion')
    print('RECORDED_NEMU_PASS cases=939 compare_bits=128 mismatches=0')


def check_soc():
    directory = ROOT / 'results/cluster/20261019'
    summary = read_data(directory / 'summary.json')
    programs = read_data(directory / 'program_manifest.json')
    require(summary.get('all_ok') is True, 'The original full-SoC summary did not pass')
    require(digest(directory / 'build_manifest.json') == summary['build_manifest_sha256'],
            'The original build record has changed')
    require(len(summary['inputs']) == 19, 'Expected 19 original input files')
    for relative, expected in summary['inputs'].items():
        require(matches_historical_source(ROOT / relative.replace('\\', '/'), expected),
                'The supplied source differs from the completed verification: ' + relative)
    rows = {row['name']: row for row in programs['programs']}
    require(len(rows) == 32, 'Expected 32 original programs')
    for row in rows.values():
        require(digest(ROOT / 'programs' / row['image']) == row['image_sha256'],
                'A supplied program differs from the tested program: ' + row['name'])
    runs = summary['runs']
    require(len(runs) == 64, 'Expected 64 completed full-SoC executions')
    expected_repeats = Counter({name: 3 if row['kind'] == 'benchmark' else 1 for name, row in rows.items()})
    require(Counter(run['name'] for run in runs) == expected_repeats, 'Execution coverage differs from the program list')
    require(len({(run['name'], run['repeat']) for run in runs}) == 64, 'Duplicate completed execution')
    for run in runs:
        require(run['ok'] is True, 'An execution is not successful: ' + run['name'])
        path = recorded_file(directory / run['log'], run['log_sha256'])
        require(digest(path) == run['log_sha256'], 'An original execution output has changed: ' + run['name'])
        text = ANSI.sub('', path.read_text(encoding='utf-8', errors='replace'))
        require(not re.search(r'\bABORT\b|\bFAIL(?:ED)?\b|Assertion .*failed|different at pc|AddressSanitizer|Segmentation fault', text, re.I),
                'An execution output contains an error: ' + run['name'])
        addresses = re.findall(r'Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = (0x[0-9a-fA-F]+)', text)
        require(len(addresses) == 1, 'Missing unique terminal address: ' + run['name'])
        address = int(addresses[0], 16)
        require(address == int(run['pc'], 16), 'Terminal address differs from the original result: ' + run['name'])
        row = rows[run['name']]
        if row['kind'] == 'benchmark':
            offset = address - row['symbols']['LANDING']
            require(0 <= offset < row['landing_bytes'] and offset % 4 == 0,
                    'Timing program reached an invalid address: ' + run['name'])
            require(offset // 4 * row['cycle_grid'] == run['cycles_lower'],
                    'Timing result differs from the terminal address: ' + run['name'])
        else:
            require(address == row['symbols']['OK'], 'Functional program did not reach success: ' + run['name'])
        require(any(value.startswith('--diff=') for value in run['command']),
                'The original execution does not name a reference model: ' + run['name'])
    wave = summary['wave']
    require(digest(recorded_file(directory / wave['log'], wave['log_sha256'])) == wave['log_sha256'], 'The original vadd output has changed')
    require(digest(recorded_file(directory / wave['file'], wave['sha256'])) == wave['sha256'], 'The original vadd waveform has changed')
    print('RECORDED_FULL_SOC_PASS programs=32 executions=64 source_files=19')


def check_nemu_programs():
    directory = ROOT / 'results/recorded_nemu'
    data = read_data(directory / 'programs_nemu.json')
    require(data.get('all_ok') is True and len(data['programs']) == 32, 'Expected 32 successful NEMU programs')
    for program in data['programs']:
        path = directory / Path(program['log'].replace('\\', '/')).name
        require(program['ok'] is True and program['rc'] == 0, 'An original NEMU program did not pass')
        require(digest(path) == program['log_sha256'], 'An original NEMU output has changed: ' + program['name'])
        require('IMAGE PASS' in path.read_text(encoding='utf-8'), 'Missing original NEMU success conclusion')
    print('RECORDED_NEMU_PROGRAMS_PASS programs=32')


def check_wrapper():
    data = read_data(ROOT / 'results/recorded_nemu/fixed_wrapper.json')
    require(data.get('all_ok') is True and len(data['scenarios']) == 96,
            'Expected 96 successful functional-unit checks')
    require(all(row['ok'] is True for row in data['scenarios'].values()),
            'A functional-unit check did not pass')
    for relative, expected in data['inputs'].items():
        require(matches_historical_source(ROOT / relative.replace('\\', '/'), expected),
                'A functional-unit input differs from the completed verification: ' + relative)
    print('RECORDED_WRAPPER_PASS scenarios=96')


def main():
    check_vectors()
    check_nemu_programs()
    check_wrapper()
    check_soc()
    print('RECORDED_RESULTS_PASS')
    print('This command checks supplied completed results. It does not execute a new RTL simulation.')
    print('CURRENT_CODE_VERIFIED=false historical_source_changes=' + str(len(historical_source_changes())))


if __name__ == '__main__':
    try:
        main()
    except (ValueError, KeyError, OSError) as error:
        print('RECORDED_RESULTS_FAIL: ' + str(error), file=sys.stderr)
        raise SystemExit(1)
