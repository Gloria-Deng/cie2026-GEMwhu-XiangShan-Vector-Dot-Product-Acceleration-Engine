#!/usr/bin/env python3

from pathlib import Path
import argparse
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--prefix', default='riscv64-unknown-elf-')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    out = a.out.resolve()
    if out == ROOT or ROOT in out.parents:
        p.error('--out must be outside the package')
    if out.exists() and any(out.iterdir()):
        p.error('--out must be new or empty')
    tools = {k: shutil.which(a.prefix+k) or shutil.which(a.prefix+k+'.exe')
             for k in ('as', 'ld', 'objcopy', 'objdump', 'nm')}
    if not all(tools.values()):
        p.error('Missing RISC-V GNU tools: '+', '.join(k for k,v in tools.items() if not v))
    out.mkdir(parents=True, exist_ok=True)
    src = ROOT/'gen/cluster_programs/vadd_full_register.S'
    obj,elf,binary = [out/('vadd_full_register.'+x) for x in ('o','elf','bin')]
    commands = [[tools['as'],'-march=rv64gcv','-mabi=lp64d','-o',obj,src],
                [tools['ld'],'-m','elf64lriscv','-Ttext=0x80000000','-Tdata=0x80100000',
                 '--no-relax','-e','_start','-o',elf,obj],
                [tools['objcopy'],'-O','binary',elf,binary]]
    for cmd in commands:
        subprocess.run(list(map(str,cmd)), check=True)
    (out/'vadd_full_register.dis').write_text(subprocess.check_output(
        [tools['objdump'],'-d',str(elf)],text=True),encoding='utf-8')
    (out/'symbols.txt').write_text(subprocess.check_output(
        [tools['nm'],'-n',str(elf)],text=True),encoding='utf-8')
    data=binary.read_bytes()
    if data != (ROOT/'gen/cluster_programs/vadd_full_register.bin').read_bytes():
        raise SystemExit('FAIL: rebuilt binary differs from supplied image')
    print('PASS: rebuilt image matches all',len(data),'bytes')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
