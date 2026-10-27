#!/usr/bin/env python3

import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    cc=shutil.which('riscv64-unknown-elf-gcc')
    if not cc and Path('E:/msys64/ucrt64/bin/riscv64-unknown-elf-gcc.exe').is_file():cc='E:/msys64/ucrt64/bin/riscv64-unknown-elf-gcc.exe'
    if not cc:raise SystemExit('RISC-V GCC missing')
    dump=str(Path(cc).with_name('riscv64-unknown-elf-objdump'+('.exe' if cc.endswith('.exe') else '')))
    build=ROOT/'build/asm_probe';build.mkdir(parents=True,exist_ok=True)
    obj=build/'probe.o'
    command=[cc,'-O2','-ffreestanding','-march=rv64gcv','-mabi=lp64d','-Wall','-Werror',
             '-c','software/asm_compile_probe.c','-o',obj.as_posix()]
    r=subprocess.run(command,cwd=ROOT,capture_output=True,text=True)
    if r.returncode:raise SystemExit(r.stdout+r.stderr)
    dis=subprocess.check_output([dump,'-d',obj.as_posix()],text=True,cwd=ROOT)
    ok=bool(re.search(r'\bb38cad57\b',dis)) and 'v24' in dis and 'v25' in dis and 'v26' in dis
    out=ROOT/'results/current';out.mkdir(exist_ok=True);log=out/'asm_compile.log'
    log.write_text('COMMAND '+repr(command)+'\n'+r.stdout+r.stderr+dis,encoding='utf-8')
    data={'all_ok':ok,'scope':'Real RISC-V GCC target compile and opcode check; target execution not measured',
          'inputs':{p:sha(ROOT/p) for p in ['software/include/vdot_vv.h','software/asm_compile_probe.c','tools/compile_asm_probe.py']},
          'logs':{'compile':{'path':str(log.relative_to(ROOT)),'sha256':sha(log)}},
          'compiler_version':subprocess.check_output([cc,'--version'],text=True).splitlines()[0]}
    (out/'asm_compile.json').write_text(json.dumps(data,indent=2)+'\n')
    print('RISC-V ASM COMPILE','PASS' if ok else 'FAIL')
    return 0 if ok else 1
if __name__=='__main__':raise SystemExit(main())
