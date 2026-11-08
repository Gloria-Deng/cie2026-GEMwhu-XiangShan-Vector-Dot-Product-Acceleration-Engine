#!/usr/bin/env python3
"""Build standalone UARTLite NEMU in a new copy of the supplied source tree."""
import argparse
from datetime import datetime
import os
import re
from pathlib import Path
import shutil
import subprocess
import sys

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--source',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--jobs',type=int,default=2)
    args=ap.parse_args()
    src=args.source.resolve();out=args.out.resolve()
    if not (src/'Kconfig').is_file() or out.exists() or src==out or src in out.parents:
        raise ValueError('supply an existing NEMU source tree and a new output directory outside it')
    out.mkdir(parents=True)
    tree=out/'NEMU'
    def ignore(directory,names):
        skipped={'.git','__pycache__'}.intersection(names)
        rel=Path(directory).relative_to(src).as_posix()
        if rel in ('.','tools/kconfig','tools/fixdep','resource/softfloat'):
            skipped.update({'build'}.intersection(names))
        return skipped
    shutil.copytree(src,tree,symlinks=True,ignore=ignore)
    env=os.environ.copy();env['NEMU_HOME']=str(tree)
    with (out/'build.txt').open('w',encoding='utf-8') as f:
        f.write(datetime.now().astimezone().isoformat()+'\n');f.flush()
        def run(cmd):
            f.write(' '.join(map(str,cmd))+'\n');f.flush()
            subprocess.run(list(map(str,cmd)),cwd=tree,env=env,stdout=f,stderr=subprocess.STDOUT,check=True)
        run(['make','riscv64-xs_defconfig'])
        p=tree/'.config';text=p.read_text()
        # The supplied vdot decode additions need their matching configuration switch.
        if 'CUSTOM_VDOT' in (tree/'src/isa/riscv64/Kconfig').read_text():
            text=text.replace('# CONFIG_CUSTOM_VDOT is not set','CONFIG_CUSTOM_VDOT=y')
        # UART-only execution does not need the display, keyboard or audio devices.
        for name in ('HAS_VGA', 'HAS_KEYBOARD', 'HAS_AUDIO'):
            text = re.sub(r'^CONFIG_' + name + r'=y$',
                          '# CONFIG_' + name + ' is not set', text, flags=re.M)
        p.write_text(text)
        run([tree/'tools/kconfig/build/conf','--syncconfig','Kconfig'])
        config=p.read_text()
        if 'CONFIG_HAS_UARTLITE=y' not in config or 'CONFIG_UARTLITE_MMIO=0x40600000' not in config:
            raise ValueError('selected NEMU configuration does not provide the expected UARTLite address')
        if any('CONFIG_' + name + '=y' in config for name in ('HAS_VGA', 'HAS_KEYBOARD', 'HAS_AUDIO')):
            raise ValueError('UART-only build unexpectedly enables an SDL device')
        # This fixed NEMU revision links SDL for every standalone device build.
        # Limit the link dependency to devices that actually call SDL.
        makefile=tree/'Makefile';make_text=makefile.read_text()
        anchor='LDFLAGS += -lSDL2'
        if make_text.count(anchor) != 1:
            raise ValueError('unexpected SDL link rule in the supplied NEMU Makefile')
        makefile.write_text(make_text.replace(anchor,
            'ifneq ($(filter y,$(CONFIG_HAS_AUDIO) $(CONFIG_HAS_VGA) $(CONFIG_HAS_KEYBOARD)),)\n'
            + anchor + '\nendif'))
        (out/'uart_config.txt').write_text(config,encoding='utf-8')
        run(['make','-j'+str(args.jobs)])
    print('NEMU_UART_BUILD_PASS executable='+str(tree/'build/riscv64-nemu-interpreter'))
    return 0

if __name__=='__main__':
    try:raise SystemExit(main())
    except (ValueError,OSError,subprocess.SubprocessError) as error:
        print('FAIL '+str(error),file=sys.stderr);raise SystemExit(1)
