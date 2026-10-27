#!/usr/bin/env python3

from __future__ import annotations
import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'tools'))
from runtime_common import matches_recorded_source
ANSI_RE = re.compile(r'\x1b\[[0-?]*[ -/]*[@-~]')
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()


def classify(log, rc, row):


    log = ANSI_RE.sub('', log)


    if rc != 0 or re.search(r'\bABORT\b|\bFAIL(?:ED)?\b|Assertion .*failed|different at pc|AddressSanitizer|Segmentation fault',log,re.I):
        return {'ok':False,'reason':'process or DiffTest failure'}
    ends = re.findall(r'Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = (0x[0-9a-fA-F]+)',log)
    if len(ends) != 1: return {'ok':False,'reason':'missing or ambiguous terminal PC'}
    pc = int(ends[0],16)
    if row['kind'] != 'benchmark':
        return {'ok':pc == row['symbols']['OK'],'pc':hex(pc),'reason':'terminal PC checked'}
    offset = pc - row['symbols']['LANDING']
    ok = 0 <= offset < row['landing_bytes'] and offset % 4 == 0
    return {'ok':ok,'pc':hex(pc),'cycles_lower':offset//4*row['cycle_grid'] if ok else None,
            'uncertainty_cycles':row['cycle_grid']-1,'reason':'cycle landing PC checked'}


def fit(points):
    n = len(points); xm = sum(x for x,y in points)/n; ym = sum(y for x,y in points)/n
    ssx = sum((x-xm)**2 for x,y in points)
    slope = sum((x-xm)*(y-ym) for x,y in points)/ssx
    intercept = ym-slope*xm
    sse = sum((y-(intercept+slope*x))**2 for x,y in points)
    sst = sum((y-ym)**2 for x,y in points)
    return {'cycles_per_iteration':slope,'intercept_cycles':intercept,
            'r_squared':1-sse/sst if sst else 0,'points':points,
            'slope_quantization_bound':7*sum(abs(x-xm) for x,y in points)/ssx}


def selftest():
    row={'kind':'functional','symbols':{'OK':0x80000010,'BAD':0x80000014}}
    good='Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = 0x80000010'
    assert classify(good,0,row)['ok']
    assert not classify(good,1,row)['ok']
    assert not classify(good.replace('10','14'),0,row)['ok']
    assert not classify(good+'\nv1_high different at pc = 0x80000000',0,row)['ok']
    assert not classify('',0,row)['ok']
    row={'kind':'benchmark','symbols':{'LANDING':0x80000100},'landing_bytes':256,'cycle_grid':8}
    log='Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = 0x80000140'
    assert classify(log,0,row)['cycles_lower'] == 128
    assert not classify(log.replace('140','141'),0,row)['ok']
    r=fit([(16,132),(64,516),(256,2052),(1024,8196)])
    assert r['cycles_per_iteration']==8 and r['r_squared']==1
    print('CLUSTER PARSER SELFTEST PASS')


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--run-root',type=Path)
    ap.add_argument('--workers',type=int,default=8)
    ap.add_argument('--repeat',type=int,default=3)
    ap.add_argument('--selftest',action='store_true')
    args=ap.parse_args()
    if args.selftest: selftest(); return 0
    if args.run_root is None: ap.error('--run-root required')
    if not 1 <= args.workers <= 8 or args.repeat < 3: ap.error('workers 1..8, repeat >=3')
    run=args.run_root.resolve(); output=run/'validation'; output.mkdir(exist_ok=True)
    bm=json.loads((run/'build_manifest.json').read_text())
    pm=json.loads((run/'programs/manifest.json').read_text())
    for p,want in {**bm['inputs'],**pm['inputs']}.items():
        if not matches_recorded_source(ROOT/p,want): raise SystemExit('stale build input: '+p)
    emu=Path(bm['emu']); lib=Path(bm['library'])
    for p,want in [(emu,bm['emu_sha256']),(lib,bm['library_sha256']),
                   (run/'programs/manifest.json',bm['program_manifest_sha256'])]:
        if sha(p)!=want: raise SystemExit('stale build product: '+str(p))
    for p,want in bm['patched_sources'].items():
        if sha(run/p)!=want: raise SystemExit('source changed since build: '+p)
    for row in pm['programs']:
        if sha(run/'programs'/row['image'])!=row['image_sha256']:
            raise SystemExit('modified image: '+row['image'])
    jobs=[(row,r) for row in pm['programs'] for r in range(args.repeat if row['kind']=='benchmark' else 1)]

    def execute(job):
        row,rep=job
        cycles=30000 + (row.get('cases',0)*200 if row['kind']!='benchmark' else row['iterations']*120)
        cmd=[str(emu),'-i',str(run/'programs'/row['image']),'--diff='+str(lib),
             '--ram-size=256MB','--no-squash','-s','1','-C',str(cycles)]
        name=row['name']+'_r'+str(rep); logpath=output/(name+'.log')
        try:
            with logpath.open('w') as f:
                r=subprocess.run(cmd,cwd=run,stdout=f,stderr=subprocess.STDOUT,timeout=7200)
            verdict=classify(logpath.read_text(errors='replace'),r.returncode,row)
        except subprocess.TimeoutExpired:
            verdict={'ok':False,'reason':'wall clock timeout'}
        verdict.update(name=row['name'],repeat=rep,kind=row['kind'],command=cmd,
                       log=logpath.name,log_sha256=sha(logpath))
        if row['kind']=='benchmark': verdict.update(arm=row['arm'],dependent=row['dependent'],iterations=row['iterations'])
        print(name,'PASS' if verdict['ok'] else 'FAIL',flush=True)
        return verdict

    with ThreadPoolExecutor(max_workers=args.workers) as pool: verdicts=list(pool.map(execute,jobs))
    performance={}
    if all(r['ok'] for r in verdicts):
        for dep in (False,True):
            arms={}
            for arm in ('vdot','baseline'):
                group=[r for r in verdicts if r['kind']=='benchmark' and r['dependent']==dep and r['arm']==arm]
                ns=sorted({r['iterations'] for r in group})
                if len(ns)<3: raise SystemExit('insufficient benchmark sweep')
                points=[]
                for n in ns:
                    ys=sorted(r['cycles_lower'] for r in group if r['iterations']==n)
                    points.append((n,ys[len(ys)//2]+3.5))
                arms[arm]=fit(points)
            a,b=arms['vdot'],arms['baseline']
            reliable=all(r['r_squared']>=0.99 and r['cycles_per_iteration']>r['slope_quantization_bound'] for r in arms.values())
            performance['dependent' if dep else 'independent']={'arms':arms,'quality_gate':reliable,
                'speedup':b['cycles_per_iteration']/a['cycles_per_iteration'] if reliable else None}
    data={'schema':1,'inputs':bm['inputs'],'build_manifest_sha256':sha(run/'build_manifest.json'),
          'scope':'Current KunminghuV2 full-SoC DiffTest, complete 128-bit results',
          'runs':verdicts,'functional_ok':all(r['ok'] for r in verdicts if r['kind']!='benchmark'),
          'all_runs_ok':all(r['ok'] for r in verdicts),'performance':performance}
    data['all_ok']=data['all_runs_ok'] and all(r['quality_gate'] for r in performance.values()) and len(performance)==2
    (output/'summary.json').write_text(json.dumps(data,indent=2)+'\n')
    (output/'build_manifest.json').write_text(json.dumps(bm,indent=2)+'\n')
    (output/'program_manifest.json').write_text(json.dumps(pm,indent=2)+'\n')
    print('FULL_SOC_PASS' if data['all_ok'] else 'FULL_SOC_FAIL',output)
    return 0 if data['all_ok'] else 1

if __name__=='__main__': raise SystemExit(main())
