
from pathlib import Path
import csv
import re

ROOT = Path(__file__).resolve().parents[1]
GROUPS = {'pos': 46, 'neg': 48, 'bound': 45, 'rand': 800}
ANSI = re.compile(r'\x1b\[[0-?]*[ -/]*[@-~]')

def signed(value):
    return value if value < 128 else value - 256

def read_cases(group, enforce_count=True):
    rows=[]
    for line in (ROOT/'tests'/('cases_'+group+'.txt')).read_text(encoding='ascii').splitlines():
        parts=line.split()
        if not parts: continue
        if len(parts)!=4: raise ValueError('invalid input row')
        index,a,b,want=parts
        a=int(a,16).to_bytes(16,'little'); b=int(b,16).to_bytes(16,'little')
        expected=int(want,16).to_bytes(16,'little')
        value=sum(signed(x)*signed(y) for x,y in zip(a[:8],b[:8]))
        if int.from_bytes(expected,'little') != value & 0xffffffff:
            raise ValueError('incorrect complete expected result: '+group+' '+index)
        rows.append((a,b,expected))
    if not rows: raise ValueError('empty input group: '+group)
    if enforce_count and len(rows)!=GROUPS[group]: raise ValueError('incorrect input count: '+group)
    return rows

def corpus_program(rows):
    src='''.option norvc
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
  la s0,CASES
  la s1,OUT
  la s2,POISON
'''
    src+='  li s3,%d\n' % len(rows)
    src+='''CASE_LOOP:
  vsetivli zero,16,e8,m1,ta,ma
  vle8.v v4,(s2)
  vle8.v v8,(s0)
  addi t0,s0,16
  vle8.v v9,(t0)
  vsetivli zero,8,e8,m1,ta,mu
  .word 0xb2942257
  vs1r.v v4,(s1)
  ld t0,0(s1)
  ld t1,32(s0)
  bne t0,t1,BAD
  ld t0,8(s1)
  ld t1,40(s0)
  bne t0,t1,BAD
  addi s0,s0,48
  addi s3,s3,-1
  bnez s3,CASE_LOOP
  j OK
.balign 4
BAD: j BAD
UNEXPECTED_TRAP: j BAD
OK: j OK
.section .data
.balign 16
POISON:
.byte 165,165,165,165,165,165,165,165,165,165,165,165,165,165,165,165
OUT: .zero 16
CASES:
'''
    for a,b,expected in rows:
        src+='.byte '+','.join(map(str,a+b+expected))+'\n'
    return src

def classify(text, rc, ok_address):
    text=ANSI.sub('',text)
    ends=re.findall(r'Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = (0x[0-9a-fA-F]+)',text)
    error=re.search(r'\bABORT\b|\bFAIL(?:ED)?\b|Assertion .*failed|different at pc|AddressSanitizer|Segmentation fault',text,re.I)
    enabled='Difftest enabled' in text
    passed=rc==0 and enabled and not error and len(ends)==1 and int(ends[0],16)==ok_address
    return bool(passed),ends[0] if len(ends)==1 else ''

def read_programs(directory):
    with (Path(directory)/'programs.csv').open(encoding='utf-8',newline='') as f:
        return {row['group']:row for row in csv.DictReader(f)}
