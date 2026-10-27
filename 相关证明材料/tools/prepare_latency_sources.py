#!/usr/bin/env python3

import os
from pathlib import Path
import shutil
import subprocess
import sys

sys.path.insert(0,str(Path(__file__).resolve().parents[1]))
from run_latency import copy_source_additions

run = Path(os.environ['RUN_ROOT']).resolve()
if run.exists():
    raise SystemExit('RUN_ROOT exists')
sources = [(Path(os.environ['XS_PRISTINE']).resolve(), '42f87803d10bc21bbc5df2807a2fc07db6c9dc89'),
           (Path(os.environ['NEMU_PRISTINE']).resolve(), '3d9f9fb8c050')]
for src, expected in sources:
    if not src.is_dir() or src == run or run in src.parents or src in run.parents:
        raise SystemExit('invalid or overlapping source/destination: ' + str(src))
    if (src/'.git').exists():
        head = subprocess.check_output(['git','-C',str(src),'rev-parse','HEAD'],text=True).strip()
        if not head.startswith(expected):
            raise SystemExit('wrong upstream revision: ' + head)
xs = sources[0][0]
if 'val VdotCfg' in (xs/'src/main/scala/xiangshan/backend/fu/FuConfig.scala').read_text():
    raise SystemExit('XS_PRISTINE is already patched')
if 'def_EHelper(vdot)' in (sources[1][0]/'src/isa/riscv64/instr/rvv/vcompute.h').read_text():
    raise SystemExit('NEMU_PRISTINE is already patched')
run.mkdir(parents=True)
shutil.copytree(xs,run/'XiangShan',ignore=shutil.ignore_patterns('.git','build','out','.bsp'))
xs_copy = run/'XiangShan'
copy_source_additions(xs_copy)




subprocess.run(['git', '-C', str(xs_copy), 'init', '-q'], check=True)
subprocess.run(['git', '-C', str(xs_copy), 'config', 'core.autocrlf', 'false'], check=True)
subprocess.run(['git', '-C', str(xs_copy), 'config', 'user.email', 'vdot-build@localhost'], check=True)
subprocess.run(['git', '-C', str(xs_copy), 'config', 'user.name', 'vdot-build'], check=True)
subprocess.run(['git', '-C', str(xs_copy), 'add', '-A'], check=True)
subprocess.run(['git', '-C', str(xs_copy), 'commit', '-qm', 'isolated XiangShan source snapshot'], check=True)



component = xs_copy / 'difftest'
for arguments in (['init', '-q'], ['config', 'core.autocrlf', 'false'],
                  ['config', 'user.email', 'vdot-build@localhost'],
                  ['config', 'user.name', 'vdot-build'], ['add', '-A'],
                  ['commit', '-qm', 'isolated difftest sources']):
    subprocess.run(['git', '-C', str(component), *arguments], check=True)
print('isolated source prepared:',run)
