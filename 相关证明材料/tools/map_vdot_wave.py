#!/usr/bin/env python3
"""Resolve the pipeline roles against declarations read from the current FST."""
import argparse
import csv
import gzip
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--hierarchy', required=True, type=Path)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    with gzip.open(args.hierarchy, 'rt', encoding='utf-8-sig', newline='') as stream:
        variables = list(csv.DictReader(stream))
    byname = {}
    for row in variables:
        name = re.sub(r'\s+\[[^]]+\]$', '', row['path'])
        byname.setdefault(name, []).append(row)
    matches = [n.rsplit('.io_in_valid', 1)[0] for n in byname if n.endswith('.Vdot.io_in_valid')]
    if len(matches) != 1:
        raise ValueError('expected one actual Vdot instance, got ' + str(matches))
    unit = matches[0]
    exu = unit.rsplit('.', 1)[0]
    backend = exu.split('.inner_vfExuBlock.')[0]
    rows = []

    def add(role, name):
        found = byname.get(name, [])
        if len(found) != 1:
            raise ValueError(f'{role}: actual declaration is not unique: {name}')
        rows.append(dict(role=role, path=found[0]['path'], width=found[0]['width']))

    add('clock', 'TOP.SimTop.clock')
    add('cycle', backend + '.inner_ctrlBlock.rob.difftest_trap_cycleCnt')
    add('timer', 'TOP.SimTop.timer')
    for role, port in dict(valid='valid', rob='bits_robIdx_value', flag='bits_robIdx_flag', level='bits_level').items():
        add('flush.' + role, backend + '.inner_ctrlBlock.io_toExuBlock_flush_' + port)
    for role, port in dict(valid='io_in_valid', ready='io_in_ready', op='io_in_bits_ctrl_fuOpType',
                           src0='io_in_bits_data_src_0', src1='io_in_bits_data_src_1').items():
        add('in.' + role, unit + '.' + port)
    for role, suffix in dict(rob='robIdx_value', flag='robIdx_flag', pdest='pdest').items():
        add('in.' + role, exu + '.io_in_bits_' + suffix)
    for role, port in dict(valid='io_out_valid', ready='io_out_ready', rob='io_out_bits_ctrl_robIdx_value',
                           flag='io_out_bits_ctrl_robIdx_flag', pdest='io_out_bits_ctrl_pdest',
                           data='io_out_bits_res_data').items():
        add('out.' + role, unit + '.' + port)
    for slot in range(6):
        prefix = backend + f'.inner_ctrlBlock.dispatch.io_fromRename_{slot}_'
        for role, suffix in dict(valid='valid', ready='ready', pc='bits_pc', instruction='bits_instr',
                                 rob='bits_robIdx_value', flag='bits_robIdx_flag', pdest='bits_pdest',
                                 psrc0='bits_psrc_0', psrc1='bits_psrc_1').items():
            add(f'dispatch.{slot}.' + role, prefix + suffix)
    for slot in range(8):
        prefix = backend + '.inner_ctrlBlock.rob.'
        add(f'commit.{slot}.enable', prefix + 'io_commits_isCommit')
        for role, port in dict(valid=f'io_commits_commitValid_{slot}',
                              pc=f'io_commits_info_{slot}_debug_pc', instruction=f'io_commits_info_{slot}_debug_instr',
                              rob=f'io_commits_robIdx_{slot}_value', flag=f'io_commits_robIdx_{slot}_flag',
                              pdest=f'io_commits_info_{slot}_basicDebug_pdest').items():
            add(f'commit.{slot}.' + role, prefix + port)
    for part in range(4):
        for port in range(5):
            prefix = backend + f'.inner_dataPath.vfRegFilePart{part}.io_writePorts_{port}_'
            for role, suffix in dict(valid='wen', addr='addr', data='data').items():
                add(f'wb.{part}.{port}.' + role, prefix + suffix)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.DictWriter(stream, ['role', 'path', 'width'])
        writer.writeheader()
        writer.writerows(rows)
    print(f'WAVE_MAPPING_PASS roles={len(rows)} instance={unit}')


if __name__ == '__main__':
    main()
