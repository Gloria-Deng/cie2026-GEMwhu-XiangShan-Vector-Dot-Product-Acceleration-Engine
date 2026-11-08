#!/usr/bin/env python3
"""Discover real FST paths, then analyze explicitly mapped vdot pipeline signals."""
from __future__ import annotations
import argparse
from bisect import bisect_right
import csv
import gzip
from datetime import datetime
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]

def require(ok, text):
    if not ok: raise ValueError(text)

def write_csv(path, rows, columns=None):
    opener=gzip.open if path.suffix=='.gz' else open
    with opener(path,'wt',newline='',encoding='utf-8-sig') as f:
        w=csv.DictWriter(f,fieldnames=columns or list(rows[0]));w.writeheader();w.writerows(rows)

def read_csv(path):
    with path.open(encoding='utf-8-sig',newline='') as f: return list(csv.DictReader(f))

def template():
    roles=['clock','cycle','timer']
    roles+=['flush.'+p for p in ('valid','rob','flag','level')]
    roles+=['in.'+p for p in ('valid','ready','op','rob','flag','pdest','src0','src1')]
    roles+=['out.'+p for p in ('valid','ready','rob','flag','pdest','data')]
    roles+=['dispatch.0.'+p for p in ('valid','ready','pc','instruction','rob','flag','pdest','psrc0','psrc1')]
    roles+=['commit.0.'+p for p in ('valid','enable','pc','instruction','rob','flag','pdest')]
    roles+=['wb.'+str(part)+'.0.'+p for part in range(4) for p in ('valid','addr','data')]
    return [dict(role=role,path='',width='') for role in roles]

class Signals:
    def __init__(self, changes, byhandle, widths):
        self.series={role:[] for role in widths}
        for t,h,bits in changes:
            for role in byhandle[h]:
                require(len(bits)==widths[role] and set(bits)<=set('01'), 'unknown or invalid value: '+role)
                self.series[role].append((t,int(bits,2)))
        for role, series in self.series.items(): require(bool(series),'no values for '+role)
    def v(self,role,t):
        s=self.series[role];i=bisect_right(s,(t,1<<4096))-1
        require(i>=0,'no value for '+role+' at '+str(t));return s[i][1]
    def has(self,*roles):return all(r in self.series for r in roles)

def group_names(mapping, prefix, parts):
    groups=sorted({r.rsplit('.',1)[0] for r in mapping if r.startswith(prefix+'.')})
    for g in groups: require(all(g+'.'+p in mapping for p in parts),'incomplete mapping group: '+g)
    return groups

def analyze(sig, mapping, expected, fuop, out, expected_latency):
    v=sig.v
    required=['clock','cycle']+['in.'+p for p in ('valid','ready','op','rob','flag','pdest','src0','src1')]
    required+=['out.'+p for p in ('valid','ready','rob','flag','pdest','data')]
    require(sig.has(*required),'missing mandatory roles: '+','.join(r for r in required if not sig.has(r)))
    dispatch=group_names(mapping,'dispatch',('valid','ready','pc','instruction','rob','flag','pdest','psrc0','psrc1'))
    commit=group_names(mapping,'commit',('valid','enable','pc','instruction','rob','flag','pdest'))
    writes=group_names(mapping,'wb',('valid','addr','data'))
    require(dispatch and commit and writes,'dispatch, commit and physical writeback mappings are required')
    require({int(g.split('.')[1]) for g in writes}==set(range(4)),'map all four physical register parts')
    # Use the actual processor counter, never assume the old vadd t-2 conversion.
    samples=[t for t,c in sig.series['cycle'] if v('clock',t)==1]
    require(samples,'no high-clock processor samples')
    calibration=[dict(fst_time=t,processor_cycle=v('cycle',t),clock=v('clock',t)) for t in samples]
    require(all(b['processor_cycle']>a['processor_cycle'] for a,b in zip(calibration,calibration[1:])),
            'cycle counter is not strictly increasing at selected samples; map the active ROB counter')
    write_csv(out/'cycle_calibration.csv',calibration)
    flushes=[t for t in samples if sig.has('flush.valid','flush.rob','flush.flag','flush.level') and v('flush.valid',t)]
    def cancelled(identity,start,end):
        # Exact RobPtr.needFlush semantics: (flag xor flag) xor (index > index),
        # or the same pointer when RedirectLevel.flushItself (level bit 0) is set.
        flag,index,_=identity
        return [t for t in flushes if start<=t<=end and
                (bool(flag ^ v('flush.flag',t)) ^ (index>v('flush.rob',t)) or
                 (flag==v('flush.flag',t) and index==v('flush.rob',t) and v('flush.level',t)))]
    if flushes:
        write_csv(out/'redirects.csv',[dict(cycle=v('cycle',t),rob_flag=v('flush.flag',t),
                  rob_index=v('flush.rob',t),flush_itself=v('flush.level',t)) for t in flushes])
    def tag(group,t):return tuple(v(group+'.'+p,t) for p in ('flag','rob','pdest'))
    def fire(group,t):return v(group+'.valid',t)==v(group+'.ready',t)==1
    def one(events,what):
        require(len(events)==1,what+': expected one matching event; found '+str(len(events)));return events[0]
    targets={int(r['pc'],0):r for r in expected}
    require(len(targets)==len(expected),'duplicate target PC')
    committed=[]
    for t in samples:
        for g in commit:
            if v(g+'.enable',t) and v(g+'.valid',t) and v(g+'.pc',t) in targets:
                row=targets[v(g+'.pc',t)]
                require(v(g+'.instruction',t)==int(row['instruction'],0),'commit instruction differs from built image')
                committed.append((t,g,row))
    require(len(committed)==len(expected),'target commit count differs from expected.csv')
    require(len({r['pc'] for t,g,r in committed})==len(expected),'target PC committed more than once')
    rows=[];attempts=[]
    for tc,cg,target in committed:
        identity=tag(cg,tc)
        dispatched=[(t,g) for t in samples if t<=tc for g in dispatch
                   if fire(g,t) and tag(g,t)==identity and v(g+'.pc',t)==int(target['pc'],0)
                   and v(g+'.instruction',t)==int(target['instruction'],0)]
        surviving=[]
        for t,g in dispatched:
            flushed=cancelled(identity,t,tc)
            attempts.append(dict(name=target['name'],dispatch_cycle=v('cycle',t),rob_flag=identity[0],
                                 rob_index=identity[1],pdest=identity[2],cancelled=bool(flushed),
                                 cancel_cycle=v('cycle',flushed[0]) if flushed else ''))
            if not flushed:surviving.append((t,g))
        td,dg=one(surviving,target['name']+' surviving dispatch')
        ti=one([t for t in samples if td<=t<=tc and fire('in',t) and v('in.op',t)==fuop
                and tag('in',t)==identity],target['name']+' execution input')
        transfer=one([t for t in samples if ti<=t<=tc and fire('out',t) and tag('out',t)==identity],target['name']+' execution result transfer')
        valid_times=[t for t in samples if ti<=t<=transfer and v('out.valid',t) and tag('out',t)==identity]
        require(bool(valid_times),'output never became valid')
        to=min(valid_times)
        want=int(target['expected'],0)
        actual=v('out.data',to)
        require(actual==want,target['name']+' full 128-bit result mismatch')
        require(v('out.data',transfer)==want,target['name']+' result changed before successful transfer')
        def signed_byte(x):return x if x<128 else x-256
        a,b=v('in.src0',ti),v('in.src1',ti)
        dot=sum(signed_byte((a>>(8*k))&255)*signed_byte((b>>(8*k))&255) for k in range(8))&0xffffffff
        require(actual==dot,target['name']+' result differs from the actual source dot product')
        wt=[]
        for part in range(4):
            hit=one([(t,g) for t in samples if to<=t<=tc for g in writes if int(g.split('.')[1])==part
                     and v(g+'.valid',t) and v(g+'.addr',t)==identity[2]],target['name']+f' writeback part {part}')
            t,g=hit
            require(v(g+'.data',t)==(want>>(32*part))&0xffffffff,target['name']+' writeback data mismatch')
            wt.append(t)
        require(len(set(wt))==1,'four vector parts wrote on different cycles')
        tw=wt[0]
        require(ti<to<=transfer<=tw<tc,'unexpected execution/writeback/commit order')
        latency=v('cycle',to)-v('cycle',ti)
        if expected_latency is not None: require(latency==expected_latency,'execution latency differs from requested value')
        rows.append(dict(name=target['name'],pc=target['pc'],instruction=target['instruction'],
                         rob_flag=identity[0],rob_index=identity[1],pdest=identity[2],
                         psrc0=v(dg+'.psrc0',td),psrc1=v(dg+'.psrc1',td),
                         dispatch_cycle=v('cycle',td),issue_cycle=v('cycle',ti),result_cycle=v('cycle',to),
                         output_transfer_cycle=v('cycle',transfer),output_wait_cycles=v('cycle',transfer)-v('cycle',to),
                         writeback_cycle=v('cycle',tw),commit_cycle=v('cycle',tc),
                         execution_latency=latency,issue_to_commit=v('cycle',tc)-v('cycle',ti),
                         source0=f'0x{a:032x}',source1=f'0x{b:032x}',expected=target['expected'],
                         actual=f'0x{actual:032x}',match=True))
    rows.sort(key=lambda r:r['issue_cycle'])
    write_csv(out/'dispatch_attempts.csv',attempts)
    write_csv(out/'vdot_executions.csv',rows)
    intervals=[]
    for kind in ('CHAIN','INDEPENDENT'):
        selected=sorted([r for r in rows if r['name'].startswith('VDOT_'+kind+'_')],key=lambda r:r['name'])
        for a,b in zip(selected,selected[1:]):
            intervals.append(dict(sequence=kind,previous=a['name'],following=b['name'],
                                  issue_interval=b['issue_cycle']-a['issue_cycle']))
    write_csv(out/'issue_intervals.csv',intervals,['sequence','previous','following','issue_interval'])
    vadd=read_csv(ROOT/'results/vadd_wave_stage1/vadd_all11_summary.csv')
    comparison=[dict(operation='vadd',source='existing original FST analysis',
                     execution_latency=int(vadd[0]['result_cycle'])-int(vadd[0]['fu_input_cycle']),
                     issue_to_commit=int(vadd[0]['commit_cycle'])-int(vadd[0]['fu_input_cycle']))]
    comparison += [dict(operation=r['name'],source='current FST',execution_latency=r['execution_latency'],
                        issue_to_commit=r['issue_to_commit']) for r in rows]
    write_csv(out/'vadd_vdot_comparison.csv',comparison)
    print('VDOT_FST_PASS executions='+str(len(rows)))

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('mode',choices=('discover','analyze','vadd-regression'))
    ap.add_argument('--fst',type=Path,default=ROOT/'waveforms/vadd.fst')
    ap.add_argument('--library',type=Path,default=ROOT/'tools/fsttool'/('fstapi.dll' if os.name=='nt' else 'libfstapi.so'))
    ap.add_argument('--mapping',type=Path,help='CSV role,path,width; paths must come from this FST')
    ap.add_argument('--expected',type=Path,help='expected.csv produced by build_vdot_wave.py')
    ap.add_argument('--fuop',type=lambda x:int(x,0),help='actual VdotType operation value from this build')
    ap.add_argument('--expected-latency',type=int,default=2)
    ap.add_argument('--out',type=Path)
    args=ap.parse_args()
    out=(args.out or ROOT/'results'/('vdot_wave_analysis_'+datetime.now().strftime('%Y%m%d_%H%M%S_%f'))).resolve()
    require(not out.exists() or not any(out.iterdir()),'output directory must be new or empty')
    out.mkdir(parents=True,exist_ok=True);print('output='+str(out),flush=True)
    if args.mode=='vadd-regression':
        # The original analyzer deliberately requires its output outside this package.
        with tempfile.TemporaryDirectory(prefix='vadd_regression_') as td:
            dest=Path(td)/'analysis'
            cmd=[sys.executable,str(ROOT/'tools/analyze_vadd_fst.py'),'--fst',str(args.fst.resolve()),
                 '--library',str(args.library.resolve()),'--out',str(dest),'--no-plot']
            p=subprocess.run(cmd,capture_output=True,text=True)
            (out/'vadd_regression.txt').write_text(p.stdout+p.stderr,encoding='utf-8')
            require(p.returncode==0,'original vadd FST regression failed; inspect vadd_regression.txt')
            shutil.copytree(dest,out/'vadd')
        rows=read_csv(out/'vadd/vadd_all11_summary.csv')
        require(len(rows)==11 and all(int(r['result_cycle'])-int(r['fu_input_cycle'])==1
                and int(r['commit_cycle'])-int(r['fu_input_cycle'])==3 for r in rows),'vadd latency regression differs')
        print('VADD_REGRESSION_PASS executions=11 bytes=176 execution_latency=1 issue_to_commit=3')
        return 0
    require(args.fst.is_file(),'missing FST: '+str(args.fst))
    sys.path.insert(0,str(ROOT/'tools/fsttool'))
    import fst_scan as fst
    lib=fst.open_dll(args.library.resolve())
    with tempfile.TemporaryDirectory(prefix='vdot_fst_') as td:
        wave=Path(td)/'input.fst';shutil.copyfile(args.fst,wave)
        ctx=fst.open_fst(lib,wave)
        try: variables=[dict(handle=h,width=w,alias=a,path=p) for h,w,a,p in fst.iter_vars(lib,ctx)]
        finally:lib.fstReaderClose(ctx)
        if args.mode=='discover':
            write_csv(out/'hierarchy.csv.gz',variables)
            candidates=[r for r in variables if re.search(r'VDot|vdot|rob\.|RegFilePart|dispatch|ibuffer|decoder',r['path'])]
            write_csv(out/'candidates.csv',candidates,['handle','width','alias','path'])
            write_csv(out/'mapping_template.csv',template())
            relevant=[r['path'] for r in variables if re.search(r'VDot|vdot|\.Vdot\.',r['path'])]
            gtkw=['[*] Real paths discovered in this input FST','[dumpfile] "'+str(args.fst.resolve())+'"',
                  '-VDot candidates']+relevant
            (out/'vdot_candidates.gtkw').write_text('\n'.join(gtkw)+'\n',encoding='utf-8')
            count=sum(bool(re.search(r'VDot|vdot',r['path'])) for r in variables)
            (out/'discovery.txt').write_text(f'variables={len(variables)}\nvdot_named_signals={count}\n',encoding='ascii')
            print(f'FST_DISCOVERY_PASS variables={len(variables)} vdot_named_signals={count}')
            return 0
        require(args.mapping and args.expected and args.fuop is not None,'analyze requires --mapping, --expected and --fuop')
        rows=read_csv(args.mapping)
        require(all(r['role'] and r['path'] and r['width'] for r in rows),'mapping still has empty entries')
        mapping={r['role']:r for r in rows}
        require(len(mapping)==len(rows),'duplicate mapping role')
        paths={r['path']:r for r in variables};byhandle={};widths={}
        for role,row in mapping.items():
            require(row['path'] in paths,'signal is absent from actual FST: '+row['path'])
            signal=paths[row['path']]
            require(signal['width']==int(row['width']),'signal width differs: '+role)
            byhandle.setdefault(signal['handle'],[]).append(role);widths[role]=signal['width']
        changes=fst.extract_signals(lib,wave,byhandle)
        selected=[]
        for t,h,bits in changes:
            for role in byhandle[h]:selected.append(dict(time=t,role=role,value=bits))
        write_csv(out/'selected_changes.csv',selected)
        # GTKWave names are copied from real declarations. Nothing is inferred from instance spelling.
        gtkw=['[*] Selected signals from actual hierarchy','[dumpfile] "'+str(args.fst.resolve())+'"']
        for section in ('clock','cycle','timer','fetch.','decode.','dispatch.','in.','out.','wb.','commit.'):
            gtkw+=['- '+section]
            gtkw += [r['path'] for role,r in mapping.items() if role==section or role.startswith(section)]
        (out/'vdot.gtkw').write_text('\n'.join(gtkw)+'\n',encoding='utf-8')
        analyze(Signals(changes,byhandle,widths),mapping,read_csv(args.expected),args.fuop,out,args.expected_latency)
    return 0

if __name__=='__main__':
    try:raise SystemExit(main())
    except (ValueError,OSError,subprocess.SubprocessError,ImportError,KeyError) as error:
        print('FAIL '+str(error),file=sys.stderr);raise SystemExit(1)
