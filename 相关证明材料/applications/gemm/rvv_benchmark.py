"""Standard RVV and unchanged custom-vdot GEMM comparison (Linux/WSL)."""
import argparse
import csv
import hashlib
from pathlib import Path
import re
import statistics
import subprocess
import sys

import api_benchmark as api
import benchmark

ROOT = Path(__file__).resolve().parent
METHODS = ('rvv_dot', 'rvv_outer', 'vdot_movx', 'vdot_unroll4')
CASES = api.CASES


def implementation(method):
    old_header = (ROOT/'include/vdot_gemm.h').read_text(encoding='utf-8')
    old = (ROOT/'src/vdot_gemm.c').read_text(encoding='utf-8').replace('#include "vdot_gemm.h"',old_header)
    if method >= 2:
        return '#define VDOT_GEMM_ASM 1\n' + old
    new_header = (ROOT/'include/rvv_gemm.h').read_text(encoding='utf-8').replace('#include "vdot_gemm.h"','')
    new = (ROOT/'src/rvv_gemm.c').read_text(encoding='utf-8').replace('#include "rvv_gemm.h"',new_header)
    return '#define RVV_GEMM_ASM 1\n' + old + '\n' + new


def pack_call(method):
    return (f'rvv_gemm_pack_b(b,N,K,packed,sizeof packed,(enum rvv_gemm_method){method})'
            if method < 2 else 'vdot_gemm_pack_b(b,N,K,packed,sizeof packed)')


def compute_call(method):
    return (f'rvv_gemm_packed(a,packed,c,M,N,K,(enum rvv_gemm_method){method})'
            if method < 2 else f'vdot_gemm_packed(a,packed,c,M,N,K,(enum vdot_gemm_method){method-2})')


def generate(args):
    # Resolve every compiler tool before creating an output directory.
    for name in ('gcc','objcopy','nm','objdump'): benchmark.tool(args.prefix,name)
    args.out.mkdir(parents=True,exist_ok=False)
    rows=[]
    for m,n,k in CASES:
        a=[((i*17+11)%256)-128 for i in range(m*k)]
        b=[((i*13+97)%256)-128 for i in range(k*n)]
        expected=[sum(a[i*k+q]*b[q*n+j] for q in range(k)) for i in range(m) for j in range(n)]
        values=lambda data:'{'+','.join(map(str,data))+'}'
        for method,label in enumerate(METHODS):
            for scope in ('compute','pack_compute'):
                name=f't4_{m}x{n}x{k}_{label}_{scope}'
                pack=pack_call(method)
                source=implementation(method)+f'''
enum {{ M={m},N={n},K={k},STRIDE=(K+7)&~7 }};
static const int8_t a[M*K]={values(a)};
static const int8_t b[K*N]={values(b)};
static const int32_t expected[M*N]={values(expected)};
static int8_t packed[N*STRIDE];
static int32_t c[M*N];
extern char LANDING_BASE[];
__attribute__((noinline,used)) void BAD(void) {{ for (;;) __asm__ volatile(""); }}
static inline uint64_t ticks(void) {{ uint64_t v; __asm__ volatile("fence rw,rw\\n\\trdcycle %0\\n\\tfence rw,rw" : "=r"(v) : : "memory"); return v; }}
void run(void) {{
    {f'if ({pack}) BAD();' if scope=='compute' else ''}
    uint64_t start=ticks();
    {f'if ({pack}) BAD();' if scope=='pack_compute' else ''}
    int status={compute_call(method)};
    uint64_t delta=ticks()-start;
    if (status || delta >= 65536ULL*8) BAD();
    for (size_t i=0;i<M*N;i++) if (c[i]!=expected[i]) BAD();
    ((void (*)(void))(LANDING_BASE+(delta/8)*4))();
}}
'''
                path=args.out/(name+'.c'); path.write_text(source,encoding='utf-8')
                rows.append(dict(name=name,M=m,N=n,K=k,impl=method,packed=1,scope=scope,
                                 source=path.name,content=api.digest(path),cycle_grid=8,max_cycles=500000))
    benchmark.write_rows(args.out/'programs.csv',rows)
    benchmark.build(argparse.Namespace(programs=args.out,prefix=args.prefix))
    for row in api.read_rows(args.out/'compiled.csv'):
        text=benchmark.command([benchmark.tool(args.prefix,'objdump'),'-d',args.out/(row['name']+'.elf')])
        (args.out/(row['name']+'.asm')).write_text(text,encoding='utf-8')
        method=int(row['impl'])
        required=('vwmul.vv','vwredsum.vs') if method==0 else ('vsext.vf2','vwmacc.vx') if method==1 else ('b38cad57' if method==2 else 'b38ca257',)
        if any(item not in text for item in (*required,'rdcycle')): raise ValueError('missing instructions: '+row['name'])
        if method<2 and re.search(r'\bb38ca[0-9a-f]{3}\b',text): raise ValueError('custom vdot in standard RVV image')
    validation=args.out/'validation'; validation.mkdir()
    path=validation/'rvv_validation.c'
    source=implementation(0)+(ROOT/'baremetal/rvv_validation.c').read_text(encoding='utf-8').replace('#include "rvv_gemm.h"','')
    path.write_text(source,encoding='utf-8')
    benchmark.write_rows(validation/'programs.csv',[dict(name='rvv_validation',source=path.name,content=api.digest(path))])
    benchmark.build(argparse.Namespace(programs=validation,prefix=args.prefix))
    print('T4_PROGRAMS_PASS timed=24 validation=1')


def functional(args):
    if not args.library.is_file() or not args.layout.is_file(): raise ValueError('NEMU library/layout unavailable')
    args.out.mkdir(parents=True,exist_ok=False)
    # Build the existing application runner, whose instruction bound is configurable.
    runner=args.out/'reference_runner'
    local_source=args.out/'reference_runner.c'
    source=(ROOT/'baremetal/reference_runner.c').read_text(encoding='utf-8')
    # Timed images finish at one of 65536 aligned addresses, after checking C.
    source=source.replace('pc == ok','(pc >= ok && pc < ok + 65536ULL*4 && (pc-ok)%4 == 0)')
    local_source.write_text(source,encoding='utf-8')
    (args.out/'cosim_layout.h').write_bytes(args.layout.read_bytes())
    benchmark.command([args.cc,'-O2','-o',runner,local_source,'-ldl'])
    records=[]
    for directory in (args.programs,args.programs/'validation'):
        rows=api.read_rows(directory/'compiled.csv'); benchmark.validate_programs(directory,rows)
        for row in rows:
            base=int(row['LANDING_BASE'],0)
            command=[str(runner.resolve()),str(args.library.resolve()),str((directory/(row['name']+'.bin')).resolve()),hex(base),row['BAD'],'100000000']
            result=subprocess.run(command,capture_output=True,text=True,errors='replace',timeout=300)
            output=result.stdout+result.stderr; output_path=args.out/(row['name']+'.txt'); output_path.write_text(output,encoding='utf-8')
            valid=result.returncode==0 and 'IMAGE_PASS' in output
            records.append(dict(name=row['name'],status='PASS' if valid else 'FAIL',exit_code=result.returncode,output=output_path.name,output_content=api.digest(output_path)))
            benchmark.write_rows(args.out/'checks.csv',records)
            if not valid: raise ValueError('NEMU execution failed: '+row['name'])
    print('T4_NEMU_PASS timed=24 validation=1 shapes=1516+6 methods=2 full_register=3')


def analyze(results,out,repeat,programs):
    if repeat < 3: raise ValueError('at least three repetitions are required')
    rows=api.read_rows(results/'measurements.csv')
    compiled=api.read_rows(programs/'compiled.csv')
    benchmark.validate_programs(programs,compiled)
    by_name={r['name']:r for r in compiled}
    expected_names={f't4_{m}x{n}x{k}_{label}_{scope}' for m,n,k in CASES for label in METHODS for scope in ('compute','pack_compute')}
    if set(by_name)!=expected_names or {r['name'] for r in rows}!=expected_names: raise ValueError('unexpected program set')
    if len(rows)!=24*repeat: raise ValueError('expected exactly 24*repeat measurements')
    out.mkdir(parents=True,exist_ok=False)
    summary=[]
    for m,n,k in CASES:
        for method,label in enumerate(METHODS):
            for scope in ('compute','pack_compute'):
                selected=[r for r in rows if (int(r['M']),int(r['N']),int(r['K']),int(r['method']),r['scope'])==(m,n,k,method,scope)]
                if len(selected)!=repeat or {int(r['repeat']) for r in selected}!=set(range(repeat)): raise ValueError('missing or duplicate repetition')
                values=[]
                for row in selected:
                    path=results/row['output']
                    if api.digest(path)!=row['output_content']: raise ValueError('execution output changed')
                    # Terminal PC is re-read from actual simulator output, rather than trusted from the CSV.
                    text=path.read_text(encoding='utf-8',errors='replace')
                    original=by_name[row['name']]
                    if (original['M'],original['N'],original['K'],original['impl'],original['scope'])!=(row['M'],row['N'],row['K'],row['method'],row['scope']): raise ValueError('program identity mismatch')
                    if original['image_content']!=row['image_content']: raise ValueError('image mismatch')
                    pc=int(row['terminal_pc'],0); cycles=int(row['cycles_lower']); base=int(original['LANDING_BASE'],0)
                    valid,decoded=benchmark.valid_execution(text,int(row['exit_code']),base)
                    if row['status']!='PASS' or not valid or decoded!=pc or cycles!=((pc-base)//4)*8 or int(row['cycle_grid'])!=8: raise ValueError('invalid differential execution')
                    values.append(cycles)
                summary.append(dict(M=m,N=n,K=k,method=method,implementation=label,scope=scope,samples=len(values),minimum=min(values),median=statistics.median(values),maximum=max(values),cycle_grid=8))
    benchmark.write_rows(out/'summary.csv',summary)
    comparison=[]
    for m,n,k in CASES:
        for scope in ('compute','pack_compute'):
            values={r['method']:r['median'] for r in summary if (r['M'],r['N'],r['K'],r['scope'])==(m,n,k,scope)}
            best_rvv=min(values[0],values[1]); best_vdot=min(values[2],values[3])
            if best_vdot<=0: raise ValueError('zero cycle count')
            comparison.append(dict(M=m,N=n,K=k,scope=scope,rvv_dot=values[0],rvv_outer=values[1],vdot_movx=values[2],vdot_unroll4=values[3],best_rvv_over_best_vdot=best_rvv/best_vdot))
    benchmark.write_rows(out/'comparison.csv',comparison)
    print('T4_ANALYSIS_PASS groups=24 comparisons=6')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    modes=parser.add_subparsers(dest='mode',required=True)
    gen=modes.add_parser('generate'); gen.add_argument('--out',type=Path,required=True); gen.add_argument('--prefix',default='riscv64-unknown-elf-')
    fun=modes.add_parser('functional')
    fun.add_argument('--programs',type=Path,required=True); fun.add_argument('--out',type=Path,required=True)
    fun.add_argument('--library',type=Path,required=True); fun.add_argument('--layout',type=Path,required=True); fun.add_argument('--cc',default='gcc')
    exe=modes.add_parser('execute')
    for name in ('programs','out','emu','library'): exe.add_argument('--'+name,type=Path,required=True)
    exe.add_argument('--repeat',type=int,default=3); exe.add_argument('--workers',type=int,default=16); exe.add_argument('--seconds-limit',type=float,default=7200)
    check=modes.add_parser('analyze'); check.add_argument('--results',type=Path,required=True); check.add_argument('--programs',type=Path,required=True); check.add_argument('--out',type=Path,required=True); check.add_argument('--repeat',type=int,default=3)
    args=parser.parse_args()
    try:
        if args.mode=='execute':
            api.analyze=lambda results,out,repeat: analyze(results,out,repeat,args.programs)
            api.execute(args)
        elif args.mode=='analyze': analyze(args.results,args.out,args.repeat,args.programs)
        else: globals()[args.mode](args)
    except (ValueError,OSError,RuntimeError,subprocess.SubprocessError) as error:
        print('T4_FAIL '+str(error),file=sys.stderr); return 1
    return 0


if __name__=='__main__': raise SystemExit(main())
