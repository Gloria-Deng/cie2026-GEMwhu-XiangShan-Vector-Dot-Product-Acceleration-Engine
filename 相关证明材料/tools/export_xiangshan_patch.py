#!/usr/bin/env python3

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
ROOT=Path(__file__).resolve().parents[1]
EXISTING=['src/main/scala/xiangshan/backend/fu/FuType.scala',
 'src/main/scala/xiangshan/backend/fu/FuConfig.scala','src/main/scala/xiangshan/Parameters.scala',
 'src/main/scala/xiangshan/backend/decode/VecDecoder.scala','src/main/scala/xiangshan/backend/decode/Instructions.scala',
 'src/main/scala/xiangshan/backend/decode/DecodeUnit.scala',
 'src/main/scala/xiangshan/backend/decode/VecExceptionGen.scala']
ADDED=['src/main/scala/xiangshan/backend/fu/wrapper/VDotU.scala',
       'src/main/scala/xiangshan/backend/fu/wrapper/VdotCfg.scala','src/main/scala/vdot/VDotUnit.scala']
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--upstream',type=Path,required=True);ap.add_argument('--bash',default='bash')
    args=ap.parse_args(); build=ROOT/'build';build.mkdir(exist_ok=True)
    work=Path(tempfile.mkdtemp(prefix='export_patch_',dir=build)); patched=work/'patched';control=work/'control'
    for dest in (patched,control):
        for rel in EXISTING:
            p=dest/rel;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(args.upstream/rel,p)
        subprocess.run(['git','-c','core.autocrlf=false','init','-q',str(dest)],check=True)
        subprocess.run(['git','-C',str(dest),'config','core.autocrlf','false'],check=True)
        subprocess.run(['git','-C',str(dest),'add','.'],check=True)
        subprocess.run(['git','-C',str(dest),'-c','user.name=Patch export','-c','user.email=export@localhost','commit','-qm','pristine'],check=True)
    def bashpath(p):
        s=p.resolve().as_posix()
        return '/'+s[0].lower()+s[2:] if os.name=='nt' else s
    env=os.environ.copy();env['PATH']=str(Path(args.bash).resolve().parent)+os.pathsep+env['PATH']
    r=subprocess.run([args.bash,bashpath(ROOT/'rtl/xiangshan-patch/apply.sh'),bashpath(patched)],env=env,capture_output=True,text=True,errors='replace')
    if r.returncode: raise SystemExit(r.stdout+r.stderr)
    subprocess.run(['git','-C',str(patched),'add','-N',*ADDED],check=True)
    content=subprocess.check_output(['git','-C',str(patched),'-c','core.autocrlf=false','diff','--',*(EXISTING+ADDED)])
    patch=ROOT/'rtl/xiangshan-patch/vdot.patch';patch.write_bytes(content)
    subprocess.run(['git','-C',str(control),'apply',str(patch)],check=True)
    if any((patched/p).read_bytes()!=(control/p).read_bytes() for p in EXISTING+ADDED):
        raise SystemExit('git apply differs from script')
    data={'all_ok':True,'inputs':{'rtl/xiangshan-patch/apply.sh':sha(ROOT/'rtl/xiangshan-patch/apply.sh'),
          'rtl/xiangshan-patch/VDotU.scala':sha(ROOT/'rtl/xiangshan-patch/VDotU.scala'),
          'rtl/xiangshan-patch/VdotCfg.scala':sha(ROOT/'rtl/xiangshan-patch/VdotCfg.scala'),
          'rtl/chisel/vdot/vdot/src/vdot/VDotUnit.scala':sha(ROOT/'rtl/chisel/vdot/vdot/src/vdot/VDotUnit.scala'),
          'rtl/xiangshan-patch/vdot.patch':sha(patch),
          'tools/export_xiangshan_patch.py':sha(Path(__file__))},'files':len(EXISTING+ADDED),
          'scope':'Fresh pinned source anchors and byte-equal git apply; compilation measured separately'}
    out=ROOT/'results/current';out.mkdir(exist_ok=True)
    (out/'patch_export.json').write_text(json.dumps(data,indent=2)+'\n')
    print('PATCH EXPORT PASS files=',data['files'])
if __name__=='__main__':main()
