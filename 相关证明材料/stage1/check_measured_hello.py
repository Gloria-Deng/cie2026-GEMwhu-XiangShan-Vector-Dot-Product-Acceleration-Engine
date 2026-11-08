#!/usr/bin/env python3
"""Recheck the three saved hello outputs without executing a processor."""
import argparse
import ipaddress
from pathlib import Path
import re


def check(folder):
    embedded = (folder / 'image/embedded_ip.txt').read_text().strip()
    ipaddress.IPv4Address(embedded)
    symbols = {}
    for line in (folder / 'image/symbols.txt').read_text().splitlines():
        name, value = line.split('=', 1)
        symbols[name] = int(value, 0)
    greeting = 'hello xiangshan, I am GEMwhu, IP address ' + embedded
    for layer in ('linux', 'nemu', 'emu'):
        text = re.sub(r'\x1b\[[0-?]*[ -/]*[@-~]', '', (folder / (layer + '.txt')).read_text(encoding='utf-8', errors='replace'))
        if greeting not in text.splitlines():
            raise ValueError(layer + ': saved greeting differs from embedded host address')
        if re.search(r'\bABORT\b|\bFAIL(?:ED)?\b|different at pc|Segmentation fault', text, re.I):
            raise ValueError(layer + ': saved execution reports failure')
        if layer == 'nemu':
            pcs = re.findall(r'^\s*pc\s*:?\s+(?:0x)?([0-9a-fA-F]+)\b', text, re.M)
            if not pcs or int(pcs[-1], 16) != symbols['OK']:
                raise ValueError('NEMU did not stop at OK')
        if layer == 'emu':
            pcs = re.findall(r'Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = (0x[0-9a-fA-F]+)', text)
            if len(pcs) != 1 or int(pcs[0], 16) != symbols['OK'] or 'Difftest enabled' not in text:
                raise ValueError('processor DiffTest or terminal address differs')
    if (folder / 'status.txt').read_text().strip() != 'PASS linux,nemu,emu':
        raise ValueError('saved completion status differs')
    print('MEASURED_HELLO_PASS layers=3 pc=' + hex(symbols['OK']))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--results', type=Path, default=Path(__file__).resolve().parent / 'measured_20261102')
    check(parser.parse_args().results)
