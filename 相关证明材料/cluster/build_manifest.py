#!/usr/bin/env python3
import hashlib
import json
import os
from pathlib import Path
import subprocess
from build_configuration import load_configuration

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
root = Path(os.environ['SUBMISSION']).resolve()
run = Path(os.environ['RUN_ROOT']).resolve()
xs = run/'XiangShan'; nm = run/'NEMU'
copies = {
 'rtl/xiangshan-patch/VDotU.scala':xs/'src/main/scala/xiangshan/backend/fu/wrapper/VDotU.scala',
 'rtl/chisel/vdot/vdot/src/vdot/VDotUnit.scala':xs/'src/main/scala/vdot/VDotUnit.scala',
}
for source, dest in copies.items():
    if sha(root/source) != sha(dest): raise SystemExit('patched source mismatch: '+source)
emu = xs/'build/emu'; lib = nm/'build/riscv64-nemu-interpreter-so'
if not emu.is_file() or not lib.is_file(): raise SystemExit('missing build products')
manifest = json.loads((run/'programs/manifest.json').read_text())
paths = list(manifest['inputs']) + ['cluster/build.sbatch','cluster/prepare_sources.py',
  'cluster/build_manifest.py','cluster/build_configuration.py','cluster/run_suite.py','cluster/test.sbatch','tools/run_instruction_cosim.py',
  'nemu/cosim/cosim_baseline.c','nemu/cosim/probe_offsets.c','nemu/cosim/rtl_vectors_to_cosim.py']
data = {'schema':1,'inputs':{p:sha(root/p) for p in paths},
 'emu':str(emu),'emu_sha256':sha(emu),'library':str(lib),'library_sha256':sha(lib),
 'program_manifest_sha256':sha(run/'programs/manifest.json'),
 'patched_sources':{str(p.relative_to(run)):sha(p) for p in list(copies.values())+
      [xs/'src/main/scala/xiangshan/backend/fu/FuConfig.scala',
       xs/'src/main/scala/xiangshan/backend/fu/FuType.scala',xs/'src/main/scala/xiangshan/Parameters.scala',
       xs/'src/main/scala/xiangshan/backend/decode/Instructions.scala',xs/'src/main/scala/xiangshan/backend/decode/VecDecoder.scala',
       xs/'src/main/scala/xiangshan/backend/decode/DecodeUnit.scala',
       nm/'src/isa/riscv64/instr/rvv/vcompute.h',nm/'src/isa/riscv64/instr/rvv/vcommon.c',nm/'.config']},
 'configuration':load_configuration(run),
 'tools':{c:subprocess.run([c,'--version'],capture_output=True,text=True).stdout.splitlines()[:2]
          for c in ['verilator','gcc','riscv64-unknown-elf-as']}}
(run/'build_manifest.json').write_text(json.dumps(data,indent=2)+'\n')
