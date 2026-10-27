#!/usr/bin/env python3

from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
BASE = 0x80000000
LANDING_BYTES = 0x40000


def digest(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def dot(a, b):
    return sum((x if x < 128 else x-256)*(y if y < 128 else y-256)
               for x, y in zip(a[:8], b[:8])) & 0xffffffff


def byte_line(data):
    return '.byte ' + ','.join(map(str, data))


def vdot_word(vd):
    return (0b101100 << 26) | (1 << 25) | (9 << 20) | (8 << 15) | (2 << 12) | (vd << 7) | 0x57


BOOT = '''.option norvc
.option norelax
.section .text
.globl _start
_start:
  li t0,0x600
  csrw mstatus,t0
  li t0,8
  csrw 0x744,t0
  la t0,UNEXPECTED_TRAP
  csrw mtvec,t0
'''
END = '''
.balign 4
BAD: j BAD
UNEXPECTED_TRAP: j BAD
OK: j OK
'''


def corpus_program(rows, vl=8, ta=1, vd=4, operation='vdot'):
    src = BOOT + '  la s0,CASES\n  la s1,OUT\n  la s2,POISON\n'
    src += '  li s3,%d\nCASE_LOOP:\n  vsetivli zero,16,e8,m1,ta,ma\n' % len(rows)

    src += '  vle8.v v%d,(s2)\n  vle8.v v8,(s0)\n  addi t0,s0,16\n  vle8.v v9,(t0)\n' % vd
    src += '  vsetivli zero,%d,e8,m1,%s,mu\n' % (vl, 'ta' if ta else 'tu')
    if operation == 'vdot':
        src += '  .word 0x%08x\n' % vdot_word(vd)
    else:
        src += '  vadd.vv v%d,v8,v9\n' % vd
    src += '  vs1r.v v%d,(s1)\n  ld t0,0(s1)\n  ld t1,32(s0)\n  bne t0,t1,BAD\n' % vd
    src += '  ld t0,8(s1)\n  ld t1,40(s0)\n  bne t0,t1,BAD\n'
    src += '  addi s0,s0,48\n  addi s3,s3,-1\n  bnez s3,CASE_LOOP\n  j OK\n' + END
    src += '.section .data\n.balign 16\nPOISON:\n' + byte_line(bytes([0xa5]*16)) + '\n'
    src += 'OUT: .zero 16\nCASES:\n'
    for a, b, expected in rows:
        src += byte_line(a+b+expected) + '\n'
    return src


def benchmark_program(n, arm, dependent):
    a = bytes(range(1,9)) + bytes([0x51]*8)
    b = bytes(x & 255 for x in (1,-2,3,-4,5,-6,7,-8)) + bytes([0xb7]*8)
    state = a
    for _ in range(n):
        value = dot(state, b)
        if dependent:
            state = value.to_bytes(4, 'little') + bytes(12)
    want = dot(a,b) if not dependent else value
    src = BOOT + '  la s0,INPUT_A\n  la s1,INPUT_B\n  la s2,POISON\n  la s3,OUT\n'
    src += '  vsetivli zero,16,e8,m1,ta,ma\n  vle8.v v8,(s0)\n  vle8.v v9,(s1)\n  vle8.v v4,(s2)\n'


    src += '  vsetivli zero,8,e8,m1,ta,ma\n  li s4,%d\n' % n
    src += '  fence rw,rw\n  csrr s5,cycle\nBENCH_LOOP:\n'
    if arm == 'vdot':
        src += '  .word 0x%08x\n' % vdot_word(4)
    else:
        src += '  vwmul.vv v6,v9,v8\n  vsetivli zero,8,e16,m1,tu,mu\n'
        src += '  vmv.v.i v4,0\n  vwredsum.vs v4,v6,v4\n'


        src += '  vsetivli zero,8,e8,m1,ta,ma\n'
    if dependent:
        src += '  vmv1r.v v8,v4\n'
    src += '  addi s4,s4,-1\n  bnez s4,BENCH_LOOP\n'


    src += '  vs1r.v v4,(s3)\n  fence rw,rw\n  ld t0,0(s3)\n  ld t1,8(s3)\n  csrr s6,cycle\n'
    src += '  li t2,0x%08x\n  slli t2,t2,32\n  srli t2,t2,32\n  bne t0,t2,BAD\n  bnez t1,BAD\n' % want
    src += '  sub s6,s6,s5\n  li t0,%d\n  bgeu s6,t0,BAD\n' % (LANDING_BYTES*2)
    src += '  srli s6,s6,3\n  slli s6,s6,2\n  la t0,LANDING\n  add t0,t0,s6\n  jr t0\n' + END
    src += '.balign 4\nLANDING:\n.rept %d\n  j .\n.endr\n' % (LANDING_BYTES//4)
    src += '.section .data\n.balign 16\nINPUT_A:\n' + byte_line(a) + '\nINPUT_B:\n' + byte_line(b)
    src += '\nPOISON:\n' + byte_line(bytes([0xa5]*16)) + '\nOUT: .zero 16\n'
    return src


def illegal_program(setting):
    setup = {'sew':'  vsetivli zero,8,e16,m1,tu,mu\n',
             'lmul':'  vsetivli zero,8,e8,m2,tu,mu\n',
             'fractional_lmul':'  vsetivli zero,8,e8,mf2,tu,mu\n',
             'mask':'  vsetivli zero,8,e8,m1,tu,mu\n',
             'restart':'  vsetivli zero,8,e8,m1,tu,mu\n  li t0,1\n  csrw vstart,t0\n',
             'vill':'  vsetivli zero,8,e64,mf8,tu,mu\n'}[setting]
    word = vdot_word(4) ^ ((1<<25) if setting=='mask' else 0)
    return BOOT + setup + '''  la t0,EXPECT_TRAP
  csrw mtvec,t0
FAULT:
  .word 0x%08x
  j BAD
EXPECT_TRAP:
  csrr t0,mcause
  li t1,2
  bne t0,t1,BAD
  csrr t0,mepc
  la t1,FAULT
  bne t0,t1,BAD
  j OK
''' % word + END


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--prefix', default='riscv64-unknown-elf-')
    ap.add_argument('--out', type=Path, default=ROOT/'build/cluster_programs')
    ap.add_argument('--iterations', type=int, nargs='+', default=[16,64,256,1024])
    args = ap.parse_args()
    out = args.out.resolve(); out.mkdir(parents=True, exist_ok=True)
    def find_tool(k):
        name = args.prefix + k
        return shutil.which(name) or (str(Path(name + '.exe').resolve())
                                     if Path(name + '.exe').is_file() else None)
    tools = {k: find_tool(k) for k in ('as','ld','objcopy','nm','objdump')}
    if not all(tools.values()):
        raise SystemExit('missing RISC-V binutils: ' + str(tools))
    if len(set(args.iterations)) < 3 or any(n < 1 for n in args.iterations):
        raise SystemExit('need at least three distinct positive iteration counts')
    rows = []
    for group in ('pos','neg','bound','rand'):
        for line in (ROOT/'tests'/('cases_'+group+'.txt')).read_text().splitlines():
            fields = line.split()
            if len(fields) != 4: continue
            _, a, b, expected = fields
            a = int(a,16).to_bytes(16,'little'); b = int(b,16).to_bytes(16,'little')
            expected = int(expected,16).to_bytes(16,'little')
            if int.from_bytes(expected,'little') != dot(a,b):
                raise SystemExit('corpus expectation is not a complete fixed-window result')
            rows.append((a,b,expected))
    programs = []

    def emit(name, source, metadata):
        assembly = out/(name+'.S'); assembly.write_text(source, encoding='ascii')
        obj = out/(name+'.o'); elf = out/(name+'.elf'); binary = out/(name+'.bin')
        commands = [[tools['as'],'-march=rv64gcv','-mabi=lp64d','-o',obj,assembly],


                    [tools['ld'],'-m','elf64lriscv','-Ttext=0x80000000','-Tdata=0x80100000','--no-relax','-e','_start','-o',elf,obj],
                    [tools['objcopy'],'-O','binary',elf,binary]]
        for cmd in commands:
            r = subprocess.run(list(map(str,cmd)), capture_output=True, text=True)
            if r.returncode: raise SystemExit(r.stderr)
        nm = subprocess.check_output([tools['nm'],'-n',str(elf)],text=True)
        symbols = {line.split()[2]: int(line.split()[0],16) for line in nm.splitlines()
                   if len(line.split()) == 3 and line.split()[1].lower() in ('t','d')}
        dis = subprocess.check_output([tools['objdump'],'-d',str(elf)],text=True)
        (out/(name+'.dis')).write_text(dis,encoding='utf-8')
        row = {'name':name, 'image':binary.name, 'image_sha256':digest(binary),
               'assembly_sha256':digest(assembly), 'symbols':symbols, **metadata}
        programs.append(row); print(name, 'BUILT', binary.stat().st_size)

    emit('corpus_vl8_ta1',corpus_program(rows),{'kind':'functional','cases':len(rows),'vl':8,'vta':1,'vd':4})

    subset = rows[:139] + rows[-32:]
    for vl, ta in ((0,0),(1,1),(4,0),(8,0),(16,1)):
        emit('scope_vl%d_ta%d'%(vl,ta),corpus_program(subset,vl,ta),
             {'kind':'functional','cases':len(subset),'vl':vl,'vta':ta,'vd':4})
    for vd in (0,8,9):
        emit('alias_v%d'%vd,corpus_program(subset,8,1,vd),
             {'kind':'functional','cases':len(subset),'vl':8,'vta':1,'vd':vd})
    vadd_rows = [(a,b,bytes((x+y)&255 for x,y in zip(a,b))) for a,b,_ in subset[:11]]
    emit('vadd_full_register',corpus_program(vadd_rows,16,0,4,'vadd'),{'kind':'vadd','cases':len(vadd_rows)})
    for setting in ('sew','lmul','fractional_lmul','mask','restart','vill'):
        emit('illegal_'+setting,illegal_program(setting),{'kind':'illegal','cases':1,'setting':setting})
    for dependent in (False,True):
        for n in sorted(set(args.iterations)):
            for arm in ('vdot','baseline'):
                name = 'bench_%s_%s_n%d'%('dependent' if dependent else 'independent',arm,n)
                emit(name,benchmark_program(n,arm,dependent),
                     {'kind':'benchmark','arm':arm,'dependent':dependent,'iterations':n,
                      'cycle_grid':8,'landing_bytes':LANDING_BYTES})
    inputs = ['rtl/xiangshan-patch/VDotU.scala','rtl/xiangshan-patch/apply.sh',
              'rtl/chisel/vdot/vdot/src/vdot/VDotUnit.scala','nemu/apply_nemu_patch.py',
              'tools/gen_cluster_programs.py']
    inputs += [str(p.relative_to(ROOT)) for p in sorted((ROOT/'tests').glob('cases_*.txt'))]
    manifest = {'schema':1,'load_address':BASE,'inputs':{p:digest(ROOT/p) for p in inputs},
                'programs':programs,'benchmark_scope':'Repeated kernel, including loop and baseline e8 restore; setup excluded.'}
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
