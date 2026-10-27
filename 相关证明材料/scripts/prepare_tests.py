#!/usr/bin/env python3

import argparse
import csv
from pathlib import Path
import shutil
import subprocess
from test_common import ROOT, GROUPS, read_cases, corpus_program

def tool(prefix,name):
    value=prefix+name
    found=shutil.which(value)
    if found: return found
    for p in (Path(value),Path(value+'.exe')):
        if p.is_file(): return str(p.resolve())
    raise ValueError('missing tool: '+value)

def main():
    ap=argparse.ArgumentParser(description='Compile the three basic test programs.')
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--prefix',default='riscv64-unknown-elf-')
    args=ap.parse_args()
    out=args.out.resolve();out.mkdir(parents=True,exist_ok=True)
    tools={n:tool(args.prefix,n) for n in ('as','ld','objcopy','objdump','nm')}
    records=[]
    for group in ('pos','neg','bound'):
        rows=read_cases(group,enforce_count=False)
        name='basic_'+group
        source=out/(name+'.S');obj=out/(name+'.o');elf=out/(name+'.elf');binary=out/(name+'.bin')
        source.write_text(corpus_program(rows),encoding='ascii',newline='\n')
        for command in ([tools['as'],'-march=rv64gcv','-mabi=lp64d','-o',obj,source],
                        [tools['ld'],'-m','elf64lriscv','-Ttext=0x80000000','-Tdata=0x80100000','--no-relax','-e','_start','-o',elf,obj],
                        [tools['objcopy'],'-O','binary',elf,binary]):
            subprocess.run(list(map(str,command)),check=True)
        listing=subprocess.check_output([tools['nm'],'-n',str(elf)],text=True)
        symbols={p[2]:int(p[0],16) for line in listing.splitlines() if len(p:=line.split())==3}
        dis=subprocess.check_output([tools['objdump'],'-d',str(elf)],text=True)
        (out/(name+'.dis')).write_text(dis,encoding='utf-8')
        records.append([group,name,len(rows),hex(symbols['OK']),hex(symbols['BAD']),binary.name])
        print('PROGRAM_BUILT group='+group+' cases='+str(len(rows))+' OK='+hex(symbols['OK']))
    for suffix in ('.S','.bin','.elf','.dis'):
        src=ROOT/'programs'/('corpus_vl8_ta1'+suffix);dst=out/src.name
        if src.resolve()!=dst.resolve(): shutil.copy2(src,dst)
    records.append(['corpus','corpus_vl8_ta1',939,'0x80000088','0x80000080','corpus_vl8_ta1.bin'])
    with (out/'programs.csv').open('w',encoding='utf-8',newline='') as f:
        w=csv.writer(f);w.writerow(['group','program','cases','OK','BAD','image']);w.writerows(records)
    print('BUILD_PASS '+' '.join(str(r[0])+'='+str(r[2]) for r in records[:3]))

if __name__=='__main__': main()
