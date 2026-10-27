#!/usr/bin/env python3

import argparse,csv,json,sys,tempfile
from pathlib import Path
from analyze_vadd_fst import Timeline,analyze

def check_failures(original,meta,image):
    cases=[('missing_target','exu2_fuop',None,'0'),('wrong_result','fu_res_data',4315,'flip'),('not_ready','exu2_in_ready',None,'0'),('wrong_cycle','cycleCnt',4314,'flip')]
    results=[]
    for name,key,time,change in cases:
        rows=[dict(r) for r in original];n=0
        for r in rows:
            if r['name']==key and (time is None or int(r['time'])==time):
                value=('0'*len(r['value'])) if change=='0' else r['value'][:-1]+('1' if r['value'][-1]=='0' else '0')
                n+=value!=r['value'];r['value']=value
        if not n:raise ValueError(name+': no sample changed')
        try:analyze(Timeline(rows,meta),image,meta)
        except ValueError as exc:
            results.append(dict(case=name,returncode=1,expected_failure=True,reason=str(exc)))
        else:raise ValueError(name+': invalid input was accepted')
    return results

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[1]);ap.add_argument('--out',type=Path);a=ap.parse_args()
    root=a.root.resolve();base=root/'results/vadd_wave_stage1'
    with (base/'extract_all.csv').open(encoding='utf-8-sig',newline='') as f:original=list(csv.DictReader(f))
    meta=json.loads((base/'selected_signals.json').read_text(encoding='utf8'))
    results=check_failures(original,meta,root/'gen/cluster_programs/vadd_full_register.bin')
    target=(a.out or Path(tempfile.mkdtemp(prefix='vadd_failures_'))/'failure_checks.json').resolve()
    if target==root or root in target.parents:ap.error('--out must be outside the project')
    if target.exists():ap.error('--out already exists')
    target.parent.mkdir(parents=True,exist_ok=True)
    target.write_text(json.dumps(dict(ok=True,checks=results),ensure_ascii=False,indent=2)+'\n',encoding='utf8')
    print('PASS: four invalid inputs were rejected')
if __name__=='__main__':main()
