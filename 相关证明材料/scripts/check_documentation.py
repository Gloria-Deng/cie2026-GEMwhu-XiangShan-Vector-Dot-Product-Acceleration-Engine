#!/usr/bin/env python3
"""Check local links and the measured counts used by the maintained documents."""
from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    args = parser.parse_args()
    if args.out.exists() and any(args.out.iterdir()):
        parser.error('--out must be new or empty')
    args.out.mkdir(parents=True, exist_ok=True)
    files = [ROOT / 'README.md', *sorted((ROOT / '技术文档/src').rglob('*.md')),
             *sorted((ROOT / '技术文档/答辩材料').glob('*.md')),
             *sorted((ROOT / '技术文档/提交准备').glob('*.md'))]
    files.extend(ROOT / '相关证明材料' / p for p in [
        'synth/README.md', 'experiments/throughput/README.md', 'applications/gemm/README.md',
        'performance/README.md', 'verification_20261104/README.md',
        'results/completed_performance_20261104/README.md',
        'results/performance_submission_20261030/README.md', 'results/vdot_full_core_20261102/README.md',
        'stage1/measured_20261102/README.md', 'experiments/throughput/measured_20261103/README.md',
        'applications/gemm/measured_20261103/README.md'])
    rows, failures = [], []
    for path in files:
        if not path.is_file():
            failures.append('missing document: ' + str(path)); continue
        text = path.read_text(encoding='utf-8')
        visible = re.sub(r'```.*?```', '', text, flags=re.S)
        for target in re.findall(r'!?\[[^\]]*\]\(([^)]+)\)', visible):
            target = target.strip().split(' "')[0].strip('<>')
            parsed = urlsplit(target)
            if parsed.scheme or target.startswith('#'):
                continue
            destination = (path.parent / unquote(parsed.path)).resolve()
            exists = destination.exists()
            rows.append([path.relative_to(ROOT).as_posix(), target, 'PASS' if exists else 'FAIL'])
            if not exists:
                failures.append(f'{path.name}: {target}')
        if path.parent.name == 'src' and not re.search(r'修订|版本', text[:400]):
            failures.append('missing revision note: ' + path.name)
    materials = ROOT / '相关证明材料'
    counts = {group: sum(len(s.split()) == 4 for s in (materials / f'tests/cases_{group}.txt').read_text().splitlines())
              for group in ('pos', 'neg', 'bound', 'rand')}
    if counts != dict(pos=46, neg=48, bound=45, rand=800) or sum(counts.values()) != 939:
        failures.append('input counts differ')
    summary = json.loads((materials / 'results/cluster/20261019/summary.json').read_text(encoding='utf-8'))
    manifest = json.loads((materials / 'results/cluster/20261019/program_manifest.json').read_text(encoding='utf-8'))
    if len(summary['runs']) != 16 or len(manifest['programs']) != 16:
        failures.append('processor counts differ')
    manual = (ROOT / '技术文档/src/original/2.3.0_共用环境部署与操作手册.txt').read_text(encoding='utf-8')
    for chapter in ('3', '4.1', '6.1', '6.2', '7', '9.4'):
        if not re.search(r'(?m)^' + re.escape(chapter) + r'\s+', manual):
            failures.append('missing manual chapter: ' + chapter)
    with (args.out / 'links.csv').open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.writer(stream); writer.writerow(['document', 'target', 'status']); writer.writerows(rows)
    pending = []
    for path in files:
        if path.is_file():
            for number, line in enumerate(path.read_text(encoding='utf-8').splitlines(), 1):
                if '待实测' in line or '待确认' in line:
                    pending.append([path.relative_to(ROOT).as_posix(), number, line])
    with (args.out / 'pending_measurements.csv').open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.writer(stream); writer.writerow(['document', 'line', 'text']); writer.writerows(pending)
    (args.out / 'summary.txt').write_text('\n'.join(failures) + f'\nlinks={len(rows)} failures={len(failures)}\n', encoding='utf-8')
    for failure in failures:
        print('DOCUMENTATION_FAIL', failure)
    print(f'DOCUMENTATION_CHECK files={len(files)} links={len(rows)} failures={len(failures)} pending_lines={len(pending)}')
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
