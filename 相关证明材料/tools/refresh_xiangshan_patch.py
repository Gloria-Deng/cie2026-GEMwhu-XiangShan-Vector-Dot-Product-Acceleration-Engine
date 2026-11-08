#!/usr/bin/env python3
"""Rebuild the delivery patch from the unchanged supplied upstream and installer."""
from __future__ import annotations

import argparse
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
PATCH_DIR = ROOT / 'rtl/xiangshan-patch'


def run(command, cwd):
    result = subprocess.run(command, cwd=cwd, capture_output=True, text=True,
                            encoding='utf-8', errors='replace')
    if result.returncode:
        raise RuntimeError(' '.join(map(str, command)) + '\n' + result.stdout + result.stderr)
    return result.stdout


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path, help='new patch path outside the original patch')
    args = parser.parse_args()
    if args.out.exists():
        parser.error('output already exists')
    if not shutil.which('bash') or not shutil.which('git'):
        parser.error('bash and git are required; use Linux or WSL')
    old = (PATCH_DIR / 'vdot.patch').read_text(encoding='utf-8')
    paths = re.findall(r'^diff --git a/(\S+) b/\S+$', old, re.M)
    with tempfile.TemporaryDirectory(prefix='vdot-patch-') as temporary:
        work = Path(temporary)
        for relative in paths:
            source = ROOT / 'sources/XiangShan' / relative
            if source.is_file():
                destination = work / relative
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(source, destination)
        run(['git', 'init', '-q'], work)
        run(['git', 'add', '.'], work)
        run(['bash', str(PATCH_DIR / 'install.sh'), str(work)], work)
        run(['bash', str(PATCH_DIR / 'apply.sh'), '--check', str(work)], work)
        created = run(['git', 'ls-files', '--others', '--exclude-standard', '-z', '--', 'src'], work).split('\0')
        created = [p for p in created if p and not p.endswith('.vdotbak')]
        if created:
            run(['git', 'add', '-N', '--', *created], work)
        patch = run(['git', '-c', 'core.autocrlf=false', 'diff', '--no-ext-diff', '--no-color', '--', 'src'], work)
        if not patch:
            raise RuntimeError('generated patch is empty')
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(patch, encoding='utf-8', newline='\n')
    print('PATCH_REBUILD_PASS', args.out)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError) as error:
        print('PATCH_REBUILD_FAIL:', error, file=sys.stderr)
        sys.exit(1)
