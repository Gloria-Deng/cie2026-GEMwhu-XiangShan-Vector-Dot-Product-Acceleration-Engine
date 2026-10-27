from pathlib import Path
import argparse
import csv
import os
import re
import shutil
import subprocess
import sys

sys.dont_write_bytecode = True


def find_objdump(explicit=None):
    if explicit:
        found = shutil.which(str(explicit))
        if found:
            return found
        raise ValueError('找不到指定的反汇编程序：' + str(explicit))
    candidates = ['riscv64-unknown-elf-objdump', 'riscv64-linux-gnu-objdump']
    for variable in ('RISCV_XPACK', 'RISCV_PREFIX'):
        base = os.environ.get(variable)
        if base:
            candidates.extend([str(Path(base) / 'bin/riscv64-unknown-elf-objdump'),
                               base + 'objdump'])
    if os.name == 'nt':
        for drive in ('C:', 'D:', 'E:'):
            candidates.append(drive + '/msys64/ucrt64/bin/riscv64-unknown-elf-objdump.exe')
    for candidate in candidates:
        found = shutil.which(candidate)
        if found:
            return found
    raise ValueError('需要 RISC-V GNU objdump；可用 --objdump 指定完整位置。')


def decode_listing(listing):
    records = []
    address_seen = set()
    section = None
    for line in listing.splitlines():
        if line.startswith('Disassembly of section '):
            section = line[len('Disassembly of section '):].rstrip(':')
            continue
        match = re.match(r'^\s*([0-9a-fA-F]+):\s+([0-9a-fA-F]{4}|[0-9a-fA-F]{8})\s+(.+)$', line)
        if section is None or not match:
            continue
        address = int(match[1], 16)
        if (section, address) in address_seen:
            raise ValueError('反汇编中出现重复地址。')
        address_seen.add((section, address))
        word = int(match[2], 16)
        name = 'other'
        if len(match[2]) == 8:
            if word & 0xfe00707f == 0xb2002057:
                name = 'vdot'
            elif word & 0x707f == 0x7057:
                name = 'vset'
            elif word & 0xfe0ff07f == 0x42002057:
                name = 'vmv.x.s'
            elif re.search(r'\bvs(?:1|2|4|8)r\.v\b', match[3]):
                name = 'whole_register_store'
        records.append(dict(section=section, address=f'0x{address:x}', word=match[2].lower(),
                            kind=name, destination=(word >> 7) & 31,
                            instruction=match[3].strip()))
    if not records:
        raise ValueError('没有读到可执行节中的机器指令。')
    return records


def inspect_listing(listing, minimum_vdot=1, expected_vdot=None,
                    require_vset=True, require_extract=False):
    if minimum_vdot < 0 or expected_vdot is not None and expected_vdot < 0:
        raise ValueError('指令数量不能为负。')
    records = decode_listing(listing)
    counts = {name: sum(row['kind'] == name for row in records)
              for name in ('vdot', 'vset', 'vmv.x.s', 'whole_register_store')}
    if counts['vdot'] < minimum_vdot:
        raise ValueError('程序中未包含要求数量的自定义点积指令。')
    if expected_vdot is not None and counts['vdot'] != expected_vdot:
        raise ValueError('程序中的点积指令数量与预期不同。')
    if require_vset and not counts['vset']:
        raise ValueError('程序中未找到向量配置指令。')
    if require_extract and not counts['vmv.x.s']:
        raise ValueError('程序中未找到要求的向量结果取出指令。')
    return {'counts': counts, 'instructions': records,
            'vdot_destinations': [row['destination'] for row in records
                                  if row['kind'] == 'vdot']}


def inspect_elf(path, objdump=None, **requirements):
    path = Path(path).resolve()
    if not path.is_file():
        raise ValueError('程序文件不存在：' + str(path))
    process = subprocess.run([find_objdump(objdump), '-d', path.name], cwd=path.parent,
                             capture_output=True, text=True,
                             encoding='utf-8', errors='replace')
    if process.returncode:
        raise ValueError('反汇编未完成：' + process.stdout + process.stderr)
    result = inspect_listing(process.stdout, **requirements)
    result['listing'] = process.stdout
    return result


def main():
    parser = argparse.ArgumentParser(description='检查实际编译程序中的向量配置、点积和结果取出指令。')
    parser.add_argument('elf', type=Path)
    parser.add_argument('--objdump')
    parser.add_argument('--expected-vdot', type=int)
    parser.add_argument('--minimum-vdot', type=int, default=1)
    parser.add_argument('--require-extract', action='store_true')
    parser.add_argument('--out', type=Path)
    args = parser.parse_args()
    try:
        result = inspect_elf(args.elf, args.objdump,
                             minimum_vdot=args.minimum_vdot,
                             expected_vdot=args.expected_vdot,
                             require_extract=args.require_extract)
        if args.out:
            out = args.out.resolve()
            if out.exists():
                raise ValueError('输出目录必须尚未存在。')
            out.mkdir(parents=True)
            (out / 'program.dis').write_text(result['listing'], encoding='utf-8')
            with (out / 'instruction_counts.csv').open('w', encoding='utf-8', newline='') as stream:
                writer = csv.writer(stream)
                writer.writerow(['instruction', 'count'])
                writer.writerows(result['counts'].items())
        print('INSTRUCTION_CHECK_PASS ' + ' '.join(
            name + '=' + str(count) for name, count in result['counts'].items()))
        return 0
    except (ValueError, OSError) as error:
        print('INSTRUCTION_CHECK_FAIL ' + str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
