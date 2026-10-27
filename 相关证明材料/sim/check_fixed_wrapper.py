#!/usr/bin/env python3

from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'tools'))
from runtime_common import matches_recorded_source
SV = ROOT/'rtl/xs_wrapper_generated/VDotU.sv'
MANIFEST = SV.parent/'manifest.json'
SOURCES = ['rtl/xiangshan-patch/VDotU.scala','rtl/xiangshan-patch/VDotWrapperMain.scala',
           'rtl/chisel/vdot/vdot/src/vdot/VDotUnit.scala','rtl/xiangshan-patch/apply.sh']


def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def bench(text, casefile, knobs, wrong_tail=False):
    header = re.search(r'module VDotU\s*\((.*?)\);', text, re.S)
    if not header: raise ValueError('missing VDotU module')
    ports = re.findall(r'\b(input|output)\s*(\[[^\]]+\])?\s*(\w+)\s*(?=,|$)', header[1], re.S)
    required = {'clock','reset','io_in_valid','io_out_valid','io_in_bits_data_src_0',
                'io_in_bits_data_src_1','io_out_bits_res_data','io_out_bits_ctrl_exceptionVec_2'}
    if not required <= {p[2] for p in ports}: raise ValueError('wrapper port schema changed')
    declarations = []; initial = []; connections = []
    for direction, width, name in ports:
        declarations.append(('reg ' if direction == 'input' else 'wire ') + width + ' ' + name + ';')
        connections.append('.%s(%s)'%(name,name))
        if direction == 'input':
            value = "'0"
            if name == 'reset': value = "1'b1"
            if name == 'io_out_ready' or 'validPipe_' in name: value = "1'b1"
            if name.endswith('fuOpType'): value = "9'b001100111"
            if name.endswith('vpu_vm'): value = str(knobs.get('vm',1))
            if name.endswith('vpu_vill'): value = str(knobs.get('vill',0))
            if name.endswith('vpu_vsew'): value = str(knobs.get('sew',0))
            if name.endswith('vpu_vlmul'): value = str(knobs.get('lmul',0))
            if name.endswith('vpu_vstart'): value = str(knobs.get('start',0))
            if name.endswith('vpu_vta'): value = str(knobs.get('ta',0))
            if name.endswith('vpu_vma'): value = str(knobs.get('ma',0))
            if name.endswith('vpu_vl') or name.endswith('data_src_4'): value = str(knobs.get('vl',8))
            if name.endswith('data_src_2'): value = "128'ha5a5a5a5a5a5a5a5a5a5a5a5a5a5a5a5"
            if name.endswith('data_src_3'): value = "128'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
            if name.endswith('pdest'): value = '77'
            if name.endswith('vecWen') or name.endswith('v0Wen'): value = "1'b1"
            initial.append(name+' = '+value+';')
    illegal = int(knobs.get('sew',0)!=0 or knobs.get('lmul',0)!=0 or knobs.get('vm',1)==0
                  or knobs.get('start',0)!=0 or knobs.get('vill',0)!=0)
    expected = "(expected ^ (128'h1 << 64))" if wrong_tail else 'expected'
    return '''`timescale 1ns/1ps
module test;
%s
reg [127:0] a,b,expected;
integer fd,idx,nread,total,bad,lat_bad,exc_bad;
VDotU dut(%s);
always #5 clock=~clock;
initial begin
%s
fd=$fopen("%s","r");
if(!fd) $fatal(1,"missing cases");
total=0;bad=0;lat_bad=0;exc_bad=0;
repeat(3) @(posedge clock);
@(negedge clock); reset=0;
while(!$feof(fd)) begin
 nread=$fscanf(fd,"%%d %%h %%h %%h",idx,a,b,expected);
 if(nread==4) begin
  @(negedge clock);io_in_valid=1;io_in_bits_data_src_0=a;io_in_bits_data_src_1=b;
  @(posedge clock);#1;if(io_out_valid!==0)lat_bad=lat_bad+1;
  @(negedge clock);io_in_valid=0;
  @(posedge clock);#1;
  total=total+1;
  if(io_out_valid!==1)lat_bad=lat_bad+1;
  if(io_out_bits_ctrl_exceptionVec_2!==1'b%d)exc_bad=exc_bad+1;
  if(io_out_bits_res_data!==%s)bad=bad+1;
  if(io_out_bits_ctrl_pdest!==77 || io_out_bits_ctrl_vecWen!==1 || io_out_bits_ctrl_v0Wen!==1)bad=bad+1;
  @(posedge clock);#1;if(io_out_valid!==0)lat_bad=lat_bad+1;
 end
end
$display("WRAPPER total=%%0d bad=%%0d bad_latency=%%0d bad_exception=%%0d",total,bad,lat_bad,exc_bad);
if(total==0 || bad || lat_bad || exc_bad)$fatal(1,"wrapper mismatch");
$finish;
end
endmodule
'''%('\n'.join(declarations),','.join(connections),'\n'.join(initial),casefile,illegal,expected)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--capture', action='store_true', help='Record provenance immediately after actual elaboration')
    args = ap.parse_args()
    if args.capture:
        compile_log = ROOT/'build/review_fix/emit_wrapper.log'
        if not SV.exists() or not compile_log.exists() or 'VDOT-WRAPPER-EMIT PASS' not in compile_log.read_text(errors='replace'):
            raise SystemExit('capture requires a successful elaboration log')
        MANIFEST.write_text(json.dumps({'kind':'XiangShan FU standalone elaboration',
                          'inputs':{p:sha(ROOT/p) for p in SOURCES},'sv_sha256':sha(SV)},indent=2)+'\n')
    if not MANIFEST.exists(): raise SystemExit('missing generated wrapper provenance')
    manifest=json.loads(MANIFEST.read_text())
    if not matches_recorded_source(SV,manifest['sv_sha256']) or any(not matches_recorded_source(ROOT/p,v) for p,v in manifest['inputs'].items()):
        raise SystemExit('STALE wrapper netlist: re-elaborate current Scala sources')
    compiler=shutil.which('iverilog');runner=shutil.which('vvp')
    if not compiler or not runner: raise SystemExit('SETUP-FAIL: iverilog and vvp required')
    text=SV.read_text();build=ROOT/'build/fixed_wrapper';build.mkdir(parents=True,exist_ok=True)
    results={}
    scenarios=[('vl%d_ta%d_ma%d'%(vl,ta,ma),{'vl':vl,'ta':ta,'ma':ma})
               for vl in (0,1,4,8,16) for ta,ma in ((0,0),(1,1))]
    scenarios += [('sew%d'%s,{'sew':s}) for s in (1,2,3)]
    scenarios += [('lmul%d'%m,{'lmul':m}) for m in range(1,8)]
    scenarios += [('masked',{'vm':0}),('restart',{'start':4}),('vill',{'vill':1})]
    for name,knobs in scenarios + [('wrong_tail_control',{})]:
        for group in ('pos','neg','bound','rand'):
            key=name+'_'+group;tb=build/(key+'.sv');exe=build/(key+'.vvp')
            tb.write_text(bench(text,'tests/cases_'+group+'.txt',knobs,name=='wrong_tail_control'))
            r=subprocess.run([compiler,'-g2012','-s','test','-o',str(exe),str(tb),str(SV)],capture_output=True,text=True,cwd=ROOT)
            if r.returncode: raise SystemExit(r.stderr[-2000:])
            r=subprocess.run([runner,str(exe)],capture_output=True,text=True,cwd=ROOT)
            m=re.search(r'WRAPPER total=(\d+) bad=(\d+) bad_latency=(\d+) bad_exception=(\d+)',r.stdout)
            if not m: raise SystemExit(r.stdout+r.stderr)
            total,bad,lat,exc=map(int,m.groups())
            ok=(total>0 and lat==exc==0 and ((r.returncode!=0 and bad==total) if name=='wrong_tail_control' else r.returncode==0 and bad==0))
            results[key]={'total':total,'bad':bad,'bad_latency':lat,'bad_exception':exc,'ok':ok,'knobs':knobs}
            if not ok: print(key,r.stdout)
    data={'schema':1,'inputs':{**manifest['inputs'],'rtl/xs_wrapper_generated/VDotU.sv':sha(SV)},
          'scope':'Actual XiangShan VDotU FU wrapper; no full-SoC claim.',
          'scenarios':results,'all_ok':all(x['ok'] for x in results.values())}
    data['inputs']['sim/check_fixed_wrapper.py']=sha(Path(__file__))
    data['inputs'].update({str(p.relative_to(ROOT)):sha(p) for p in sorted((ROOT/'tests').glob('cases_*.txt'))})
    out=ROOT/'results/current';out.mkdir(parents=True,exist_ok=True)
    (out/'fixed_wrapper.json').write_text(json.dumps(data,indent=2)+'\n')
    print('FIXED_WRAPPER', 'PASS' if data['all_ok'] else 'FAIL', 'groups=',len(results))
    return 0 if data['all_ok'] else 1


if __name__=='__main__':raise SystemExit(main())
