#!/usr/bin/env python3
"""Build a fixed-layout vdot waveform image and optionally execute it in NEMU."""
from __future__ import annotations
import argparse
import csv
from datetime import datetime
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--prefix', default='riscv64-unknown-elf-')
    ap.add_argument('--out', type=Path)
    ap.add_argument('--ref', type=Path, help='execute function checks with this patched NEMU shared library')
    ap.add_argument('--nemu-root', type=Path, help='source tree matching --ref, including generated configuration')
    ap.add_argument('--cc', default='gcc')
    args = ap.parse_args()
    out = (args.out or ROOT/'results'/('vdot_wave_build_'+datetime.now().strftime('%Y%m%d_%H%M%S_%f'))).resolve()
    if out.exists() and any(out.iterdir()):
        raise ValueError('output directory must be new or empty')
    out.mkdir(parents=True, exist_ok=True)
    print('output='+str(out), flush=True)
    def tool(name):
        p = shutil.which(args.prefix+name)
        if not p: raise ValueError('missing tool: '+args.prefix+name)
        return p
    stem = out/'vdot_wave'
    commands = [
        [tool('as'),'-march=rv64gcv','-mabi=lp64d','-o',stem.with_suffix('.o'), ROOT/'programs/vdot_wave.S'],
        [tool('ld'),'-m','elf64lriscv','-Ttext=0x80000000','-Tdata=0x80100000','--no-relax','-e','_start',
         '-o',stem.with_suffix('.elf'),stem.with_suffix('.o')],
        [tool('objcopy'),'-O','binary',stem.with_suffix('.elf'),stem.with_suffix('.bin')],
    ]
    for cmd in commands: subprocess.run(list(map(str,cmd)),check=True)
    text = subprocess.check_output([tool('nm'),'-n',str(stem.with_suffix('.elf'))],text=True)
    (out/'symbols.txt').write_text(text,encoding='ascii')
    symbols = {p[2]:int(p[0],16) for line in text.splitlines() if len(p:=line.split())==3}
    (out/'vdot_wave.dis').write_text(subprocess.check_output([tool('objdump'),'-d',str(stem.with_suffix('.elf'))],text=True),encoding='utf-8')
    data = stem.with_suffix('.bin').read_bytes()
    expected = [8,204,-8,0,131072,-130048,129032,0,120,-1,8]
    rows=[]
    for i, value in enumerate(expected):
        offset=symbols['INPUTS']-0x80000000+32*i
        a=[x if x<128 else x-256 for x in data[offset:offset+8]]
        b=[x if x<128 else x-256 for x in data[offset+16:offset+24]]
        if sum(x*y for x,y in zip(a,b)) != value: raise ValueError('case data differs from expected result')
        name=f'VDOT_CASE_{i+1:02d}'
        rows.append(dict(name=name,pc=hex(symbols[name]),expected=f'0x{value&0xffffffff:032x}'))
    for group in ('CHAIN','INDEPENDENT'):
        for i in range(1,5):
            name=f'VDOT_{group}_{i}'
            rows.append(dict(name=name,pc=hex(symbols[name]),expected=f'0x{8:032x}'))
    for row in rows:
        off=int(row['pc'],16)-0x80000000
        row['instruction']=hex(int.from_bytes(data[off:off+4],'little'))
    with (out/'expected.csv').open('w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    if args.ref:
        if not args.nemu_root: raise ValueError('--ref requires --nemu-root to read the actual register layout')
        nm=args.nemu_root.resolve()
        includes=['include','lib-include','src/isa/riscv64/include','src/engine/interpreter',
                  'resource/softfloat/repo/source/include','resource/softfloat/repo/source/RISCV']
        cmd=[args.cc,'-O0','-o',str(out/'read_layout'),str(ROOT/'nemu/cosim/probe_offsets.c')]
        cmd+=['-I'+str(nm/p) for p in includes]
        cmd+=['-D__ISA__=riscv64','-D__ISA_riscv64__=1','-D_SHARE=1','-include',str(nm/'include/generated/autoconf.h')]
        subprocess.run(cmd,check=True)
        layout_text=subprocess.check_output([str(out/'read_layout')],text=True)
        (out/'layout.txt').write_text(layout_text,encoding='ascii')
        match=re.search(r'LAYOUT_BEGIN\s*\n(.*?)LAYOUT_END',layout_text,re.S)
        if not match: raise ValueError('NEMU headers did not return register layout')
        layout=dict(line.split() for line in match[1].strip().splitlines())
        if int(layout['VR_STRIDE'])!=16: raise ValueError('NEMU VLEN must be 128')
        (out/'cosim_layout.h').write_text(''.join(f'#define {key} {int(value)}\n' for key,value in layout.items()),encoding='ascii')
        original=(ROOT/'nemu/cosim/run_image.c').read_text(encoding='utf-8')
        anchor='  if (init2) init2(OFF_END); else init0();\n'
        if original.count(anchor)!=1: raise ValueError('runner initialization changed')
        addition=('  void (*set_ramsize)(size_t)=dlsym(h,"difftest_set_ramsize");\n'
                  '  if (!set_ramsize) return 3;\n'
                  '  set_ramsize((size_t)128*1024*1024);\n')
        (out/'run_image.c').write_text(original.replace(anchor,addition+anchor),encoding='utf-8')
        runner=out/'run_image'
        subprocess.run([args.cc,'-O2','-I'+str(out),'-o',str(runner),str(out/'run_image.c'),'-ldl'],check=True)
        p=subprocess.run([str(runner),str(args.ref.resolve()),str(stem.with_suffix('.bin')),
                          hex(symbols['OK']),hex(symbols['BAD']),'0'],capture_output=True,text=True,timeout=180)
        text=p.stdout+p.stderr
        (out/'nemu.txt').write_text(text,encoding='utf-8')
        if p.returncode or 'IMAGE PASS' not in p.stdout: raise ValueError('NEMU function check failed, exit='+str(p.returncode)+'; see '+str(out/'nemu.txt'))
        print('VDOT_WAVE_NEMU_PASS cases=11 dependent=4 independent=4')
    print('VDOT_WAVE_BUILD_PASS targets='+str(len(rows)))
    return 0

if __name__=='__main__':
    try: raise SystemExit(main())
    except (ValueError,OSError,subprocess.SubprocessError) as error:
        print('FAIL '+str(error),file=sys.stderr);raise SystemExit(1)
