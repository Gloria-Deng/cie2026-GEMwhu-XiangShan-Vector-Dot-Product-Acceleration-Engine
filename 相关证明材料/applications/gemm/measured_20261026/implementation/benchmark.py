import argparse
import csv
import datetime
import hashlib
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
NAMES = ['scalar','vector','vdot','vdot_movx','vdot_vecacc','vdot_unroll4','vdot_vecacc_unroll']
WORD = 0xb38cad57
FLAGS = ['-march=rv64gcv','-mabi=lp64d','-nostdlib','-ffreestanding','-O2','-fno-tree-vectorize','-fno-unroll-loops','-mcmodel=medany','-Wl,--build-id=none']


def write_rows(path, rows):
    if not rows:
        raise ValueError('empty result')
    with path.open('w',encoding='utf-8',newline='') as handle:
        writer = csv.DictWriter(handle,fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def tool(prefix,name):
    candidates = [prefix+name,prefix+name+'.exe']
    for candidate in candidates:
        found = shutil.which(candidate)
        if found:
            return found
        if Path(candidate).is_file():
            return str(Path(candidate).resolve())
    raise ValueError('missing compiler tool '+prefix+name)


def command(argv, **kwargs):
    result = subprocess.run([str(x) for x in argv],capture_output=True,text=True,encoding='utf-8',errors='replace',**kwargs)
    if result.returncode:
        raise RuntimeError(result.stdout+result.stderr)
    return result.stdout


def validate_programs(directory, rows):
    if not rows:
        raise ValueError('no programs selected')
    for row in rows:
        for suffix,key in [('.elf','elf_content'),('.bin','image_content')]:
            path = directory/(row['name']+suffix)
            if not row.get(key) or hashlib.sha256(path.read_bytes()).hexdigest() != row[key]:
                raise ValueError('compiled program content changed: '+row['name']+suffix)
        if hashlib.sha256((directory/row['source']).read_bytes()).hexdigest() != row['content']:
            raise ValueError('compiled source changed: '+row['name'])


def execution_order(rows, repeats):
    for repeat in range(repeats):
        order = rows if repeat%2 == 0 else list(reversed(rows))
        for row in order:
            yield repeat, 'forward' if repeat%2 == 0 else 'reverse', row


def valid_execution(text, returncode, base):
    text = re.sub(r'\x1b\[[0-?]*[ -/]*[@-~]','',text)
    values = re.findall(r'Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = (0x[0-9a-fA-F]+)',text)
    pc = int(values[0],16) if len(values) == 1 else -1
    valid = returncode == 0 and base <= pc < base+65536*4 and (pc-base)%4 == 0 and 'Difftest enabled' in text and not re.search(r'\bABORT\b|different at pc|Segmentation fault|AddressSanitizer|HIT BAD TRAP',text,re.I)
    return bool(valid), pc


def generate(args):
    if any(size <= 0 or size % 16 for size in args.sizes):
        raise ValueError('historical benchmark sizes must be positive multiples of 16')
    if any(impl not in range(7) for impl in args.impls):
        raise ValueError('implementation ids must be 0..6')
    args.out.mkdir(parents=True,exist_ok=False)
    template = (ROOT/'baremetal/kernel.c.in').read_text(encoding='utf-8')
    template = template.replace('typedef int8_t i8;', 'typedef int8_t i8;\nextern char LANDING_BASE[];\n#define LANDING_SLOTS 65536')
    template = template.replace('static inline u64 rdinstret(void) {{ u64 x; __asm__ volatile("rdinstret %0" : "=r"(x)); return x; }}','static inline u64 rdcycle(void) {{ u64 x; __asm__ volatile("rdcycle %0" : "=r"(x)); return x; }}')
    template = template.replace('u64 t0 = rdinstret();','u64 t0 = rdcycle();').replace('u64 t1 = rdinstret();','u64 t1 = rdcycle();\n  u64 delta = t1-t0;')
    template = template.replace('if (mism == 0) OK(); else BAD();','if (mism == 0 && delta < (u64)LANDING_SLOTS*1024ULL) {{\n    void (*land)(void) = (void *)((u64)LANDING_BASE + ((delta >> 10) << 2));\n    land();\n  }} else BAD();')
    rows = []
    for size in args.sizes:
        a = [((i*37+11)%256)-128 for i in range(size*size)]
        b = [((i*53+97)%256)-128 for i in range(size*size)]
        a[:3],b[:3] = [0,127,-128],[-128,127,0]
        reference = [sum(a[i*size+k]*b[k*size+j] for k in range(size)) for i in range(size) for j in range(size)]
        array = lambda values: '{\n'+',\n'.join(','.join(str(x) for x in values[i:i+16]) for i in range(0,len(values),16))+'\n}'
        words = {'W'+str(v):f'0x{((WORD-(26<<7))|(v<<7)):08x}' for v in (4,5,6,7,26,27,28,29)}
        for impl in args.impls:
            for packed in (0,1):
                if impl == 0 and packed:
                    continue
                text = template.format(M=size,N=size,K=size,IMPL=impl,PACKED=packed,A=array(a),B=array(b),REF=array(reference),WORD=WORD,**words)
                name = f'gemm_{NAMES[impl]}'+('_packed' if packed else '')+f'_{size}x{size}x{size}'
                path = args.out/(name+'.c')
                path.write_text(text,encoding='utf-8')
                rows.append(dict(name=name,M=size,N=size,K=size,impl=impl,packed=packed,source=path.name,content=hashlib.sha256(path.read_bytes()).hexdigest()))
    write_rows(args.out/'programs.csv',rows)
    print(f'GEMM_GENERATED programs={len(rows)}')


def build(args):
    rows = list(csv.DictReader((args.programs/'programs.csv').open(encoding='utf-8',newline='')))
    gcc,objcopy,nm = (tool(args.prefix,name) for name in ['gcc','objcopy','nm'])
    os.environ['PATH'] = str(Path(gcc).parent)+os.pathsep+os.environ.get('PATH','')
    with tempfile.TemporaryDirectory(prefix='vdot_gemm_compile_') as temporary:
        work = Path(temporary)
        for resource in ['start.S','landing.S','link_landing.ld']:
            shutil.copyfile(ROOT/'baremetal'/resource,work/resource)
        for row in rows:
            source = args.programs/row['source']
            if hashlib.sha256(source.read_bytes()).hexdigest() != row['content']:
                raise ValueError('source changed: '+row['name'])
            local_source = work/source.name
            shutil.copyfile(source,local_source)
            elf = work/(row['name']+'.elf')
            command([gcc,*FLAGS,'-T',work/'link_landing.ld','-e','_start','-o',elf,work/'start.S',work/'landing.S',local_source])
            command([objcopy,'-O','binary',elf,elf.with_suffix('.bin')])
            symbols = command([nm,'-n',elf])
            for key in ['LANDING_BASE','BAD']:
                match = re.search(r'^([0-9a-fA-F]+)\s+\w\s+'+key+r'$',symbols,re.M)
                if not match:
                    raise ValueError('missing symbol '+key)
                row[key] = '0x'+match.group(1)
            for suffix in ['.elf','.bin']:
                shutil.copyfile(elf.with_suffix(suffix),args.programs/(row['name']+suffix))
            row['elf_content'] = hashlib.sha256(elf.read_bytes()).hexdigest()
            row['image_content'] = hashlib.sha256(elf.with_suffix('.bin').read_bytes()).hexdigest()
    write_rows(args.programs/'compiled.csv',rows)
    print(f'GEMM_COMPILED programs={len(rows)}')


def run(args):
    if args.repeats <= 0 or args.max_cycles <= 0 or args.timeout <= 0:
        raise ValueError('limits must be positive')
    args.out.mkdir(parents=True,exist_ok=False)
    rows = list(csv.DictReader((args.programs/'compiled.csv').open(encoding='utf-8',newline='')))
    if args.names:
        names = set(args.names)
        rows = [row for row in rows if row['name'] in names]
        if {row['name'] for row in rows} != names:
            raise ValueError('unknown program name')
    validate_programs(args.programs,rows)
    results = []
    for repeat,sequence,row in execution_order(rows,args.repeats):
            validate_programs(args.programs,[row])
            path = args.out/(row['name']+f'.r{repeat}.txt')
            argv = [args.emu,'-i',args.programs/(row['name']+'.bin'),'--diff='+str(args.library.resolve()),'--ram-size=256MB','--no-squash','-s','1','-C',str(args.max_cycles)]
            started = datetime.datetime.now(datetime.timezone.utc).isoformat()
            try:
                process = subprocess.run([str(x) for x in argv],capture_output=True,text=True,encoding='utf-8',errors='replace',timeout=args.timeout)
                text = process.stdout+process.stderr
                returncode = process.returncode
            except subprocess.TimeoutExpired as exc:
                output = exc.stdout or ''
                errors = exc.stderr or ''
                if isinstance(output,bytes):
                    output = output.decode('utf-8',errors='replace')
                if isinstance(errors,bytes):
                    errors = errors.decode('utf-8',errors='replace')
                text = output+errors+'\nTIME_LIMIT_EXCEEDED '+str(args.timeout)
                returncode = -1
            path.write_text(text,encoding='utf-8')
            base = int(row['LANDING_BASE'],16)
            valid,pc = valid_execution(text,returncode,base)
            results.append(dict(name=row['name'],M=row['M'],N=row['N'],K=row['K'],impl=row['impl'],packed=row['packed'],repeat=repeat,sequence=sequence,order=len(results)+1,started_utc=started,status='PASS' if valid else 'FAIL',cycles_window=((pc-base)//4)*1024 if valid else '',cycle_grid=1024,terminal_pc=hex(pc) if pc>=0 else '',max_cycles=args.max_cycles,image_content=row['image_content'],elf_content=row['elf_content'],output=path.name))
            write_rows(args.out/'measurements.csv',results)
            print(row['name'],repeat,results[-1]['status'],flush=True)
            if not valid:
                raise RuntimeError('execution failed; parameters were kept unchanged')
    print(f'GEMM_MEASURED samples={len(results)}')


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_subparsers(dest='mode',required=True)
    gen = modes.add_parser('generate')
    gen.add_argument('--out',type=Path,required=True)
    gen.add_argument('--sizes',type=int,nargs='+',default=[16,32])
    gen.add_argument('--impls',type=int,nargs='+',default=list(range(7)))
    compile_parser = modes.add_parser('build')
    compile_parser.add_argument('--programs',type=Path,required=True)
    compile_parser.add_argument('--prefix',default='riscv64-unknown-elf-')
    runner = modes.add_parser('run')
    runner.add_argument('--programs',type=Path,required=True)
    runner.add_argument('--emu',type=Path,required=True)
    runner.add_argument('--library',type=Path,required=True)
    runner.add_argument('--out',type=Path,required=True)
    runner.add_argument('--names',nargs='+')
    runner.add_argument('--repeats',type=int,default=3)
    runner.add_argument('--max-cycles',type=int,required=True)
    runner.add_argument('--timeout',type=float,required=True)
    args = parser.parse_args()
    {'generate':generate,'build':build,'run':run}[args.mode](args)


if __name__ == '__main__':
    main()
