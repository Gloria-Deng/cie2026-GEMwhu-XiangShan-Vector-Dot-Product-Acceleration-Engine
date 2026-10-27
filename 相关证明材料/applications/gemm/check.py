import argparse
import csv
import gzip
import hashlib
import os
import re
import shutil
import statistics
import subprocess
import sys
import tempfile
from pathlib import Path

import benchmark

ROOT = Path(__file__).resolve().parent


def read_rows(path):
    with path.open(encoding='utf-8-sig',newline='') as stream:
        return list(csv.DictReader(stream))


def verify_recorded(out):
    measured = ROOT/'measured_20261021'
    inventory = read_rows(ROOT/'imported_files.csv')
    for item in inventory:
        path = ROOT/item['path']
        data = path.read_bytes()
        if len(data) != int(item['bytes']) or hashlib.sha256(data).hexdigest() != item['content_sha256']:
            raise ValueError('imported file changed: '+item['path'])
    rows = read_rows(measured/'gemm_cycles_summary.csv')
    groups = {}
    passed = failed = 0
    for item in rows:
        original = gzip.decompress((measured/item['log']).read_bytes())
        if hashlib.sha256(original).hexdigest() != item['log_sha256']:
            raise ValueError('raw output content changed: '+item['name'])
        source = measured/'src'/item['M']/(item['name']+'.c')
        if hashlib.sha256(source.read_bytes()).hexdigest() != item['source_sha256']:
            raise ValueError('measured source changed: '+item['name'])
        if item['status'] == 'PASS':
            text = original.decode('utf-8',errors='replace')
            text = re.sub(r'\x1b\[[0-?]*[ -/]*[@-~]','',text)
            pc = int(item['terminal_pc'],0)
            base = int(item['landing_base'],0)
            terminals = re.findall(r'Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = (0x[0-9a-fA-F]+)',text)
            if len(terminals) != 1 or int(terminals[0],0) != pc or 'Difftest enabled' not in text:
                raise ValueError('raw execution does not match the recorded result: '+item['name'])
            if not base <= pc < base+65536*4 or (pc-base)%4:
                raise ValueError('invalid terminal position: '+item['name'])
            value = ((pc-base)//4)*int(item['cycle_grid'])
            if value != int(item['cycles_window']):
                raise ValueError('cycle decoding mismatch: '+item['name'])
            key = tuple(int(item[x]) for x in ['M','impl','packed'])
            groups.setdefault(key,[]).append(value)
            passed += 1
        elif item['status'] == 'FAIL':
            failed += 1
        else:
            raise ValueError('unknown recorded status')
    if (len(rows),passed,failed,len(groups)) != (59,52,7,26):
        raise ValueError('incomplete measured package')
    calculated = []
    for item in read_rows(measured/'gemm_cycles_speedup.csv'):
        key = tuple(int(item[x]) for x in ['M','impl','packed'])
        values = groups[key]
        mid = statistics.median(values)
        reference = statistics.median(groups[(key[0],1,key[2])])
        expected = [len(values),min(values),mid,max(values),reference]
        reported = [float(item[k]) for k in ['runs','cycles_min','cycles_median','cycles_max','baseline_vector_cycles']]
        if expected != reported or abs(float(item['vector_over_variant'])-reference/mid) > 0.000051:
            raise ValueError('derived table does not match raw measurements: '+str(key))
        calculated.append(dict(size=key[0],implementation=benchmark.NAMES[key[1]],packed=key[2],samples=len(values),minimum=min(values),median=mid,maximum=max(values),standard_rvv=reference,standard_over_implementation=round(reference/mid,6)))
    benchmark.write_rows(out/'recomputed_cycles.csv',calculated)
    return f'files={len(inventory)} attempts=59 successful=52 unsuccessful=7 implementations=26'


def executable(name, supplied=None):
    if supplied:
        if Path(supplied).is_file():
            return str(Path(supplied).resolve())
        found = shutil.which(supplied)
        if found:
            return found
        raise ValueError('missing tool '+supplied)
    found = shutil.which(name)
    if found:
        return found
    for base in ['E:/msys64/ucrt64/bin','C:/msys64/ucrt64/bin']:
        candidate = Path(base)/(name+'.exe')
        if candidate.is_file():
            return str(candidate)
    raise ValueError('missing tool '+name)


def reference_library(supplied):
    if supplied:
        if supplied.is_file():
            return supplied.resolve()
        raise ValueError('missing reference library '+str(supplied))
    candidates = []
    if os.environ.get('VDOT_NEMU_LIBRARY'):
        candidates.append(Path(os.environ['VDOT_NEMU_LIBRARY']))
    for suffix in ['','exe','dll','so']:
        name = 'riscv64-nemu-interpreter-so'+('.'+suffix if suffix else '')
        candidates.append(ROOT.parents[1]/'sources/NEMU/build'/name)
    if os.name == 'nt':
        candidates.append(ROOT.parents[4]/'RSIC-V香山/工作区/收口构建_20261019/nemu-vdot/build/riscv64-nemu-interpreter-so.exe')
    for path in candidates:
        if path.is_file():
            return path.resolve()
    raise ValueError('reference library unavailable; specify --library or VDOT_NEMU_LIBRARY')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--cc')
    parser.add_argument('--prefix')
    parser.add_argument('--library',type=Path)
    parser.add_argument('--layout',type=Path,default=ROOT/'baremetal/cosim_layout.h')
    args = parser.parse_args()
    requested = args.out.resolve()
    requested.mkdir(parents=True,exist_ok=False)
    temporary = tempfile.TemporaryDirectory(prefix='vdot_gemm_')
    scratch = Path(temporary.name)
    args.out = scratch/'output'
    args.out.mkdir()
    package = scratch/'package'
    package.mkdir()
    for folder in ['include','src','baremetal']:
        shutil.copytree(ROOT/folder,package/folder)
    for name in ['benchmark.py','execute_image.py']:
        shutil.copyfile(ROOT/name,package/name)
    records = []

    def run(name,argv):
        argv = [str(x) for x in argv]
        argv = [str(package)+x[len(str(ROOT)):] if x.startswith(str(ROOT)) else x for x in argv]
        result = subprocess.run(argv,capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=300)
        text = result.stdout+result.stderr
        (args.out/(name+'.txt')).write_text(text,encoding='utf-8')
        if result.returncode:
            raise RuntimeError(name+' failed '+str(result.returncode)+': '+text[-2000:])
        return text

    try:
        detail = verify_recorded(args.out)
        records.append(dict(check='recorded_measurements',status='PASS',detail=detail))
        cc = executable('gcc',args.cc)
        gcc = executable('riscv64-unknown-elf-gcc',args.prefix+'gcc' if args.prefix else None)
        args.library = reference_library(args.library)
        os.environ['PATH'] = os.pathsep.join([str(Path(cc).parent),str(Path(gcc).parent),os.environ.get('PATH','')])
        prefix = args.prefix or gcc[:-len('gcc.exe' if gcc.endswith('.exe') else 'gcc')]
        suffix = '.exe' if os.name == 'nt' else ''
        for source,name in [('selftest.c','api_test'),('demo.c','application')]:
            target = args.out/(name+suffix)
            run(name+'_compile',[cc,'-std=c11','-O2','-fno-tree-vectorize','-Wall','-Wextra','-I',ROOT/'include',ROOT/'src/vdot_gemm.c',ROOT/'src'/source,'-o',target])
            text = run(name,[target])
            marker = 'GEMM_API_PASS' if source == 'selftest.c' else 'GEMM_DEMO_PASS'
            if marker not in text or (source == 'demo.c' and 'backend=C_REFERENCE' not in text):
                raise ValueError('missing application result')
            records.append(dict(check=name,status='PASS',detail=text.splitlines()[0]))
        programs = args.out/'programs'
        run('generate',[sys.executable,'-B',ROOT/'benchmark.py','generate','--sizes','16','32','--out',programs])
        run('build',[sys.executable,'-B',ROOT/'benchmark.py','build','--programs',programs,'--prefix',prefix])
        records.append(dict(check='measured_implementation_build',status='PASS',detail='26 programs; seven implementations; two sizes'))
        compiled = read_rows(programs/'compiled.csv')
        benchmark.validate_programs(programs,compiled)
        mutation = args.out/'changed_program'
        mutation.mkdir()
        item = compiled[0]
        for file in [item['source'],item['name']+'.elf',item['name']+'.bin']:
            shutil.copyfile(programs/file,mutation/file)
        binary = mutation/(item['name']+'.bin')
        altered = bytearray(binary.read_bytes())
        altered[0] ^= 1
        binary.write_bytes(altered)
        try:
            benchmark.validate_programs(mutation,[item])
        except ValueError:
            pass
        else:
            raise ValueError('changed program was accepted')
        sample = next(row for row in read_rows(ROOT/'measured_20261021/gemm_cycles_summary.csv') if row['status']=='PASS')
        output = gzip.decompress((ROOT/'measured_20261021'/sample['log']).read_bytes()).decode('utf-8',errors='replace')
        base = int(sample['landing_base'],0)
        if not benchmark.valid_execution(output,0,base)[0] or benchmark.valid_execution(output.replace('Difftest enabled','disabled'),0,base)[0]:
            raise ValueError('differential execution status was not enforced')
        sample_rows = [{'name':name} for name in ['first','second','third']]
        order = [(repeat,sequence,row['name']) for repeat,sequence,row in benchmark.execution_order(sample_rows,3)]
        if [row[2] for row in order] != ['first','second','third','third','second','first','first','second','third']:
            raise ValueError('execution order did not alternate')
        benchmark.write_rows(args.out/'order_check.csv',[dict(repeat=r,sequence=s,name=n) for r,s,n in order])
        records.append(dict(check='execution_controls',status='PASS',detail='changed image rejected; missing differential mode rejected; forward/reverse order checked'))
        api_elf = args.out/'api_riscv.elf'
        run('api_riscv_compile',[gcc,*benchmark.FLAGS,'-DVDOT_GEMM_ASM','-I',ROOT/'include','-T',ROOT/'baremetal/link_landing.ld','-e','_start','-o',api_elf,ROOT/'baremetal/start.S',ROOT/'src/vdot_gemm.c',ROOT/'src/demo_baremetal.c'])
        objcopy,nm,objdump = (benchmark.tool(prefix,x) for x in ['objcopy','nm','objdump'])
        run('api_image',[objcopy,'-O','binary',api_elf,api_elf.with_suffix('.bin')])
        disassembly = run('api_disassembly',[objdump,'-d',api_elf])
        wanted = [0xb38cad57,0xb38ca257,0xb38ca2d7,0xb38ca357,0xb38ca3d7]
        if any(f'{word:08x}' not in disassembly.lower() for word in wanted):
            raise ValueError('custom instruction destinations are missing from the compiled program')
        records.append(dict(check='custom_instruction_application_build',status='PASS',detail='movx and four-column methods; nonmultiple dimensions 3x5x13'))
        if args.library:
            comparisons = 0
            for m,n,k in [(3,5,13),(1,4,1),(1,4,8),(1,8,16),(1,3,7),(2,5,0)]:
                label = f'api_{m}x{n}x{k}'
                elf = api_elf if (m,n,k)==(3,5,13) else args.out/(label+'.elf')
                if elf != api_elf:
                    run(label+'_compile',[gcc,*benchmark.FLAGS,'-DVDOT_GEMM_ASM',f'-DVDOT_APP_M={m}',f'-DVDOT_APP_N={n}',f'-DVDOT_APP_K={k}','-I',ROOT/'include','-T',ROOT/'baremetal/link_landing.ld','-e','_start','-o',elf,ROOT/'baremetal/start.S',ROOT/'src/vdot_gemm.c',ROOT/'src/demo_baremetal.c'])
                    run(label+'_image',[objcopy,'-O','binary',elf,elf.with_suffix('.bin')])
                symbols = run(label+'_symbols',[nm,'-n',elf])
                terminals = {name:'0x'+re.search(r'^([0-9a-fA-F]+)\s+\w\s+'+name+r'$',symbols,re.M).group(1) for name in ['OK','BAD']}
                text = run(label+'_nemu',[sys.executable,'-B',ROOT/'execute_image.py','--library',args.library,'--layout',args.layout,'--image',elf.with_suffix('.bin'),'--ok',terminals['OK'],'--bad',terminals['BAD']])
                match = re.search(r'^GPR (.+)$',text,re.M)
                expected = [m,n,k,2,m*n*2,1,0,1]
                if 'IMAGE_PASS' not in text or not match or [int(x,16) for x in match.group(1).split()] != expected:
                    raise ValueError('reference execution did not complete both methods for '+label)
                comparisons += m*n*2
            records.append(dict(check='custom_instruction_application_nemu',status='PASS',detail=f'cases=6 methods=2 output_comparisons={comparisons} mismatches=0; reference execution only'))
    except Exception as exc:
        records.append(dict(check='delivery',status='FAIL',detail=str(exc)))
        benchmark.write_rows(args.out/'checks.csv',records)
        shutil.copytree(args.out,requested,dirs_exist_ok=True)
        temporary.cleanup()
        print(str(exc),file=sys.stderr)
        return 1
    benchmark.write_rows(args.out/'checks.csv',records)
    shutil.copytree(args.out,requested,dirs_exist_ok=True)
    temporary.cleanup()
    print('GEMM_DELIVERY_PASS',detail)
    for item in records:
        print(item['check'],item['status'],item['detail'])
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
