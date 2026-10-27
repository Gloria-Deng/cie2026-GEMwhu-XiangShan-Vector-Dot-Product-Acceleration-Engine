#!/usr/bin/env python3

from pathlib import Path
from types import SimpleNamespace
import argparse
import json
import os
import subprocess
import sys
import tempfile

sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'tools'))
from runtime_common import digest,new_output
from check_local_delivery import check_cluster,check_current,check_wave

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out',type=Path)
    parser.add_argument('--scratch',type=Path)
    args=parser.parse_args()
    out=new_output(args.out) if args.out else Path(tempfile.mkdtemp(prefix='xs_env_review_'))
    report={'ok':False,'checks':{},'errors':[]}
    try:
        report['checks']['current']=check_current()
        print('Recorded functional results PASS',flush=True)
        validation=ROOT/'results/cluster/20261019'
        report['checks']['full_core']=check_cluster(validation)
        print('Recorded full-core executions PASS 64',flush=True)
        wave_args=SimpleNamespace(image=None,tables_only=False,fst=None,library=None,scratch=args.scratch)
        report['checks']['wave']=check_wave(wave_args,out,validation)
        print('Raw FST PASS 11 executions 176 byte results',flush=True)
        env=os.environ.copy();env['TEAM_ID']='GEMwhu'
        cmds=[('Python',[sys.executable,'-B',str(ROOT/'stage1/hello_xiangshan_anyos.py')])]
        if os.name=='nt':cmds.append(('C',[str(ROOT/'stage1/hello_xiangshan.exe')]))
        identities=[]
        for label,cmd in cmds:
            result=subprocess.run(cmd,cwd=ROOT,env=env,capture_output=True,timeout=30)
            if result.returncode:raise ValueError(label+' identity program failed')
            text=result.stdout.decode('utf8',errors='replace')
            first=text.splitlines()[0]
            if not first.startswith('hello xiangshan, I am GEMwhu, IP address '):raise ValueError('identity line differs')
            identities.append(first)
            (out/('identity_'+label+'.txt')).write_text(text,encoding='utf8')
        if len(set(identities))!=1:raise ValueError('C and Python network addresses differ')
        report['checks']['identity']=identities
        print(identities[0],flush=True)
        report['ok']=True
        print('ENVIRONMENT_PACKAGE_PASS',flush=True)
    except Exception as exc:
        report['errors'].append(str(exc));print('ENVIRONMENT_PACKAGE_FAIL',str(exc),flush=True)
    (out/'review_result.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    return 0 if report['ok'] else 1

if __name__=='__main__':raise SystemExit(main())
