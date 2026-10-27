#!/usr/bin/env python3

from pathlib import Path
import argparse
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parent

def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--mode', choices=('fst', 'csv', 'invalid'), default='csv')
    p.add_argument('--out', type=Path)
    p.add_argument('--plot', action='store_true')
    p.add_argument('--scratch', type=Path)
    p.add_argument('--library', type=Path)
    a = p.parse_args()
    out = (a.out or Path(tempfile.mkdtemp(prefix='vadd_review_'))).resolve()
    if out == ROOT or ROOT in out.parents:
        p.error('--out must be outside the package')
    if out.exists() and any(out.iterdir()):
        p.error('--out must be new or empty')
    if a.mode == 'invalid':
        out.mkdir(parents=True, exist_ok=True)
        cmd = [sys.executable, '-B', str(ROOT/'tools/check_vadd_fst_failures.py'),
               '--root', str(ROOT), '--out', str(out/'failure_checks.json')]
    else:
        cmd = [sys.executable, '-B', str(ROOT/'tools/analyze_vadd_fst.py'), '--out', str(out)]
        if a.mode == 'fst':
            cmd += ['--fst', str(ROOT/'waveforms/vadd.fst')]
        else:
            cmd += ['--cache-csv', str(ROOT/'results/vadd_wave_stage1/extract_all.csv')]
        if not a.plot:
            cmd += ['--no-plot']
        if a.scratch:
            a.scratch.mkdir(parents=True, exist_ok=True)
            cmd += ['--scratch', str(a.scratch.resolve())]
        if a.library:
            cmd += ['--library', str(a.library.resolve())]
    return subprocess.call(cmd)

if __name__ == '__main__':
    raise SystemExit(main())
