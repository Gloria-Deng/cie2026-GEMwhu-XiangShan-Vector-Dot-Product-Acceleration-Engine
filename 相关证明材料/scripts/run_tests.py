#!/usr/bin/env python3

import argparse
import csv
from pathlib import Path
import subprocess
from test_common import classify, read_programs

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--run-root',type=Path,required=True)
    ap.add_argument('--group',choices=('pos','neg','bound','all','corpus'),required=True)
    ap.add_argument('--cycles',type=int)
    args=ap.parse_args()
    run=args.run_root.resolve()
    emu=run/'XiangShan/build/emu';library=run/'NEMU/build/riscv64-nemu-interpreter-so'
    for p in (emu,library):
        if not p.is_file(): raise ValueError('missing build product: '+str(p))
    programs=read_programs(run/'programs')
    groups=('pos','neg','bound') if args.group=='all' else (args.group,)
    output=run/'basic_results';output.mkdir(exist_ok=True)
    results=[]
    for group in groups:
        row=programs[group];image=run/'programs'/row['image']
        if not image.is_file(): raise ValueError('missing program: '+str(image))
        cycles=args.cycles or (30000+int(row['cases'])*200)
        command=[str(emu),'-i',str(image),'--diff='+str(library),'--ram-size=256MB','--no-squash','-s','1','-C',str(cycles)]
        path=output/(row['program']+'.txt')
        with path.open('w',encoding='utf-8') as f:
            result=subprocess.run(command,cwd=run,stdout=f,stderr=subprocess.STDOUT,timeout=7200)
        text=path.read_text(encoding='utf-8',errors='replace')
        passed,address=classify(text,result.returncode,int(row['OK'],16))
        results.append([group,row['cases'],row['OK'],address,result.returncode,passed,str(path)])
        print('group='+group+' cases='+row['cases']+' expected_OK='+row['OK']+' actual_end='+address)
        print('output='+str(path))
        print('BASIC_TEST_PASS' if passed else 'BASIC_TEST_FAIL')
        if not passed: break
    with (output/'latest_results.csv').open('w',encoding='utf-8',newline='') as f:
        w=csv.writer(f);w.writerow(['group','cases','expected_OK','actual_end','process_exit','passed','output']);w.writerows(results)
    return 0 if len(results)==len(groups) and all(r[5] for r in results) else 1

if __name__=='__main__': raise SystemExit(main())
