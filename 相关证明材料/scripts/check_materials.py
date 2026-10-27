#!/usr/bin/env python3

import argparse
import csv
import re
from pathlib import Path
from test_common import ROOT, GROUPS, read_cases, signed, classify

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--write-readable',type=Path)
    ap.add_argument('--inputs-only',action='store_true',help='validate edited inputs without historical or description comparisons')
    args=ap.parse_args()
    if args.inputs_only:
        total=0
        for group in GROUPS:
            data=read_cases(group,enforce_count=False)
            total+=len(data)
            print('GROUP_PASS group='+group+' cases='+str(len(data))+' compare_bits=128')
        print('INPUTS_PASS groups=4 cases='+str(total))
        return
    rows=[]; readable=[]
    for group,count in GROUPS.items():
        data=read_cases(group)
        with (ROOT/'tests'/('cases_'+group+'.labels.csv')).open(encoding='utf-8-sig',newline='') as f:
            labels=list(csv.DictReader(f))
        if len(labels)!=count: raise ValueError('incorrect descriptions count')
        for index,((a,b,expected),label) in enumerate(zip(data,labels)):
            value=sum(signed(x)*signed(y) for x,y in zip(a[:8],b[:8]))
            if int(label['dot_result'])!=value: raise ValueError('description result differs')
            if bytes.fromhex(label['vs1_hex'])[::-1]!=a or bytes.fromhex(label['vs2_hex'])[::-1]!=b or int(label['vd_hex'],16)!=int.from_bytes(expected,'little'):
                raise ValueError('description input differs')
            readable.append([group,index,label['label'],' '.join(str(signed(x)) for x in a),' '.join(str(signed(x)) for x in b),value,expected[::-1].hex()])
        rows+=data
        print('GROUP_PASS group='+group+' cases='+str(count)+' compare_bits=128')
    binary=(ROOT/'programs/corpus_vl8_ta1.bin').read_bytes()
    expected=b''.join(a+b+want for a,b,want in rows)
    if binary[0x100020:]!=expected: raise ValueError('historical image data differs')
    if binary[0x50:0x54]!=bytes.fromhex('572294b2'): raise ValueError('instruction encoding differs')
    if binary[0x88:0x8c]!=bytes.fromhex('6f000000'): raise ValueError('success address differs')
    text=(ROOT/'results/historical/corpus_vl8_ta1.txt').read_text(encoding='utf-8',errors='replace')
    passed,address=classify(text,0,0x80000088)
    if not passed: raise ValueError('historical XiangShan output does not show successful completion')
    with (ROOT/'results/historical/summary.csv').open(encoding='utf-8-sig',newline='') as f:
        summary=list(csv.DictReader(f))
    if len(summary)!=1 or summary[0]['result']!='PASS' or summary[0]['actual_end']!=address or summary[0]['total']!=str(len(rows)):
        raise ValueError('historical summary differs')
    if args.write_readable:
        args.write_readable.parent.mkdir(parents=True,exist_ok=True)
        with args.write_readable.open('w',encoding='utf-8-sig',newline='') as f:
            w=csv.writer(f);w.writerow(['group','index','description','A_lane0_to_15','B_lane0_to_15','signed_dot','vd_128bit_hex']);w.writerows(readable)
    print('HISTORICAL_SOC_PASS program=corpus_vl8_ta1 cases=939 end='+address)
    print('MATERIALS_PASS cases=939 groups=4')

if __name__=='__main__': main()
