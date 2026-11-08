#!/usr/bin/env python3
"""Build and run the three independent hello layers; never submits a job."""
from __future__ import annotations
import argparse
from datetime import datetime
import ipaddress
import os
from pathlib import Path
import re
import shutil
import socket
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
ANSI = re.compile(r'\x1b\[[0-?]*[ -/]*[@-~]')
HELLO = re.compile(r'^hello xiangshan, I am GEMwhu, IP address (\d+\.\d+\.\d+\.\d+)$', re.M)

def require(ok, message):
    if not ok:
        raise ValueError(message)

def command(args, *, cwd=None, input=None, timeout=300):
    p = subprocess.run(list(map(str, args)), cwd=cwd, input=input, text=True,
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout)
    return p.returncode, ANSI.sub('', p.stdout).replace('\r', '')

def ip_address(explicit=None):
    if explicit:
        address = str(ipaddress.IPv4Address(explicit))
        require(not ipaddress.ip_address(address).is_loopback, 'loopback IP is not accepted')
        return address
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        try:
            s.connect(('8.8.8.8', 53))
            return ip_address(s.getsockname()[0])
        except OSError:
            for entry in socket.getaddrinfo(socket.gethostname(), None, socket.AF_INET):
                if not ipaddress.ip_address(entry[4][0]).is_loopback:
                    return ip_address(entry[4][0])
    raise ValueError('cannot select host IPv4; supply --ip from the execution host')

def tool(name):
    found = shutil.which(name)
    require(found is not None, 'missing executable: ' + name)
    return found

def symbols(elf, prefix):
    rc, text = command([tool(prefix + 'nm'), '-n', elf])
    require(rc == 0, text)
    return {p[2]: int(p[0], 16) for line in text.splitlines()
            if len(p := line.split()) == 3 and re.fullmatch('[0-9a-fA-F]+', p[0])}

def build(out, prefix, ip):
    out.mkdir(parents=True, exist_ok=True)
    message = f'hello xiangshan, I am GEMwhu, IP address {ip}'
    (out / 'hello_message.inc').write_text('.asciz "' + message + '\\n"\n', encoding='ascii')
    (out / 'embedded_ip.txt').write_text(ip + '\n', encoding='ascii')
    steps = [
        [tool(prefix + 'as'), '-march=rv64gc', '-mabi=lp64d', '-I', out,
         '-o', out/'hello.o', HERE/'hello_baremetal.S'],
        [tool(prefix + 'ld'), '-m', 'elf64lriscv', '-Ttext=0x80000000',
         '-Tdata=0x80100000', '--no-relax', '-e', '_start', '-o', out/'hello.elf', out/'hello.o'],
        [tool(prefix + 'objcopy'), '-O', 'binary', out/'hello.elf', out/'hello.bin'],
    ]
    for step in steps:
        rc, text = command(step)
        require(rc == 0, text)
    rc, text = command([tool(prefix+'objdump'), '-d', out/'hello.elf'])
    require(rc == 0, text)
    (out/'hello.dis').write_text(text, encoding='utf-8')
    table = symbols(out/'hello.elf', prefix)
    (out/'symbols.txt').write_text(''.join(f'{k}={v:#x}\n' for k,v in table.items()), encoding='ascii')
    return out/'hello.bin', table, message

def verify(text, expected=None):
    matches = HELLO.findall(text)
    require(bool(matches), 'expected hello line is absent')
    for item in matches:
        ipaddress.IPv4Address(item)
    if expected:
        require(expected in text.splitlines(), 'printed IP differs from embedded host IP')

def linux(out):
    require(sys.platform.startswith('linux'), 'Linux layer requires Linux/WSL')
    pieces = [datetime.now().astimezone().isoformat(), 'hostname=' + socket.gethostname()]
    rc, text = command(['uname', '-a']); require(rc == 0, text); pieces.append(text)
    for name, flags in [('gcc',['--version']), ('verilator',['--version']), ('mill',['--version']),
                        (os.environ.get('RISCV_PREFIX','riscv64-unknown-elf-')+'gcc',['--version'])]:
        found = shutil.which(name)
        pieces.append(name + '=' + (found or 'UNAVAILABLE'))
        if found:
            rc, text = command([found]+flags, timeout=60)
            pieces.append(text.strip()); require(rc == 0, name + ' version query failed')
    pieces.append('emu=' + (os.environ.get('EMU') or shutil.which('emu') or 'UNAVAILABLE'))
    rc, text = command([tool('gcc'), '-O2', '-Wall', '-Wextra', HERE/'hello_xiangshan.c', '-o', out/'hello_linux'])
    pieces.append(text); require(rc == 0, text)
    # TEAM_ID is part of the required greeting, shared by the existing C/Python programs.
    os.environ['TEAM_ID'] = 'GEMwhu'
    for cmd in [[out/'hello_linux'], [sys.executable, HERE/'hello_xiangshan_anyos.py']]:
        rc, text = command(cmd); pieces.append(text)
        (out/'linux.txt').write_text('\n'.join(pieces), encoding='utf-8')
        require(rc == 0, 'host hello failed'); verify(text)
    print('LINUX_HELLO_PASS')

def execute(args, layer, out, image, table, message):
    if layer == 'nemu':
        require(args.nemu, '--nemu must name a standalone NEMU executable with UARTLite enabled')
        executable = str(Path(args.nemu).resolve()) if Path(args.nemu).is_file() else tool(args.nemu)
        # Leave the OK/BAD self loops unchanged; stop through the NEMU monitor.
        rc, text = command([executable, image], input='si 20000\ninfo r\nq\n', timeout=args.timeout)
        pcs = re.findall(r'^\s*pc\s*:?\s+(?:0x)?([0-9a-fA-F]+)\b', text, re.M)
        passed = bool(pcs) and int(pcs[-1],16) == table['OK']
    else:
        require(args.emu, '--emu must name the XiangShan emulator')
        require(args.ref and Path(args.ref).is_file(), '--ref must name the matching NEMU reference library')
        executable = str(Path(args.emu).resolve()) if Path(args.emu).is_file() else tool(args.emu)
        cmd = [executable, '-i', image, '--diff='+str(Path(args.ref).resolve()),
               '--ram-size=256MB', '--no-squash', '-s', '1', '-C', str(args.cycles)]
        rc, text = command(cmd, cwd=out, timeout=args.timeout)
        pcs = re.findall(r'Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = (0x[0-9a-fA-F]+)', text)
        passed = len(pcs) == 1 and int(pcs[0],16) == table['OK']
    (out/(layer+'.txt')).write_text(text, encoding='utf-8')
    if layer == 'emu':
        require('Difftest enabled' in text, 'emu output does not confirm DiffTest is enabled')
    require(rc == 0, layer + ' exited with status ' + str(rc))
    verify(text, message)
    require(passed, layer + ' did not stop at OK')
    require(not re.search(r'\bABORT\b|\bFAIL(?:ED)?\b|different at pc|Segmentation fault',text,re.I), layer+' reported a failure')
    print(layer.upper() + '_HELLO_PASS')

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('layer', choices=('linux','build','nemu','emu','all'))
    ap.add_argument('--out', type=Path)
    ap.add_argument('--prefix', default=os.environ.get('RISCV_PREFIX','riscv64-unknown-elf-'))
    ap.add_argument('--ip', help='IPv4 selected on the host executing this image')
    ap.add_argument('--nemu', default=os.environ.get('NEMU'))
    ap.add_argument('--emu', default=os.environ.get('EMU'))
    ap.add_argument('--ref', default=os.environ.get('NEMU_REF'))
    ap.add_argument('--cycles', type=int, default=100000)
    ap.add_argument('--timeout', type=int, default=7200)
    args = ap.parse_args()
    out = (args.out or ROOT/'results'/('stage1_hello_'+datetime.now().strftime('%Y%m%d_%H%M%S_%f'))).resolve()
    require(not out.exists() or not any(out.iterdir()), 'output directory must be new or empty: '+str(out))
    out.mkdir(parents=True, exist_ok=True)
    print('output='+str(out), flush=True)
    layers = ('linux','nemu','emu') if args.layer == 'all' else (args.layer,)
    failures = []
    image_data = None
    for layer in layers:
        try:
            if layer == 'linux':
                linux(out)
            else:
                if image_data is None:
                    image_data = build(out/'image', args.prefix, ip_address(args.ip))
                if layer == 'build':
                    print('HELLO_BUILD_PASS')
                else:
                    execute(args, layer, out, *image_data)
        except (ValueError,OSError,subprocess.SubprocessError) as error:
            failures.append(layer+': '+str(error))
            (out/(layer+'_failure.txt')).write_text(str(error)+'\n',encoding='utf-8')
            print('FAIL '+failures[-1], file=sys.stderr)
    (out/'status.txt').write_text('\n'.join(failures or ['PASS '+','.join(layers)])+'\n',encoding='utf-8')
    return 1 if failures else 0

if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (ValueError,OSError,subprocess.SubprocessError) as error:
        print('FAIL '+str(error),file=sys.stderr)
        raise SystemExit(1)
