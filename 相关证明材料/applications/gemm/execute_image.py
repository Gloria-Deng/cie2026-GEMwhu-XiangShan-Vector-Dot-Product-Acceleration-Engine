import argparse
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--library',type=Path,required=True)
    parser.add_argument('--layout',type=Path,required=True)
    parser.add_argument('--image',type=Path,required=True)
    parser.add_argument('--ok',type=lambda x:int(x,0),required=True)
    parser.add_argument('--bad',type=lambda x:int(x,0),required=True)
    parser.add_argument('--max-instructions',type=int,default=2000000)
    parser.add_argument('--cc')
    args = parser.parse_args()
    if args.max_instructions <= 0:
        raise SystemExit('max-instructions must be positive')
    if args.ok == args.bad:
        raise SystemExit('success and failure addresses must differ')
    candidates = [args.cc] if args.cc else (['E:/msys64/usr/bin/gcc.exe','C:/msys64/usr/bin/gcc.exe'] if os.name=='nt' else ['gcc'])
    cc = next((shutil.which(p) or (p if Path(p).is_file() else None) for p in candidates if p and (shutil.which(p) or Path(p).is_file())),None)
    if not cc:
        raise SystemExit('MSYS GCC is required for a Windows MSYS reference library; supply --cc')
    env = dict(os.environ)
    env['PATH'] = str(Path(cc).parent)+os.pathsep+env.get('PATH','')
    with tempfile.TemporaryDirectory(prefix='vdot_reference_') as temporary:
        work = Path(temporary)
        shutil.copyfile(ROOT/'baremetal/reference_runner.c',work/'runner.c')
        shutil.copyfile(args.layout,work/'cosim_layout.h')
        shutil.copyfile(args.library,work/('reference.dll' if os.name=='nt' else 'reference.so'))
        shutil.copyfile(args.image,work/'image.bin')
        runner = work/('runner.exe' if os.name=='nt' else 'runner')
        cmd = [cc,'-O2','-I',str(work),'-o',str(runner),str(work/'runner.c')]
        if os.name != 'nt':
            cmd += ['-ldl']
        built = subprocess.run(cmd,capture_output=True,text=True,encoding='utf-8',errors='replace',env=env)
        if built.returncode:
            print(built.stdout+built.stderr,file=sys.stderr)
            return 1
        result = subprocess.run([str(runner),str(work/('reference.dll' if os.name=='nt' else 'reference.so')),str(work/'image.bin'),hex(args.ok),hex(args.bad),str(args.max_instructions)],capture_output=True,text=True,encoding='utf-8',errors='replace',env=env,timeout=120)
        print(result.stdout,end='')
        print(result.stderr,end='',file=sys.stderr)
        return result.returncode


if __name__ == '__main__':
    raise SystemExit(main())
