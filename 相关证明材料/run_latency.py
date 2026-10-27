#!/usr/bin/env python3

from __future__ import annotations
import argparse
from concurrent.futures import ThreadPoolExecutor
import csv
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'tools'))
from runtime_common import recorded_file, matches_recorded_source, matches_historical_source
SOURCE_PARTS = (
    ('rocket-chip/cde', ('common.sc', 'cde/src')),
    ('rocket-chip/hardfloat', ('common.sc', 'hardfloat/src/main/scala')),
    ('openLLC/openNCB', ('src/main/scala',)),
)
ANSI = re.compile(r'\x1b\[[0-?]*[ -/]*[@-~]')
BAD_OUTPUT = re.compile(r'\bABORT\b|\bFAIL(?:ED)?\b|Assertion .*failed|different at pc|AddressSanitizer|Segmentation fault', re.I)

def digest(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as f:
        for block in iter(lambda: f.read(1024*1024), b''): h.update(block)
    return h.hexdigest()

def csv_write(path, rows):
    with Path(path).open('w', newline='', encoding='utf-8-sig') as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader(); w.writerows(rows)

def programs(directory):
    d = json.loads((directory/'manifest.json').read_text(encoding='utf-8'))
    rows = [x for x in d['programs'] if x['kind'] == 'benchmark']
    if len(rows) != 16: raise ValueError('Expected 16 timing programs')
    for x in rows:
        if digest(directory/x['image']) != x['image_sha256']:
            raise ValueError('Program differs: '+x['image'])
        if not matches_recorded_source(directory/(x['name']+'.S'), x['assembly_sha256']):
            raise ValueError('Assembly differs: '+x['name'])
    return {x['name']:x for x in rows}

def decode(text, rc, row):
    text = ANSI.sub('', text)
    if rc != 0 or BAD_OUTPUT.search(text):
        raise ValueError('Simulation did not complete successfully')
    pcs = re.findall(r'Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = (0x[0-9a-fA-F]+)', text)
    if len(pcs) != 1: raise ValueError('Missing or ambiguous final PC')
    pc = int(pcs[0],16)
    offset = pc-row['symbols']['LANDING']
    if not (0 <= offset < row['landing_bytes']) or offset % 4:
        raise ValueError('Final PC is outside the valid result range')
    return pc, offset//4*row['cycle_grid']

def fit(points):
    xm = sum(x for x,y in points)/len(points)
    ym = sum(y for x,y in points)/len(points)
    ssx = sum((x-xm)**2 for x,y in points)
    b = sum((x-xm)*(y-ym) for x,y in points)/ssx
    a = ym-b*xm
    sse = sum((y-a-b*x)**2 for x,y in points)
    sst = sum((y-ym)**2 for x,y in points)
    return a,b,1-sse/sst if sst else 0,7*sum(abs(x-xm) for x,y in points)/ssx

def summarize(rows, out):
    out.mkdir(parents=True,exist_ok=True)
    medians, fits, ratios = [],[],[]
    for dep in ('independent','dependent'):
        for arm in ('vdot','baseline'):
            group = [x for x in rows if x['dependency']==dep and x['implementation']==arm]
            ns = sorted({x['iterations'] for x in group})
            if ns != [16,64,256,1024]: raise ValueError('The four iteration counts are required')
            points=[]
            for n in ns:
                ys=sorted(x['cycles_lower'] for x in group if x['iterations']==n)
                if len(ys)<3 or len(ys)%2==0: raise ValueError('Use at least three, and an odd number of repeats')
                lower=ys[len(ys)//2]
                points.append((n,lower+3.5))
                medians.append(dict(dependency=dep,implementation=arm,iterations=n,repeats=len(ys),
                                    lower_median=lower,cycle_midpoint=lower+3.5,
                                    upper_median=lower+7,repeat_range=max(ys)-min(ys)))
            a,b,r2,bound=fit(points)
            if b<=bound or r2<0.99: raise ValueError('Timing fit is not reliable')
            fits.append(dict(dependency=dep,implementation=arm,intercept_cycles=a,
                             cycles_per_iteration=b,r_squared=r2,slope_resolution_bound=bound))
        v=next(x for x in fits if x['dependency']==dep and x['implementation']=='vdot')
        b=next(x for x in fits if x['dependency']==dep and x['implementation']=='baseline')
        ratios.append(dict(dependency=dep,baseline_cycles=b['cycles_per_iteration'],
                           vdot_cycles=v['cycles_per_iteration'],speedup=b['cycles_per_iteration']/v['cycles_per_iteration'],
                           cycle_reduction_percent=100*(1-v['cycles_per_iteration']/b['cycles_per_iteration'])))
    csv_write(out/'raw_cycles.csv', rows)
    csv_write(out/'median_cycles.csv', medians)
    csv_write(out/'fit_summary.csv', fits)
    csv_write(out/'speedup.csv', ratios)
    for r in ratios:
        print('%s: baseline %.6f cycles, vdot %.6f cycles, speedup %.6fx, reduction %.4f%%' %
              (r['dependency'],r['baseline_cycles'],r['vdot_cycles'],r['speedup'],r['cycle_reduction_percent']))
    print('COMPLETE %d successful measurements; tables: %s' % (len(rows),out))

def replay(args):
    pm=programs(ROOT/'programs')
    data=json.loads((ROOT/'recorded'/'summary.json').read_text(encoding='utf-8'))
    for name,want in data['inputs'].items():
        if not matches_historical_source(ROOT/name,want): raise ValueError('Source differs from the saved measurement: '+name)
    selected=[x for x in data['runs'] if x['kind']=='benchmark']
    if len(selected)!=48 or not all(x['ok'] for x in selected): raise ValueError('Expected 48 successful saved measurements')
    rows=[]
    for r in selected:
        p=recorded_file(ROOT/'recorded'/'raw'/r['log'],r['log_sha256'])
        if digest(p)!=r['log_sha256']: raise ValueError('Saved output differs: '+p.name)
        pc,c=decode(p.read_text(encoding='utf-8',errors='replace'),0,pm[r['name']])
        if c!=r['cycles_lower'] or pc!=int(r['pc'],16): raise ValueError('Saved result cannot be reproduced: '+p.name)
        rows.append(dict(name=r['name'],dependency='dependent' if r['dependent'] else 'independent',
                         implementation=r['arm'],iterations=r['iterations'],repeat=r['repeat'],
                         final_pc=hex(pc),cycles_lower=c,cycles_upper=c+7))
    summarize(rows,args.out.resolve())
    print('CURRENT_CODE_VERIFIED=false; only saved measurements were recalculated')

def measure(args):
    work=args.work.resolve() if args.work else None
    emu=(args.emu or (work/'XiangShan/build/emu' if work else Path(''))).resolve()
    library=(args.library or (work/'NEMU/build/riscv64-nemu-interpreter-so' if work else Path(''))).resolve()
    if not emu.is_file() or not library.is_file(): raise ValueError('Specify existing --emu and --library, or a completed --work')
    if args.repeat<3 or args.repeat%2==0 or not 1<=args.workers<=8:
        raise ValueError('Use an odd repeat count >=3 and workers from 1 to 8')
    prog=(args.programs or (work/'programs' if work and (work/'programs').is_dir() else ROOT/'programs')).resolve()
    pm=programs(prog)
    out=args.out.resolve()
    if out.exists() and any(out.iterdir()): raise ValueError('Choose a new or empty --out directory')
    raw=out/'raw'; raw.mkdir(parents=True)
    jobs=[(r,k) for r in pm.values() for k in range(args.repeat)]
    def one(job):
        r,k=job
        cmd=[str(emu),'-i',str(prog/r['image']),'--diff='+str(library),
             '--ram-size=256MB','--no-squash','-s','1','-C',str(30000+r['iterations']*120)]
        p=raw/(r['name']+'_r%d.log'%k)
        with p.open('w',encoding='utf-8') as f:
            completed=subprocess.run(cmd,cwd=work or out,stdout=f,stderr=subprocess.STDOUT,timeout=args.timeout)
        pc,c=decode(p.read_text(encoding='utf-8',errors='replace'),completed.returncode,r)
        print('%s repeat %d PASS'%(r['name'],k),flush=True)
        return dict(name=r['name'],dependency='dependent' if r['dependent'] else 'independent',
                    implementation=r['arm'],iterations=r['iterations'],repeat=k,
                    final_pc=hex(pc),cycles_lower=c,cycles_upper=c+7)
    with ThreadPoolExecutor(max_workers=args.workers) as pool: rows=list(pool.map(one,jobs))
    summarize(rows,out)
    csv_write(out/'simulator_files.csv',[dict(component='XiangShan',path=str(emu),digest=digest(emu)),
                                       dict(component='NEMU',path=str(library),digest=digest(library))])

def source_paths(args):
    source=args.sources or ROOT/'sources'
    return (args.xs_source or source/'XiangShan').resolve(), (args.nemu_source or source/'NEMU').resolve()

def dependency_paths(xs):
    parts=[]
    for relative,required in SOURCE_PARTS:
        original=xs/relative
        addition=ROOT/'source_additions'/'XiangShan'/relative
        component=original if all((original/p).exists() for p in required) else addition
        if not all((component/p).exists() for p in required) or not any(component.rglob('*.scala')):
            raise ValueError('Incomplete source component: '+relative)
        parts.append((relative,component))
    return parts

def copy_source_additions(xs_copy):
    for relative,component in dependency_paths(xs_copy):
        destination=xs_copy/relative
        if component.resolve()!=destination.resolve():
            shutil.copytree(component,destination,dirs_exist_ok=True)
            print('SOURCE COMPONENT '+relative,flush=True)

def check_sources(xs,nm):
    required=[xs/'src/main/scala/xiangshan/backend/fu/FuConfig.scala',xs/'build.sc',
              xs/'difftest/Makefile',xs/'yunsuan/build.sc',xs/'rocket-chip/build.sc',
              nm/'src/isa/riscv64/instr/rvv/vcompute.h',nm/'resource/softfloat/repo/source/include/softfloat.h',
              nm/'resource/gcpt_restore/src/restore_rom_addr.h',nm/'resource/nanopb/pb.h',
              nm/'resource/LibCheckpoint/include/cpt_default_values.h']
    for p in required:
        if not p.is_file(): raise ValueError('Incomplete source tree: '+str(p))
    if 'val VdotCfg' in required[0].read_text(encoding='utf-8'):
        raise ValueError('XiangShan source already contains vdot; choose the original source or use measure')
    if 'def_EHelper(vdot)' in (nm/'src/isa/riscv64/instr/rvv/vcompute.h').read_text(encoding='utf-8'):
        raise ValueError('NEMU source already contains vdot; choose the original source or use measure')
    dependency_paths(xs)

def environment(args):
    xs,nm=source_paths(args)
    check_sources(xs,nm)
    for cmd in ('python3','gcc','g++','make','git','bash','java','mill','verilator'):
        p=shutil.which(cmd)
        if not p: raise ValueError('Missing tool: '+cmd)
        print(cmd+': '+p)
    for suffix in ('as','ld','objcopy','nm','objdump'):
        if not shutil.which(args.prefix+suffix): raise ValueError('Missing tool: '+args.prefix+suffix)
    configured=os.environ.get('CHISEL_FIRTOOL_PATH','')
    firtool=(Path(configured)/'firtool') if configured else None
    if firtool is None or not firtool.is_file():
        found=shutil.which('firtool')
        firtool=Path(found) if found else None
    if firtool is None or not os.access(firtool,os.X_OK):
        raise ValueError('Missing firtool; set CHISEL_FIRTOOL_PATH to its executable directory')
    version=subprocess.run([str(firtool),'--version'],capture_output=True,text=True,check=True)
    print('firtool: '+str(firtool)+' '+version.stdout.splitlines()[0])
    print('SOURCES READY\nXiangShan: %s\nNEMU: %s'%(xs,nm))

def build(args):
    if os.name=='nt': raise ValueError('Build in Linux or WSL2; Windows supports replay')
    if not 1 <= args.jobs <= 16: raise ValueError('Use jobs from 1 to 16')
    import resource
    _,hard=resource.getrlimit(resource.RLIMIT_STACK)
    resource.setrlimit(resource.RLIMIT_STACK,(hard,hard))
    environment(args)
    xs,nm=source_paths(args)
    work=args.work.resolve()
    if work.exists(): raise ValueError('--work must be a new directory')
    env=os.environ.copy()
    env.update(RUN_ROOT=str(work),XS_PRISTINE=str(xs),NEMU_PRISTINE=str(nm),
               SUBMISSION=str(ROOT),NOOP_HOME=str(work/'XiangShan'),NEMU_HOME=str(work/'NEMU'),
               WITH_CHISELDB='0',WITH_CONSTANTIN='0')
    def invoke(cmd,name):
        print('BUILD '+name,flush=True)
        record=work/(name+'.txt')
        with record.open('w',encoding='utf-8') as f:
            p=subprocess.run(list(map(str,cmd)),env=env,stdout=f,stderr=subprocess.STDOUT)
        if p.returncode: raise ValueError('Build stopped; see '+str(record))

    subprocess.run([sys.executable,str(ROOT/'tools/prepare_latency_sources.py')],env=env,check=True)
    for p in [work/'XiangShan/src/main/resources/espresso',work/'XiangShan/yunsuan/src/main/resources/espresso',
              work/'XiangShan/scripts/vlsi_mem_gen']+list((work/'XiangShan/scripts').rglob('*.sh')):
        if p.is_file(): p.chmod(p.stat().st_mode|0o111)
    invoke(['bash',ROOT/'rtl/xiangshan-patch/install.sh',work/'XiangShan'],'install_xiangshan')
    invoke([sys.executable,ROOT/'nemu/apply_nemu_patch.py',nm,work/'NEMU'],'install_nemu')
    from cluster.build_configuration import record_full
    record_full(work, args.java_heap, args.jobs, args.jobs)
    invoke(['make','-C',work/'NEMU','riscv64-xs-vdot_sdtrig_defconfig'],'configure_nemu')
    invoke(['make','-C',work/'NEMU','-j'+str(args.jobs),'SHARE=1'],'compile_nemu')
    invoke(['make','-C',work/'XiangShan','emu','CONFIG=KunminghuV2Config','NUM_CORES=1',
            'JVM_XMX='+args.java_heap,'JVM_XSS=32m','WITH_CHISELDB=0','WITH_CONSTANTIN=0',
            'EMU_THREADS=0','EMU_TRACE=fst','OPT_FAST=-O2 -fno-tree-slp-vectorize','-j'+str(args.jobs)],'compile_xiangshan')
    invoke([sys.executable,ROOT/'tools/gen_cluster_programs.py','--out',work/'programs','--prefix',args.prefix],'compile_programs')
    print('BUILD COMPLETE '+str(work))
    print('Next: python3 run_latency.py measure --work "'+str(work)+'" --workers 4 --repeat 3')

def main():
    ap=argparse.ArgumentParser(description='Recompute saved timings or build and measure the dot-product programs.')
    subs=ap.add_subparsers(dest='mode',required=True)
    rp=subs.add_parser('replay',help='Recompute the 48 included successful measurements')
    rp.add_argument('--out',type=Path,default=ROOT/'results/recomputed'); rp.set_defaults(action=replay)
    mp=subs.add_parser('measure',help='Run the timing programs with existing XiangShan and NEMU products')
    mp.add_argument('--work',type=Path); mp.add_argument('--emu',type=Path); mp.add_argument('--library',type=Path)
    mp.add_argument('--programs',type=Path)
    mp.add_argument('--out',type=Path,default=ROOT/'results/new_measurement')
    mp.add_argument('--workers',type=int,default=4); mp.add_argument('--repeat',type=int,default=3)
    mp.add_argument('--timeout',type=int,default=7200); mp.set_defaults(action=measure)
    for mode in ('check','build'):
        sp=subs.add_parser(mode,help='Check Linux prerequisites' if mode=='check' else 'Build copies of the original source trees in Linux')
        sp.add_argument('--sources',type=Path); sp.add_argument('--xs-source',type=Path); sp.add_argument('--nemu-source',type=Path)
        sp.add_argument('--prefix',default='riscv64-unknown-elf-')
        if mode=='build':
            sp.add_argument('--work',type=Path,required=True); sp.add_argument('--jobs',type=int,default=2)
            sp.add_argument('--java-heap',default='40G',help='Java maximum heap, for example 6G or 40G')
        sp.set_defaults(action=environment if mode=='check' else build)
    args=ap.parse_args()
    try: args.action(args)
    except (ValueError,OSError,subprocess.SubprocessError) as exc:
        print('ERROR: '+str(exc),file=sys.stderr); return 1
    return 0

if __name__=='__main__': raise SystemExit(main())
