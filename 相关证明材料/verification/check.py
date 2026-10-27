from pathlib import Path
import argparse
import csv
import hashlib
import os
import re
import shutil
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0, str(HERE))
from check_instructions import inspect_elf, inspect_listing


def signed(byte):
    return byte if byte < 128 else byte - 256


def result_bits(a, b):
    return sum(signed(x) * signed(y) for x, y in zip(a[:8], b[:8])) & 0xffffffff


def make_cases():
    cases = []

    def add(category, name, a, b):
        av = bytes(x & 255 for x in a)
        bv = bytes(x & 255 for x in b)
        if len(av) != 16 or len(bv) != 16:
            raise ValueError('每个输入必须恰好为16字节。')
        cases.append(dict(index=len(cases), category=category, name=name,
                          a=av, b=bv, expected=result_bits(av, bv)))

    poison_a = [0x80, 0x7f, 0xff, 0x02, 0x81, 0x40, 0x55, 0xaa]
    poison_b = [0x7f, 0x80, 0x01, 0xff, 0x40, 0x81, 0xaa, 0x55]
    for lane in range(8):
        for name, av, bv in [('positive', 5, 7), ('negative', -128, 127),
                             ('maximum_product', -128, -128)]:
            a = [0] * 8 + poison_a
            b = [0] * 8 + poison_b
            a[lane], b[lane] = av, bv
            add('single_position', f'position_{lane}_{name}', a, b)
    for lane in range(8):
        a = [0] * 8 + poison_a
        a[lane] = lane + 1
        add('one_input_routing', f'position_{lane}_asymmetric',
            a, list(range(11, 19)) + poison_b)
    for lane in range(8, 16):
        a, b = [0] * 16, [0] * 16
        a[lane], b[lane] = -128, -128
        add('unused_upper_position', f'position_{lane}_ignored', a, b)
    add('positive', 'increasing_times_decreasing', list(range(1, 9)) + poison_a,
        list(range(8, 0, -1)) + poison_b)
    add('maximum_sum', 'eight_minimum_times_minimum', [-128] * 8 + poison_a,
        [-128] * 8 + poison_b)
    add('minimum_sum', 'eight_minimum_times_maximum', [-128] * 8 + poison_a,
        [127] * 8 + poison_b)
    add('zero', 'zero_times_maximum', [0] * 8 + poison_a,
        [127] * 8 + poison_b)
    add('mixed_sign', 'asymmetric_signed', [1, -2, 3, -4, 5, -6, 7, -8] + poison_a,
        [11, -12, 13, 14, -15, 16, 17, -18] + poison_b)
    add('unused_upper_position', 'all_upper_positions_ignored', [0] * 8 + poison_a,
        [0] * 8 + poison_b)
    add('signed_extension', 'negative_four', [-128, 127] * 4 + poison_a,
        [1] * 8 + poison_b)
    add('asymmetric_routing', 'distinct_both_inputs', [3, 17, -2, 41, -128, 9, 127, -31] + poison_a,
        [-5, 4, 12, -9, 23, -71, 8, 6] + poison_b)
    return cases


def write_csv(path, columns, rows):
    with path.open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=columns)
        writer.writeheader()
        writer.writerows(rows)


def find_tool(name, explicit=None):
    candidates = [explicit] if explicit else [name]
    if not explicit and os.name == 'nt':
        for drive in ('C:', 'D:', 'E:'):
            candidates.extend([drive + '/msys64/ucrt64/bin/' + name + '.exe',
                               drive + '/iverilog/bin/' + name + '.exe'])
    for candidate in candidates:
        found = shutil.which(str(candidate))
        if found:
            return found
    raise ValueError('缺少本地工具：' + name)


def execute(command, out, name, data=None):
    environment = os.environ.copy()
    environment['PATH'] = str(Path(command[0]).resolve().parent) + os.pathsep + environment.get('PATH', '')
    process = subprocess.run(command, cwd=out, input=data,
                             capture_output=True, text=True,
                             encoding='utf-8', errors='replace',
                             env=environment, timeout=120)
    text = process.stdout + process.stderr
    (out / (name + '.txt')).write_text(text, encoding='utf-8')
    if process.returncode:
        raise ValueError('本地执行失败：' + name + '\n' + text[-1500:])
    return text


def run_rtl(out, case_path, tools, name, source, defines=()):
    target = out / 'build' / (name + '.vvp')
    relative_source = 'build/' + source.name
    if source.resolve() != (out / relative_source).resolve():
        shutil.copyfile(source, out / relative_source)
    command = [tools['iverilog'], '-g2012', '-s', 'check_datapath',
               '-o', 'build/' + target.name, '-DCASE_FILE="cases.txt"']
    command += ['-D' + item for item in defines]
    command += [relative_source, 'build/check_datapath.sv']
    execute(command, out, name + '_compile')
    text = execute([tools['vvp'], 'build/' + target.name], out, name)
    matches = list(re.finditer(r'DATAPATH cases=(\d+) passed=(\d+) failed=(\d+)', text))
    if len(matches) != 1:
        raise ValueError('缺少唯一的电路检查结果：' + name)
    total, passed, failed = map(int, matches[0].groups())
    if total != 48 or passed + failed != total:
        raise ValueError('电路检查的输入数量不符：' + name)
    first = re.search(r'DIFFERENT case=(\d+)', text)
    return dict(name=name, cases=total, passed=passed, failed=failed,
                first_difference=first[1] if first else '')


def parser_checks():
    start = 'Disassembly of section .text:\n'
    positive = start + ('  10: b29420d7 .4byte 0xb29420d7\n'
                        '  14: cc847fd7 vsetivli t6,8,e8,m1,ta,ma\n'
                        '  18: 42802557 vmv.x.s a0,v8\n')
    completed = 0
    good = inspect_listing(positive, expected_vdot=1, require_extract=True)
    if good['counts']['vdot'] != 1 or good['vdot_destinations'] != [1]:
        raise ValueError('点积编码读取错误。')
    completed += 1
    relocated = positive.replace('  10:', '  801080:').replace('  14:', '  801084:').replace('  18:', '  801088:')
    if inspect_listing(relocated)['counts'] != good['counts']:
        raise ValueError('结果依赖固定程序地址。')
    completed += 1
    compressed = positive + '  1c: 8082 ret\n'
    if len(inspect_listing(compressed)['instructions']) != 4:
        raise ValueError('没有正确读取压缩指令。')
    completed += 1
    separate_sections = positive + 'Disassembly of section .init:\n  10: 8082 ret\n'
    if len(inspect_listing(separate_sections)['instructions']) != 4:
        raise ValueError('不同可执行节中的相同地址被混淆。')
    completed += 1
    for bad, requirements in [
            (start + '  10: 00008067 ret\n', {}),
            (positive.replace('b29420d7', 'b09420d7'), {}),
            (positive.replace('b29420d7', 'b29400d7'), {}),
            (positive.replace('cc847fd7', '00000013'), {}),
            (positive.replace('42802557', '00000013'), {'require_extract': True}),
            (positive.replace('42802557', '40802557'), {'require_extract': True}),
            (positive, {'expected_vdot': 2}),
            ('.data\n  10: b29420d7 .4byte\n', {}),
            (positive + '  10: 00000013 nop\n', {}),
    ]:
        try:
            inspect_listing(bad, **requirements)
        except ValueError:
            completed += 1
        else:
            raise ValueError('无效机器指令检查被错误接受。')
    return completed


def main():
    parser = argparse.ArgumentParser(description='逐位置检查点积电路，并验证检查能发现已知错误。')
    parser.add_argument('--out', type=Path)
    parser.add_argument('--gcc')
    parser.add_argument('--iverilog')
    parser.add_argument('--vvp')
    parser.add_argument('--objdump')
    args = parser.parse_args()
    out = args.out.resolve() if args.out else Path(tempfile.mkdtemp(prefix='vdot_positions_'))
    if ROOT == out or ROOT in out.parents:
        parser.error('结果目录必须位于配套工程以外。')
    if out.exists() and any(out.iterdir()):
        parser.error('结果目录必须尚未存在或为空。')
    out.mkdir(parents=True, exist_ok=True)
    (out / 'build').mkdir()
    print('output:', out, flush=True)
    try:
        tools = {name: find_tool(name, getattr(args, name)) for name in ('gcc', 'iverilog', 'vvp')}
        tool_rows = []
        for name, path in tools.items():
            version = subprocess.run([path, '--version' if name == 'gcc' else '-V'],
                                     capture_output=True, text=True,
                                     encoding='utf-8', errors='replace', timeout=20)
            lines = (version.stdout + version.stderr).splitlines()
            tool_rows.append(dict(tool=name, location=path, version=lines[0] if lines else ''))
        write_csv(out / 'tools.csv', ['tool', 'location', 'version'], tool_rows)
        cases = make_cases()
        rows = []
        for case in cases:
            rows.append(dict(index=case['index'], category=case['category'], name=case['name'],
                             vs1=case['a'][::-1].hex(), vs2=case['b'][::-1].hex(),
                             expected=f"{case['expected']:032x}"))
        write_csv(out / 'cases.csv', ['index', 'category', 'name', 'vs1', 'vs2', 'expected'], rows)
        case_text = ''.join(f"{r['index']} {r['vs1']} {r['vs2']} {r['expected']}\n" for r in rows)
        case_path = out / 'cases.txt'
        case_path.write_text(case_text, encoding='ascii')
        shutil.copyfile(HERE / 'reference.c', out / 'build/reference.c')
        shutil.copyfile(HERE / 'check_datapath.sv', out / 'build/check_datapath.sv')
        reference = out / 'build' / ('reference.exe' if os.name == 'nt' else 'reference')
        execute([tools['gcc'], '-std=c11', '-O2', '-Wall', '-Wextra', '-Werror',
                 'build/reference.c', '-o', 'build/' + reference.name], out, 'reference_compile')
        output = execute([str(reference)], out, 'reference', case_text)
        expected_rows = {r['index']: int(r['expected'], 16) for r in rows}
        c_rows = {}
        for line in output.splitlines():
            parts = line.split()
            if len(parts) != 2 or int(parts[0]) in c_rows:
                raise ValueError('C参考计算输出不完整。')
            c_rows[int(parts[0])] = int(parts[1], 16)
        if c_rows != expected_rows:
            raise ValueError('C与Python独立计算不一致。')
        print('REFERENCE_PAIR_PASS cases=48', flush=True)
        summary = [dict(check='C and Python', status='PASS', cases=48, passed=48,
                        failed=0, scope='independent arithmetic')]
        source = ROOT / 'rtl/xs_vdot_unit.sv'
        for name, file, defines in [('RTL', source, ()),
                ('CHISEL', ROOT / 'gen/chisel/VDotUnit_t0_n8_o32_a19.sv', ('CHISEL',))]:
            result = run_rtl(out, case_path, tools, name, file, defines)
            if result['failed']:
                raise ValueError('现有电路与预期不一致：' + name)
            summary.append(dict(check=name, status='PASS', cases=48, passed=48,
                                failed=0, scope='128 bit datapath'))
            print(name + '_POSITION_PASS cases=48', flush=True)
        variants = []
        for lane in range(8):
            variants.append((f'drop_position_{lane}', source,
                             ('MODE=1', f'LANE_A={lane}')))
        for first in range(8):
            for second in range(first + 1, 8):
                variants.append((f'swap_one_input_{first}_{second}', source,
                                 ('MODE=2', f'LANE_A={first}', f'LANE_B={second}')))
        source_text = source.read_text(encoding='utf-8-sig')
        old = 'wire [4*SEW-1:0] pe = $signed(ae) * $signed(be);'
        if source_text.count(old) != 1:
            raise ValueError('不能准确定位乘法表达式。')
        unsigned_source = out / 'build/unsigned_products.sv'
        unsigned_source.write_text(source_text.replace(old,
            'wire [4*SEW-1:0] pe = $unsigned(av) * $unsigned(bv);'), encoding='utf-8')
        variants += [('unsigned_products', unsigned_source, ()),
                     ('accumulator_18_bits', source, ('ACCW=18',)),
                     ('consume_upper_positions', source, ('NLANES=16',)),
                     ('dirty_upper_result', source, ('MODE=4',)),
                     ('missing_sign_extension', source, ('MODE=5',))]
        differences = []
        for name, file, defines in variants:
            result = run_rtl(out, case_path, tools, name, file, defines)
            result['expectation'] = 'different'
            result['status'] = 'DETECTED' if result['failed'] else 'MISSED'
            differences.append(result)
        write_csv(out / 'error_detection.csv',
                  ['name', 'cases', 'passed', 'failed', 'first_difference', 'expectation', 'status'], differences)
        if any(row['status'] != 'DETECTED' for row in differences):
            raise ValueError('有故意引入的错误未被发现。')
        print('ERROR_DETECTION_PASS variants=' + str(len(differences)), flush=True)
        equivalents = []
        for first in range(8):
            for second in range(first + 1, 8):
                result = run_rtl(out, case_path, tools, f'swap_both_inputs_{first}_{second}',
                                 source, ('MODE=3', f'LANE_A={first}', f'LANE_B={second}'))
                result['expectation'] = 'same'
                result['status'] = 'EQUIVALENT' if not result['failed'] else 'DIFFERENT'
                equivalents.append(result)
        write_csv(out / 'equivalent_changes.csv',
                  ['name', 'cases', 'passed', 'failed', 'first_difference', 'expectation', 'status'], equivalents)
        if any(row['status'] != 'EQUIVALENT' for row in equivalents):
            raise ValueError('双输入同步交换位置改变了点积结果。')
        print('EQUIVALENCE_PASS variants=' + str(len(equivalents)), flush=True)
        parser_total = parser_checks()
        sample = inspect_elf(ROOT / 'examples/minimal_vdot.elf', args.objdump)
        (out / 'minimal_vdot.dis').write_text(sample['listing'], encoding='utf-8')
        print('INSTRUCTION_READER_PASS cases=' + str(parser_total) + ' supplied_elf=1', flush=True)
        summary.extend([
            dict(check='deliberate errors', status='PASS', cases=len(differences),
                 passed=len(differences), failed=0, scope='actual RTL changes detected'),
            dict(check='simultaneous input swaps', status='PASS', cases=len(equivalents),
                 passed=len(equivalents), failed=0, scope='equivalent changes accepted'),
            dict(check='instruction reader', status='PASS', cases=parser_total + 1,
                 passed=parser_total + 1, failed=0, scope='reader checks and supplied ELF'),
        ])
        write_csv(out / 'summary.csv', ['check', 'status', 'cases', 'passed', 'failed', 'scope'], summary)
        sources = [HERE / 'check.py', HERE / 'check_instructions.py', HERE / 'reference.c',
                   HERE / 'check_datapath.sv', ROOT / 'rtl/xs_vdot_unit.sv',
                   ROOT / 'gen/chisel/VDotUnit_t0_n8_o32_a19.sv', ROOT / 'examples/minimal_vdot.elf']
        write_csv(out / 'source_contents.csv', ['file', 'content_value'],
                  [dict(file=path.relative_to(ROOT).as_posix(),
                        content_value=hashlib.sha256(path.read_bytes()).hexdigest()) for path in sources])
        text = ('POSITION_CHECK_PASS cases=48 implementations=2\n'
                'REFERENCE_PAIR_PASS cases=48\n'
                'ERROR_DETECTION_PASS variants=41\n'
                'EQUIVALENCE_PASS variants=28\n'
                f'INSTRUCTION_READER_PASS cases={parser_total} supplied_elf=1\n'
                'RTL_COMPARISONS total=3408\n'
                'scope=module_arithmetic_and_full_128_bit_output\n'
                'alias_and_illegal_states=existing_full_processor_results_only\n')
        (out / 'summary.txt').write_text(text, encoding='utf-8')
        print(text, end='', flush=True)
        return 0
    except (ValueError, OSError, subprocess.TimeoutExpired) as error:
        message = 'POSITION_CHECK_FAIL ' + str(error)
        (out / 'failure.txt').write_text(message + '\n', encoding='utf-8')
        print(message, file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
