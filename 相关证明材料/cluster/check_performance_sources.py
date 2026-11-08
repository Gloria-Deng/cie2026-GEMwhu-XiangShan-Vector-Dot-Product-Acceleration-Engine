#!/usr/bin/env python3
"""Compare the current patches with a previously completed processor build."""
from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

XS_FILES = (
    'src/main/scala/xiangshan/backend/fu/FuType.scala',
    'src/main/scala/xiangshan/backend/fu/FuConfig.scala',
    'src/main/scala/xiangshan/Parameters.scala',
    'src/main/scala/xiangshan/backend/decode/VecDecoder.scala',
    'src/main/scala/xiangshan/backend/decode/VecExceptionGen.scala',
    'src/main/scala/xiangshan/backend/decode/Instructions.scala',
    'src/main/scala/xiangshan/backend/decode/DecodeUnit.scala',
)
XS_ADDED = (
    'src/main/scala/xiangshan/backend/fu/wrapper/VDotU.scala',
    'src/main/scala/xiangshan/backend/fu/wrapper/VdotCfg.scala',
    'src/main/scala/vdot/VDotUnit.scala',
)
NEMU_FILES = (
    'src/isa/riscv64/Kconfig', 'src/isa/riscv64/include/isa-all-instr.h',
    'src/isa/riscv64/instr/rvv/decode.h',
    'src/isa/riscv64/instr/rvv/vcompute.h',
    'src/isa/riscv64/instr/rvv/vcommon.c', 'scripts/build.mk',
    'configs/riscv64-xs-ref_defconfig',
)
PATTERN = re.compile(r'"(?:\\.|[^"\\])*"|/\*[\s\S]*?\*/|//[^\n]*')


def tokens(text):
    text = PATTERN.sub(lambda m: m.group() if m.group().startswith('"') else '', text)
    return re.findall(r'"(?:\\.|[^"\\])*"|[A-Za-z_$][\w$]*|\d+|\S', text)


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def copy_files(source, destination, paths):
    for relative in paths:
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source / relative, target)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    for name in ('materials', 'build', 'upstream', 'out'):
        ap.add_argument('--' + name, type=Path, required=True)
    args = ap.parse_args()
    root, build, upstream, out = (getattr(args, n).resolve()
                                  for n in ('materials', 'build', 'upstream', 'out'))
    out.mkdir(parents=True, exist_ok=False)
    saved = json.loads((build / 'build_manifest.json').read_text())
    rows = []

    def record(name, ok, detail):
        rows.append(dict(item=name, status='PASS' if ok else 'FAIL', detail=detail))
        with (out / 'checks.csv').open('w', newline='', encoding='utf-8') as f:
            w = csv.DictWriter(f, fieldnames=['item', 'status', 'detail'])
            w.writeheader()
            w.writerows(rows)
        if not ok:
            raise ValueError(name + ': ' + detail)

    for name in ('emu', 'library'):
        path = Path(saved[name])
        record(name, path.is_file() and digest(path) == saved[name + '_sha256'], str(path))
    for relative, expected in saved['patched_sources'].items():
        path = build / relative
        record('saved/' + relative, path.is_file() and digest(path) == expected, expected)
    config = saved['configuration']
    record('configuration', config['config'] == 'KunminghuV2Config' and
           config['cores'] == 1 and config['trace'] == 'fst', str(config))
    makefiles = list((build / 'XiangShan/build/verilator-compile').glob('VSimTop*.mk'))
    text = '\n'.join(p.read_text() for p in makefiles)
    record('fst_compiled', bool(re.search(r'^VM_TRACE_FST\s*[:?+]?=\s*1\s*$', text, re.M)),
           'VM_TRACE_FST=1')
    model = (build / 'XiangShan/build/verilator-compile/VSimTop.cpp').read_text()
    record('single_thread', bool(re.search(
        r'unsigned VSimTop::threads\(\) const\s*\{\s*return 1;\s*\}', model)),
        'VSimTop::threads() returns 1')

    expected_xs = out / 'expected/XiangShan'
    pristine_xs = upstream / 'XiangShan-42f87803d10bc21bbc5df2807a2fc07db6c9dc89'
    copy_files(pristine_xs, expected_xs, XS_FILES)
    with (out / 'apply_xiangshan.txt').open('w') as f:
        subprocess.run(['bash', str(root / 'rtl/xiangshan-patch/install.sh'), str(expected_xs)],
                       stdout=f, stderr=subprocess.STDOUT, check=True)
    for relative in XS_FILES + XS_ADDED:
        expected = expected_xs / relative
        actual = build / 'XiangShan' / relative
        record('current/XiangShan/' + relative,
               actual.is_file() and tokens(expected.read_text()) == tokens(actual.read_text()),
               'code tokens match the current installer output')

    pristine_nemu = upstream / 'NEMU-3d9f9fb8c05095ba84b6f9b4125234140b3de035'
    minimal_nemu = out / 'pristine/NEMU'
    expected_nemu = out / 'expected/NEMU'
    copy_files(pristine_nemu, minimal_nemu, NEMU_FILES)
    with (out / 'apply_nemu.txt').open('w') as f:
        subprocess.run(['python3', str(root / 'nemu/apply_nemu_patch.py'),
                        str(minimal_nemu), str(expected_nemu)],
                       stdout=f, stderr=subprocess.STDOUT, check=True)
    for relative in NEMU_FILES + ('configs/riscv64-xs-vdot_sdtrig_defconfig',):
        expected = expected_nemu / relative
        actual = build / 'NEMU' / relative
        record('current/NEMU/' + relative,
               actual.is_file() and tokens(expected.read_text()) == tokens(actual.read_text()),
               'code tokens match the current NEMU patch output')
    (out / 'build_manifest.json').write_bytes((build / 'build_manifest.json').read_bytes())
    (out / 'status.txt').write_text('PASS current_patch_matches_completed_build\n')
    print('CURRENT_PROCESSOR_SOURCES_PASS checks=' + str(len(rows)), flush=True)


if __name__ == '__main__':
    main()
