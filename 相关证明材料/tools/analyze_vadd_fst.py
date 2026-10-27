#!/usr/bin/env python3






from __future__ import annotations
import argparse
import os
from bisect import bisect_right
import csv
import hashlib
import json
from pathlib import Path
import sys
import tempfile
import shutil

ROOT = Path(__file__).resolve().parents[1]
PC, INSTR, OP, COUNT = 0x80000050, 0x02848257, 0x40, 11
IMAGE_ID = 'ab2aa935325cd39aab187ac92ba65405ee04ba4284228bfa3e546ec23ab8810d'
FST_ID = '70628c5e6403fdf5c7bd408169da525e2ec46ddca3452430a07f20ee5b490a8f'

def require(cond, message):
    if not cond:
        raise ValueError(message)

def digest(path):
    d = hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda: f.read(1024*1024), b''):
            d.update(block)
    return d.hexdigest()

def write_csv(path, rows):
    require(bool(rows), 'empty output: '+str(path))
    with Path(path).open('w', newline='', encoding='utf-8-sig') as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)

def extract(args, meta):
    sys.path.insert(0,str(ROOT/'tools/fsttool'))
    import fst_scan as fst
    lib=fst.open_dll(args.library)
    require(digest(args.fst)==FST_ID,'FST differs from registered original')


    with tempfile.TemporaryDirectory(prefix='vadd_fst_',dir=args.scratch) as td:
        wave=str(Path(td)/'vadd.fst')
        shutil.copyfile(args.fst,wave)
        info=fst.fst_info(lib,wave)
        ctx=fst.open_fst(lib,wave)
        bypath={p:(h,w,a) for h,w,a,p in fst.iter_vars(lib,ctx)}
        lib.fstReaderClose(ctx)
        groups={}
        for key,m in meta.items():
            require(m['path'] in bypath,'missing signal: '+m['path'])
            h,w,a=bypath[m['path']]
            require(w==m['width'],'signal width changed: '+key)
            m.update(handle=h,alias=a)
            groups.setdefault(h,[]).append(key)
        changes=fst.extract_signals(lib,wave,groups)
    rows=[]
    for t,h,v in changes:
        for key in groups[h]:
            rows.append(dict(time=t,handle=h,name=key,value=v))
    write_csv(args.out/'extract_all.csv',rows)
    (args.out/'fst_info.json').write_text(json.dumps(info,indent=2)+'\n',encoding='utf8')
    return rows,info

class Timeline:
    def __init__(self,rows,meta):
        self.series={k:[] for k in meta}
        for r in rows:
            k=r['name'];v=r['value']
            require(k in meta,'unknown signal: '+k)
            require(len(v)==meta[k]['width'] and set(v)<=set('01'),'invalid binary value: '+k)
            self.series[k].append((int(r['time']),int(v,2)))
        for k,s in self.series.items():
            require(bool(s),'missing extracted signal: '+k)
            s.sort()
            require(len(s)==len({t for t,v in s}),'duplicate sample: '+k)
        self.end=max(t for s in self.series.values() for t,v in s)
    def v(self,key,t):
        s=self.series[key];i=bisect_right(s,(t,1<<256))-1
        require(i>=0,f'no value for {key} at t={t}')
        return s[i][1]
    def times(self,start=0,end=None):
        return range(start,(self.end if end is None else end)+1)
    def hits(self,predicate,start=0,end=None):
        return [t for t in self.times(start,end) if predicate(t)]

def hx(v,n=32):return f'0x{v:0{n}x}'
def one(hits,what):
    require(len(hits)==1,f'{what}: expected 1 event, found {len(hits)}: {hits[:20]}')
    return hits[0]

def analyze(tl,image,meta):
    v=tl.v
    require(digest(image)==IMAGE_ID,'image differs from recorded test')
    data=Path(image).read_bytes()
    require(int.from_bytes(data[0x50:0x54],'little')==INSTR,'vadd encoding/address mismatch')
    require(int.from_bytes(data[0x34:0x38],'little')==0x00b00993,'loop count mismatch')
    require(int.from_bytes(data[0x4c:0x50],'little')==0xc0087057,'vsetivli mismatch')
    require(tl.end>=5035,'recording stops before all target operations')


    for t in tl.times(100,tl.end):
        require(v('timer',t)==t+1 and v('cycleCnt',t)==t-2,f'cycle calibration failed at {t}')
        require(v('clock',t)==1 and v('core_reset',t)==0,f'clock/reset inconsistent at {t}')
    starts=tl.hits(lambda t:v('exu2_in_valid',t)==1 and v('exu2_in_ready',t)==1 and v('exu2_fuop',t)==OP)
    require(len(starts)==COUNT,f'target FU input count {len(starts)} != {COUNT}')
    summaries=[];events=[];bytes_out=[]
    def event(t,name,keys,note,iteration=1):
        events.append(dict(iteration=iteration,fst_time=t,processor_cycle=v('cycleCnt',t),
            top_timer=v('timer',t),event=name,
            signals='; '.join(meta[k]['path'] for k in keys),
            values='; '.join(f'{k}={hx(v(k,t),max(1,(meta[k]["width"]+3)//4))}' for k in keys),
            interpretation=note))
    previous=0
    for i,tin in enumerate(starts):
        end=(starts[i+1]-1) if i+1<len(starts) else tl.end
        off=0x100020+i*48;a=data[off:off+16];b=data[off+16:off+32]
        require(len(a)==len(b)==16,f'case {i+1} truncated')
        expected=bytes((x+y)&255 for x,y in zip(a,b));want=int.from_bytes(expected,'little')
        require(expected==data[off+32:off+48],f'case {i+1} embedded expected differs')
        require(v('exu2_src0',tin)==int.from_bytes(b,'little'),f'case {i+1} vs1 input mismatch')
        require(v('exu2_src1',tin)==int.from_bytes(a,'little'),f'case {i+1} vs2 input mismatch')
        for key,w in [('exu2_vm',1),('exu2_vsew',0),('exu2_vlmul',0),('exu2_vstart',0),('exu2_vta',0),('exu2_vma',0),('exu2_src4',16),('ei_bits_vpu_vuopIdx',0),('exu2_vecwen',1),('fu_in_valid',1)]:
            require(v(key,tin)==w,f'case {i+1} control mismatch: {key}')
        rid,flag,pd=v('exu2_robidx',tin),v('ei_bits_robIdx_flag',tin),v('exu2_pdest',tin)
        tout=one(tl.hits(lambda t:v('fu_out_valid',t)==1 and v('fo_ready',t)==1 and v('fo_bits_ctrl_robIdx_value',t)==rid and v('fo_bits_ctrl_robIdx_flag',t)==flag and v('fo_bits_ctrl_pdest',t)==pd,tin,end),f'case {i+1} FU result')
        require(v('fu_res_data',tout)==want,f'case {i+1} 128-bit result mismatch')
        require(v('eo_valid',tout)==v('eo_ready',tout)==1 and v('eo_bits_robIdx_value',tout)==rid and v('eo_bits_robIdx_flag',tout)==flag and v('eo_bits_pdest',tout)==pd and v('eo_bits_data_0',tout)==want,f'case {i+1} execution output mismatch')
        writes=[]
        for part in range(4):
            hits=[]
            for t in tl.times(tout,end):
                for port in range(5):
                    if v(f'vrf_wen_p{part}w{port}',t)==1 and v(f'wp{part}_{port}_addr',t)==pd:
                        hits.append((t,port))
            require(len(hits)==1,f'case {i+1} part {part} write count: {hits}')
            t,port=hits[0]
            require(v(f'vrf_wdata_p{part}w{port}',t)==(want>>(32*part))&0xffffffff,f'case {i+1} write data mismatch part {part}')
            writes.append((t,port))
        tw=one(sorted(set(t for t,p in writes)),f'case {i+1} simultaneous vector writes')
        commits=[]
        for slot in range(8):
            for t in tl.times(tout,end):
                k=f'c{slot}_'
                if v('rob_iscommit',t)==1 and v(k+f'io_commits_commitValid_{slot}',t)==1 and v(k+f'io_commits_robIdx_{slot}_value',t)==rid and v(k+f'io_commits_robIdx_{slot}_flag',t)==flag and v(k+f'io_commits_info_{slot}_debug_pc',t)==PC and v(k+f'io_commits_info_{slot}_debug_instr',t)==INSTR and v(k+f'io_commits_info_{slot}_basicDebug_pdest',t)==pd:
                    commits.append((t,slot))
        require(len(commits)==1,f'case {i+1} commit count: {commits}')
        tc,slot=commits[0]
        ts=one(tl.hits(lambda t:v('sbuf_valid',t)==v('sb_ready',t)==v('sb_bits_vecValid',t)==1 and v('sbuf_vaddr',t)==0x80100010,tc,end),f'case {i+1} accepted store')
        require(v('sbuf_mask',ts)==65535 and v('sbuf_data',ts)==want,f'case {i+1} store data/mask mismatch')
        require(tin<tout<=tw<tc<ts,f'case {i+1} event order')
        summaries.append(dict(iteration=i+1,fu_input_t=tin,fu_input_cycle=v('cycleCnt',tin),result_t=tout,result_cycle=v('cycleCnt',tout),write_control_t=tw,write_control_cycle=v('cycleCnt',tw),commit_t=tc,commit_cycle=v('cycleCnt',tc),store_t=ts,store_cycle=v('cycleCnt',ts),rob_flag=flag,rob_index=rid,pdest=pd,vs1_v9=hx(int.from_bytes(b,'little')),vs2_v8=hx(int.from_bytes(a,'little')),expected=hx(want),actual=hx(v('fu_res_data',tout)),match=True))
        for j in range(16):bytes_out.append(dict(iteration=i+1,element=j,bit_low=8*j,v8=a[j],v9=b[j],sum_full=a[j]+b[j],expected=expected[j],actual=(v('fu_res_data',tout)>>(8*j))&255))
        if i==0:


            ds=[]
            for dslt in range(6):
                k=f'd{dslt}_'
                for t in tl.times(0,tin):
                    if v(k+'valid',t)==v(k+'ready',t)==1 and v(k+'bits_pc',t)==PC and v(k+'bits_instr',t)==INSTR and v(k+'bits_robIdx_value',t)==rid and v(k+'bits_robIdx_flag',t)==flag and v(k+'bits_pdest',t)==pd: ds.append((t,dslt))
            require(len(ds)==1,f'execution 1 dispatch count {ds}')
            td,dslt=ds[0];dk=f'd{dslt}_'
            require(v(dk+'bits_numUops',td)==1 and v(dk+'bits_uopIdx',td)==0,'execution 1 split operation count')
            tr=one(tl.hits(lambda t:v('vfIQ_1_0_valid',t)==v('iq_ready',t)==1 and v('iq_bits_common_robIdx_value',t)==rid and v('iq_bits_common_robIdx_flag',t)==flag and v('iq_bits_common_pdest',t)==pd,td,tin),'execution 1 register read')
            r0,r1=v('vfIQ_1_0_rf0',tr),v('vfIQ_1_0_rf1',tr)
            require((r0,r1)==(v(dk+'bits_psrc_0',td),v(dk+'bits_psrc_1',td)),'source physical mapping differs')
            for part in range(4):
                require(v(f'vrf_rdata_p{part}r{r0}',tr)==int.from_bytes(b[part*4:part*4+4],'little') and v(f'vrf_rdata_p{part}r{r1}',tr)==int.from_bytes(a[part*4:part*4+4],'little'),'source register contents differ')
            tstate=one(tl.hits(lambda t: all(v(f'vrf_rdata_p{part}r{pd}',t)==(want>>(32*part))&0xffffffff for part in range(4)) and not all(v(f'vrf_rdata_p{part}r{pd}',t-1)==(want>>(32*part))&0xffffffff for part in range(4)),tw+1,tc),'destination register update')
            event(td,'重命名后的指令被 dispatch 接收',[dk+x for x in ['valid','ready','bits_pc','bits_instr','bits_robIdx_flag','bits_robIdx_value','bits_pdest','bits_psrc_0','bits_psrc_1','bits_numUops','bits_uopIdx']],'PC、完整 ROB 指针和物理寄存器映射标识第 1 次执行')
            event(tr,'向量队列向数据通路交付寄存器读请求',['vfIQ_1_0_valid','iq_ready','iq_bits_common_robIdx_flag','iq_bits_common_robIdx_value','iq_bits_common_pdest','vfIQ_1_0_rf0','vfIQ_1_0_rf1'],'valid && ready；四个 32 位分体读内容均与实际镜像一致')
            event(tin,'执行单元输入有效并可接收',['exu2_in_valid','exu2_in_ready','fu_in_valid','exu2_fuop','exu2_robidx','ei_bits_robIdx_flag','exu2_pdest','exu2_src0','exu2_src1','exu2_src4','exu2_vsew','exu2_vlmul','exu2_vm','exu2_vstart','exu2_vta','exu2_vma','ei_bits_vpu_vuopIdx'],'src0=v9，src1=v8；SEW=8，VL=16，LMUL=m1，单个内部操作')
            event(tout,'运算结果有效且执行单元输出可接收',['fu_out_valid','fo_ready','fo_bits_ctrl_robIdx_flag','fo_bits_ctrl_robIdx_value','fo_bits_ctrl_pdest','fu_res_data','eo_valid','eo_ready','eo_bits_data_0'],'16 个字节各自相加取低 8 位；输出保留同一指令编号')
            keys=[]
            for part,(t,port) in enumerate(writes):keys.extend([f'vrf_wen_p{part}w{port}',f'wp{part}_{port}_addr',f'vrf_wdata_p{part}w{port}'])
            event(tw,'四个向量寄存器写端口给出写入控制',keys,'wen=1，addr=pdest；该采样之后的上升沿更新寄存器')
            event(tstate,'物理目的寄存器内容更新',[f'vrf_rdata_p{part}r{pd}' for part in range(4)],'四分体已更新；与写控制有效时刻区分')
            ck=f'c{slot}_'
            event(tc,'ROB 提交目标 vadd',['rob_iscommit',ck+f'io_commits_commitValid_{slot}',ck+f'io_commits_robIdx_{slot}_flag',ck+f'io_commits_robIdx_{slot}_value',ck+f'io_commits_info_{slot}_debug_pc',ck+f'io_commits_info_{slot}_debug_instr',ck+f'io_commits_info_{slot}_basicDebug_pdest'],'提交信息携带同一 PC、指令编码、ROB 指针和 pdest')
            event(ts,'结果存储被 Sbuffer 接收',['sbuf_valid','sb_ready','sb_bits_vecValid','sbuf_vaddr','sbuf_mask','sbuf_data'],'valid && ready && vecValid；完整 16 字节写入 OUT')
        previous=ts
    return summaries,events,bytes_out

def plot(tl,summary,out):
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt


    s=summary[0];start=s['fu_input_t']-5;end=s['store_t']+2
    tracks=[('exu2_in_valid','exus_2.io_in_valid'),('exu2_in_ready','exus_2.io_in_ready'),('fu_out_valid','VialuFix.io_out_valid'),('fo_ready','VialuFix.io_out_ready'),('vrf_wen_p0w1','vfRegFilePart0.writePorts_1_wen'),('rob_cvalid0','rob.commitValid_0'),('sbuf_valid','sbuffer.io_in_0_valid'),('sb_ready','sbuffer.io_in_0_ready')]
    fig,axes=plt.subplots(len(tracks),1,figsize=(14,9),sharex=True)
    xs=list(range(start,end+1))
    for ax,(key,label) in zip(axes,tracks):
        ax.step(xs,[tl.v(key,t) for t in xs],where='post',color='#146b8c',linewidth=1.5)
        ax.set_yticks([0,1]);ax.set_ylim(-.25,1.25);ax.set_ylabel(label,rotation=0,ha='right',va='center',fontsize=9)
        ax.grid(axis='x',alpha=.22)
    lines=[f"PC {PC:#010x} / instruction {INSTR:#010x} / execution #1 / ROB ({s['rob_flag']},{s['rob_index']}) / pdest {s['pdest']}",f"input  t={s['fu_input_t']}  cycle={s['fu_input_cycle']}   src0(v9)={s['vs1_v9']}",f"                                                src1(v8)={s['vs2_v8']}",f"result t={s['result_t']}  cycle={s['result_cycle']}   data={s['actual']}",f"write control t={s['write_control_t']}; register update/commit t={s['commit_t']}; accepted store t={s['store_t']} to 0x80100010"]
    fig.text(.28,.015,'\n'.join(lines),va='bottom',fontfamily='monospace',fontsize=8.5)
    axes[0].set_title('Recorded full-core vadd execution #1 (high-clock samples only)\nFST t = processor cycle + 2; top timer = t + 1',loc='left',fontsize=13)
    axes[-1].set_xlabel('FST sample time t (physical frequency is unspecified)')
    axes[-1].set_xticks([start,4314,4315,4316,4317,4322,4327,4332,end])
    axes[-1].tick_params(axis='x',labelbottom=True,labelsize=8,rotation=45)
    for ax in axes:
        for t in [s['fu_input_t'],s['result_t'],s['write_control_t'],s['commit_t'],s['store_t']]:ax.axvline(t,color='#bc6c25',alpha=.28,linewidth=.8)
    fig.subplots_adjust(left=.28,right=.98,top=.91,bottom=.23,hspace=.5)
    fig.savefig(out/'vadd_exec1_timeline.svg');fig.savefig(out/'vadd_exec1_timeline.png',dpi=160)
    plt.close(fig)

def vcd(tl,meta,summary,out):
    keys=['timer','cycleCnt','exu2_in_valid','exu2_in_ready','exu2_fuop','exu2_src0','exu2_src1','exu2_robidx','ei_bits_robIdx_flag','exu2_pdest','fu_out_valid','fo_ready','fu_res_data','eo_valid','eo_ready','vrf_wen_p0w1','wp0_1_addr','vrf_wdata_p0w1','vrf_rdata_p0r53','rob_iscommit','rob_cvalid0','rob_pc0','rob_instr0','sbuf_valid','sb_ready','sbuf_vaddr','sbuf_data','sbuf_mask']
    start=summary[0]['fu_input_t']-5;end=summary[0]['store_t']+3
    lines=['$timescale 1ps $end','$comment Original FST timescale; simulator sample count, not physical period. $end','$scope module recorded_vadd $end']
    codes={k:chr(33+i) for i,k in enumerate(keys)}
    for k in keys:lines.append(f'$var wire {meta[k]["width"]} {codes[k]} {k} $end')
    lines+=['$upscope $end','$enddefinitions $end'];prev={}
    for t in range(start,end+1):
        lines.append(f'#{t}')
        for k in keys:
            n=tl.v(k,t)
            if prev.get(k)!=n:lines.append(f'b{n:0{meta[k]["width"]}b} {codes[k]}');prev[k]=n
    (out/'vadd_exec1_window.vcd').write_text('\n'.join(lines)+'\n',encoding='ascii')

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    src=ap.add_mutually_exclusive_group(required=True);src.add_argument('--fst',type=Path);src.add_argument('--cache-csv',type=Path)
    ap.add_argument('--image',type=Path,default=ROOT/'gen/cluster_programs/vadd_full_register.bin')
    ap.add_argument('--schema',type=Path,default=ROOT/'results/vadd_wave_stage1/selected_signals.json')
    ap.add_argument('--out',type=Path,help='new empty directory outside the project; default: system temporary directory')
    ap.add_argument('--library',type=Path,default=ROOT/'tools/fsttool'/('fstapi.dll' if os.name=='nt' else 'libfstapi.so'))
    ap.add_argument('--scratch',type=Path,help='ASCII directory for fstapi temporary file')
    ap.add_argument('--no-plot',action='store_true')
    args=ap.parse_args()
    if args.out is None:
        args.out=Path(tempfile.mkdtemp(prefix='vadd_analysis_'))
    else:
        args.out=args.out.resolve()
        if args.out==ROOT or ROOT in args.out.parents:
            ap.error('--out must be outside the project to preserve confirmed materials')
        if args.out.exists() and any(args.out.iterdir()):
            ap.error('--out must be new or empty')
        args.out.mkdir(parents=True,exist_ok=True)
    print('output:',args.out,flush=True)
    report=dict(ok=False,mode='original_fst' if args.fst else 'extracted_csv',failures=[])
    try:
        meta=json.loads(args.schema.read_text(encoding='utf8'))
        if args.fst:rows,info=extract(args,meta);report['fst_info']=info
        else:
            with args.cache_csv.open(encoding='utf-8-sig',newline='') as f:rows=list(csv.DictReader(f))
            report['extraction_id']=digest(args.cache_csv)
        tl=Timeline(rows,meta)
        summary,events,elements=analyze(tl,args.image,meta)
        write_csv(args.out/'vadd_all11_summary.csv',summary)
        write_csv(args.out/'vadd_exec1_events.csv',events)
        write_csv(args.out/'element_checks.csv',elements)
        write_csv(args.out/'cycle_calibration.csv',[dict(fst_time=t,top_timer=tl.v('timer',t),processor_cycle=tl.v('cycleCnt',t),clock=tl.v('clock',t),top_reset=tl.v('reset',t),core_reset=tl.v('core_reset',t)) for t in sorted(set(list(range(9))+[4198,4245,4311,4314,4315,4316,4317,4332,5017,5035,tl.end]))])
        vcd(tl,meta,summary,args.out)
        if not args.no_plot:plot(tl,summary,args.out)
        report.update(ok=True,executions_checked=len(summary),elements_checked=len(elements),exec1=summary[0],events=events,cycle_mapping=dict(fst_steps_per_cycle=1,processor_cycle='t - 2',top_timer='t + 1',verified_range=[100,tl.end]),original_fst_id=FST_ID,image_id=IMAGE_ID)
        print(f'PASS: {len(summary)} executions; {len(elements)} byte results; original FST mode={bool(args.fst)}')
    except (Exception,SystemExit) as e:
        report['failures'].append(str(e));print('FAIL:',str(e),file=sys.stderr)
    (args.out/'check_result.json').write_text(json.dumps(report,indent=2,ensure_ascii=False)+'\n',encoding='utf8')
    return 0 if report['ok'] else 1

if __name__=='__main__':sys.exit(main())
