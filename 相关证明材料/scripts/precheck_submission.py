#!/usr/bin/env python3
"""Read-only submission checks. Pending publication checks never become success."""
from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
import re
import subprocess
import sys
import urllib.error
import urllib.request

ROOT = Path(__file__).resolve().parents[2]
REPO = 'Gloria-Deng/cie2026-GEMwhu-XiangShan-Vector-Dot-Product-Acceleration-Engine'
DOCS = [
    ('1.1', '1.1_环境部署验证输出说明.pdf'),
    ('1.2', '1.2_完整的开发环境部署与操作过程记录.pdf'),
    ('1.3', '1.3_向量加法指令在香山中的执行过程文档.pdf'),
    ('2.1', '2.1_vdot.vv设计文档.pdf'),
    ('2.3.1', '2.3.1_正数点积测试文档.pdf'),
    ('2.3.2', '2.3.2_负数点积测试文档.pdf'),
    ('2.3.3', '2.3.3_边界值测试文档.pdf'),
    ('3.1.1/3.1.2', '3.1_NEMU指令扩展与协同仿真验证报告.pdf'),
    ('3.3', '3.3_延迟加速分析报告.pdf'),
]


def git(*args):
    result = subprocess.run(['git', '-c', 'core.quotepath=false', *args], cwd=ROOT,
                            capture_output=True, encoding='utf-8', errors='replace', timeout=90)
    if result.returncode:
        raise RuntimeError('git read failed: ' + result.stderr.strip())
    return result.stdout.strip()


def request(url, data=None, headers=None):
    head = {'User-Agent': 'cie2026-local-check', **(headers or {})}
    req = urllib.request.Request(url, data=data, headers=head)
    with urllib.request.urlopen(req, timeout=30) as response:
        return json.load(response)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    parser.add_argument('--online', action='store_true', help='read public repository and remote LFS availability')
    parser.add_argument('--max-text-mib', type=int, default=64, help='maximum individual text file size to scan')
    args = parser.parse_args()
    if args.max_text_mib <= 0:
        parser.error('--max-text-mib must be positive')
    if args.out.exists() and any(args.out.iterdir()):
        parser.error('--out must be new or empty')
    args.out.mkdir(parents=True, exist_ok=True)
    rows = []

    def add(name, status, detail):
        rows.append(dict(check=name, status=status, detail=detail))
        print(name, status, detail)

    for number, name in DOCS:
        path = ROOT / '技术文档' / name
        add(number, 'PASS' if path.is_file() else 'FAIL', path.relative_to(ROOT).as_posix())
    for number, relative in [('2.2', '相关证明材料/rtl/chisel/vdot/vdot/src/vdot/VDotUnit.scala'),
                             ('3.2', '相关证明材料/experiments/throughput/study.py')]:
        add(number, 'PASS' if (ROOT / relative).is_file() else 'FAIL', relative)
    videos = sorted((ROOT / '项目演示视频').glob('*.mp4'))
    add('videos', 'PASS' if len(videos) == 3 else 'FAIL', str(len(videos)))
    tracked = git('ls-files', '-z').split('\0')
    publication_files = set(tracked) | set(git('ls-files', '--others', '--exclude-standard', '-z').split('\0'))
    pointers, oversized = [], []
    for relative in sorted(publication_files):
        if not relative:
            continue
        path = ROOT / relative
        if not path.is_file():
            continue
        size = path.stat().st_size
        if path.suffix.lower() in ('.mp4', '.fst') or size > 100 * 1024 * 1024:
            attributes = git('check-attr', 'filter', '--', relative)
            if not attributes.endswith(': lfs'):
                if size > 100 * 1024 * 1024:
                    oversized.append(relative)
                else:
                    add('large_file', 'FAIL', relative + ': missing LFS attribute')
                continue
            if relative not in tracked:
                add('large_file', 'PENDING', relative + ': 尚未保存为提交中的LFS对象')
                continue
            text = git('show', 'HEAD:' + relative)
            match = re.fullmatch(r'version https://git-lfs.github.com/spec/v1\noid sha256:([a-f0-9]{64})\nsize (\d+)', text)
            if not match:
                add('large_file', 'FAIL', relative + ': missing stored LFS pointer')
            else:
                pointers.append(dict(oid=match.group(1), size=int(match.group(2))))
    add('ordinary_large_files', 'FAIL' if oversized else 'PASS', '; '.join(oversized) or 'none')
    add('lfs_entries', 'PASS' if len(pointers) >= 4 else 'FAIL', str(len(pointers)))
    change = git('status', '--porcelain')
    add('local_changes', 'PENDING' if change else 'PASS', '尚有未提交修改' if change else '无本地修改')
    distance = git('rev-list', '--left-right', '--count', 'HEAD...@{upstream}').split()
    add('local_remote_tracking', 'PASS' if distance == ['0', '0'] else 'PENDING',
        'local_ahead=' + distance[0] + ' local_behind=' + distance[1])
    add('official_materials', 'INFO', '本地参考目录无需随作品一并发布；当前未自动添加')
    if args.online:
        try:
            repo = request('https://api.github.com/repos/' + REPO)
            add('public_repository', 'PASS' if repo['private'] is False else 'FAIL', repo['html_url'])
            head = request('https://api.github.com/repos/' + REPO + '/commits/' + repo['default_branch'])
            add('published_revision', 'PASS' if head['sha'] == git('rev-parse', 'HEAD') else 'PENDING',
                '远端与本地已提交版本相同' if head['sha'] == git('rev-parse', 'HEAD') else '远端与本地已提交版本不同')
            body = json.dumps(dict(operation='download', transfers=['basic'], objects=pointers)).encode()
            data = request('https://github.com/' + REPO + '.git/info/lfs/objects/batch', body,
                           {'Accept': 'application/vnd.git-lfs+json', 'Content-Type': 'application/vnd.git-lfs+json'})
            available = all('download' in x.get('actions', {}) and 'error' not in x for x in data.get('objects', []))
            available = available and len(data.get('objects', [])) == len(pointers)
            # Signed download addresses are deliberately never printed or saved.
            add('remote_lfs', 'PASS' if available else 'PENDING', '下载信息可获取' if available else '部分大文件待核对')
        except (OSError, KeyError, ValueError, urllib.error.HTTPError) as error:
            add('online_checks', 'PENDING', '公开服务读取失败：' + type(error).__name__)
    else:
        add('online_checks', 'PENDING', '未读取公有仓库与远端大文件状态；可加 --online')
    findings, unscanned = [], []
    patterns = {
        'private_key': re.compile(r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----'),
        'access_token': re.compile(r'\b(?:gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{40,}|AKIA[A-Z0-9]{16})\b'),
        'account_path': re.compile(r'/(?:project|home)/[A-Za-z0-9_.-]+/'),
        'email': re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b'),
    }
    candidates = publication_files
    binary_suffixes = {'.bin', '.elf', '.o', '.a', '.so', '.dll', '.exe', '.vvp', '.fst',
                       '.mp4', '.png', '.jpg', '.jpeg', '.gif', '.webp', '.woff', '.ttf', '.ttc',
                       '.gz', '.zip', '.bz2', '.xz', '.7z', '.tar'}
    skipped_binary = 0
    for relative in sorted(candidates):
        path = ROOT / relative
        if not relative or not path.is_file():
            continue
        if any(part in ('sources', 'source_additions', 'licenses', 'reference') for part in path.parts):
            continue
        if path.suffix.lower() in binary_suffixes:
            skipped_binary += 1
            continue
        if path.stat().st_size > args.max_text_mib * 1024 * 1024:
            unscanned.append(dict(path=relative, reason='超过配置的文本大小限制'))
            continue
        if path.suffix.lower() == '.pdf':
            try:
                import fitz
                with fitz.open(path) as document:
                    content = '\n'.join(page.get_text() for page in document)
            except (ImportError, RuntimeError) as error:
                unscanned.append(dict(path=relative, reason='PDF文字读取失败：' + type(error).__name__))
                continue
        else:
            data = path.read_bytes()
            if data.startswith((b'\xff\xfe', b'\xfe\xff')):
                content = data.decode('utf-16', errors='replace')
            elif b'\0' in data:
                skipped_binary += 1
                continue
            else:
                content = data.decode('utf-8-sig', errors='replace')
        for line_number, line in enumerate(content.splitlines(), 1):
            selected = []
            if 'PRIVATE KEY' in line:
                selected.append('private_key')
            if any(marker in line for marker in ('ghp_', 'gho_', 'ghu_', 'ghs_', 'ghr_', 'github_pat_', 'AKIA')):
                selected.append('access_token')
            if '/project/' in line or '/home/' in line:
                selected.append('account_path')
            if '@' in line:
                selected.append('email')
            for kind in selected:
                pattern = patterns[kind]
                if pattern.search(line):
                    findings.append(dict(kind=kind, path=relative, line=line_number))
    serious = [x for x in findings if x['kind'] in ('private_key', 'access_token')]
    add('secret_scan', 'FAIL' if serious else 'PASS', 'secret_candidates=' + str(len(serious)))
    add('publication_text_review', 'PENDING' if findings else 'PASS', 'locations=' + str(len(findings)))
    add('unscanned_text', 'PENDING' if unscanned else 'PASS', 'files=' + str(len(unscanned)))
    add('binary_files', 'INFO', 'omitted=' + str(skipped_binary))
    with (args.out / 'checks.csv').open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.DictWriter(stream, ['check', 'status', 'detail']); writer.writeheader(); writer.writerows(rows)
    with (args.out / 'review_locations.csv').open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.DictWriter(stream, ['kind', 'path', 'line']); writer.writeheader(); writer.writerows(findings)
    with (args.out / 'unscanned.csv').open('w', encoding='utf-8-sig', newline='') as stream:
        writer = csv.DictWriter(stream, ['path', 'reason']); writer.writeheader(); writer.writerows(unscanned)
    failed, pending = sum(x['status'] == 'FAIL' for x in rows), sum(x['status'] == 'PENDING' for x in rows)
    print(f'SUBMISSION_PRECHECK failures={failed} pending={pending} output={args.out}')
    return 1 if failed else 2 if pending else 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.TimeoutExpired) as error:
        print('SUBMISSION_PRECHECK_FAIL:', error, file=sys.stderr)
        sys.exit(1)
