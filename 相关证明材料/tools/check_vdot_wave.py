#!/usr/bin/env python3
"""Check a completed full-core vdot recording without running the processor again."""
import argparse
from pathlib import Path
import re
import sys

ANSI = re.compile(r'\x1b\[[0-?]*[ -/]*[@-~]')


def check_execution(text, ok_pc):
    text = ANSI.sub('', text)
    pcs = re.findall(
        r'Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = (0x[0-9a-fA-F]+)', text)
    if len(pcs) != 1 or int(pcs[0], 16) != ok_pc:
        raise ValueError('full-core execution did not stop at the unique OK address')
    if 'Difftest enabled' not in text:
        raise ValueError('execution does not confirm DiffTest is enabled')
    if re.search(r'\bABORT\b|\bFAIL(?:ED)?\b|different at pc|Segmentation fault|'
                 r'AddressSanitizer|Assertion .*failed', text, re.I):
        raise ValueError('execution reports an error')
    return int(pcs[0], 16)


def check(folder):
    symbols = {s[2]: int(s[0], 16)
               for line in (folder / 'symbols.txt').read_text(encoding='utf-8').splitlines()
               if len(s := line.split()) == 3}
    if 'OK' not in symbols:
        raise ValueError('program symbols do not contain OK')
    pc = check_execution((folder / 'emu.txt').read_text(encoding='utf-8'), symbols['OK'])
    waveform = folder / 'vdot.fst'
    if not waveform.is_file() or waveform.stat().st_size == 0:
        raise ValueError('waveform is missing or empty')
    return pc, waveform.stat().st_size


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--results', type=Path, required=True)
    args = ap.parse_args()
    try:
        pc, size = check(args.results.resolve())
        print(f'VDOT_WAVE_EMU_PASS pc={pc:#x} waveform_bytes={size}')
        return 0
    except (ValueError, OSError) as error:
        print('FAIL: ' + str(error), file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
