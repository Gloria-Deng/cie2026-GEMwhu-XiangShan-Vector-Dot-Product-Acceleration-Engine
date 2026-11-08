#!/usr/bin/env python3
"""Compare Scala code tokens with the committed version and check patch copies."""
from __future__ import annotations

from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
REPO = ROOT.parent
SCALA = [*sorted((ROOT / 'rtl/xiangshan-patch').glob('*.scala')),
         *sorted((ROOT / 'rtl/chisel/vdot/vdot/src/vdot').glob('*.scala'))]
PATTERN = re.compile(r'"(?:\\.|[^"\\])*"|/\*[\s\S]*?\*/|//[^\n]*')


def tokens(text):
    without_comments = PATTERN.sub(lambda m: m.group() if m.group().startswith('"') else '', text)
    return re.findall(r'"(?:\\.|[^"\\])*"|[A-Za-z_$][\w$]*|\d+|\S', without_comments)


def main():
    for path in SCALA:
        relative = path.relative_to(REPO).as_posix()
        result = subprocess.run(['git', 'show', 'HEAD:' + relative], cwd=REPO,
                                capture_output=True, encoding='utf-8', errors='strict')
        if result.returncode:
            raise ValueError('cannot read committed source: ' + relative)
        if tokens(result.stdout) != tokens(path.read_text(encoding='utf-8')):
            raise ValueError('Scala code changed: ' + relative)
    text = (ROOT / 'rtl/xiangshan-patch/vdot.patch').read_text(encoding='utf-8')
    for destination, source in [
        ('src/main/scala/vdot/VDotUnit.scala', ROOT / 'rtl/chisel/vdot/vdot/src/vdot/VDotUnit.scala'),
        ('src/main/scala/xiangshan/backend/fu/wrapper/VDotU.scala', ROOT / 'rtl/xiangshan-patch/VDotU.scala')]:
        match = re.search(r'^diff --git a/' + re.escape(destination) + r' b/.*?(?=^diff --git |\Z)', text, re.M | re.S)
        if not match:
            raise ValueError('missing source in patch: ' + destination)
        copied = '\n'.join(line[1:] for line in match.group().splitlines()
                           if line.startswith('+') and not line.startswith('+++')) + '\n'
        if copied != source.read_text(encoding='utf-8'):
            raise ValueError('patch differs from source: ' + destination)
    print(f'SOURCE_CLEANUP_PASS scala_files={len(SCALA)} code_tokens_identical=1 patch_copies=2')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError) as error:
        print('SOURCE_CLEANUP_FAIL:', error, file=sys.stderr)
        sys.exit(1)
