#!/usr/bin/env python3

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
ROOT=Path(__file__).resolve().parents[1]
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--library',type=Path,required=True)
    ap.add_argument('--cc',default='gcc')
    ap.add_argument('--programs',type=Path,default=ROOT/'build/cluster_programs')
    args=ap.parse_args(); build=ROOT/'build/instruction_cosim'
    exe=build/('run_image.exe' if os.name=='nt' else 'run_image')
    msys=os.name=='nt' and '/usr/bin/' in args.cc.replace('\\','/')
    def arg(p):
        s=p.as_posix() if isinstance(p,Path) else str(p)
        return re.sub(r'^(-I)?([A-Za-z]):/',lambda m:(m[1] or '')+'/'+m[2].lower()+'/',s) if msys else s
    cmd=[args.cc,'-O2','-I'+build.as_posix(),'-o',exe,ROOT/'nemu/cosim/run_image.c']
    if os.name!='nt': cmd+=['-ldl']
    subprocess.run([cmd[0]]+list(map(arg,cmd[1:])),check=True)
    manifest=json.loads((args.programs/'manifest.json').read_text())
    rows=[]; out=ROOT/'results/current'; out.mkdir(exist_ok=True)
    for row in manifest['programs']:
        symbols=row['symbols']; ok=symbols['OK']; end=0
        if row['kind']=='benchmark': ok=symbols['LANDING']; end=ok+row['landing_bytes']
        cmd=[str(exe),arg(args.library.resolve()),arg((args.programs/row['image']).resolve()),hex(ok),hex(symbols['BAD']),hex(end)]
        result=subprocess.run(cmd,capture_output=True,text=True,errors='replace',timeout=120)
        log=out/(row['name']+'_nemu.log'); log.write_text(result.stdout+result.stderr,encoding='utf-8')
        good=result.returncode==0 and 'IMAGE PASS' in result.stdout
        print(row['name'],'PASS' if good else 'FAIL',flush=True)
        rows.append({'name':row['name'],'ok':good,'rc':result.returncode,'image_sha256':row['image_sha256'],
                     'log':str(log.relative_to(ROOT)),'log_sha256':sha(log)})
    data={'schema':1,'scope':'NEMU-only image execution; no XiangShan timing measured',
          'inputs':{**manifest['inputs'],'nemu/cosim/run_image.c':sha(ROOT/'nemu/cosim/run_image.c'),
                    'tools/validate_programs_nemu.py':sha(Path(__file__))}, 'program_manifest_sha256':sha(args.programs/'manifest.json'),
          'library_sha256':sha(args.library),'all_ok':all(r['ok'] for r in rows),'programs':rows}
    (out/'programs_nemu.json').write_text(json.dumps(data,indent=2)+'\n')
    return 0 if data['all_ok'] else 1
if __name__=='__main__': raise SystemExit(main())
