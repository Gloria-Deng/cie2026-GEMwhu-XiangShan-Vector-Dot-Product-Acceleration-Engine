#!/usr/bin/env python3

from pathlib import Path
import argparse
import subprocess
ROOT=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--cc',default='gcc')
p.add_argument('--out',type=Path,required=True)
a=p.parse_args()
out=a.out.resolve()
if out.exists(): p.error('--out already exists')
out.parent.mkdir(parents=True,exist_ok=True)
gtk=ROOT/'source/gtkwave'; z=ROOT/'source/zlib'
znames=('adler32 compress crc32 deflate gzclose gzlib gzread gzwrite infback '
        'inffast inflate inftrees trees uncompr zutil').split()
cmd=[a.cc,'-O2','-shared','-fPIC','-I'+str(gtk),'-I'+str(z),
     '-DFST_CONFIG_INCLUDE="fst_config.h"']
cmd += [str(gtk/(n+'.c')) for n in ('fstapi','lz4','fastlz')]
cmd += [str(z/(n+'.c')) for n in znames]
subprocess.run(cmd+['-o',str(out)],check=True)
print('Built',out)
