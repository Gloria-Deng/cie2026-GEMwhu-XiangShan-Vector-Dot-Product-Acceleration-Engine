#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import io
import os

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, os.pardir, "tests", "cases_vadd.txt"))
VLEN = 128


def sew_bits(s):
    return 8 << s


def pack(vals, bits):
    x = 0
    for i, v in enumerate(vals):
        x |= (v & ((1 << bits) - 1)) << (i * bits)
    return x


def unpack(x, bits):
    n = VLEN // bits
    return [(x >> (i * bits)) & ((1 << bits) - 1) for i in range(n)]


def vadd_vv(sew, vs1, vs2, old_vd, v0, vl, vm, vta, vma):
    bits = sew_bits(sew)
    n = VLEN // bits
    a = unpack(vs1, bits)
    b = unpack(vs2, bits)
    o = unpack(old_vd, bits)
    out = []
    for e in range(n):
        if e >= vl:
            out.append(((1 << bits) - 1) if vta else o[e])
        elif vm == 0 and ((v0 >> e) & 1) == 0:
            out.append(((1 << bits) - 1) if vma else o[e])
        else:
            out.append((a[e] + b[e]) & ((1 << bits) - 1))
    return pack(out, bits)


def cases():
    ones16 = lambda v: pack([v] * (VLEN // 8), 8)
    c = []

    c.append(("sew8 full", 0, ones16(3), ones16(5), 0, 0, 16, 1, 0, 0))

    c.append(("sew16 full", 1, pack([0x1234] * 8, 16), pack([0x0001] * 8, 16),
              0, 0, 8, 1, 0, 0))

    c.append(("sew32 full", 2, pack([1, 2, 3, 4], 32), pack([100, 200, 300, 400], 32), 0, 0, 4, 1, 0, 0))

    c.append(("sew64 full", 3, pack([0xFFFFFFFFFFFFFFFF], 64), pack([1], 64), 0, 0, 2, 1, 0, 0))

    c.append(("sew8 wrap", 0, ones16(250), ones16(10), 0, 0, 16, 1, 0, 0))

    c.append(("sew8 vl=4 tail-undisturbed", 0, ones16(7), ones16(1), ones16(0xAA), 0, 4, 1, 0, 0))

    c.append(("sew8 vl=4 tail-agnostic", 0, ones16(7), ones16(1), ones16(0xAA), 0, 4, 1, 1, 0))

    c.append(("sew8 vm=0 v0=0b0101 undisturbed", 0, ones16(9), ones16(1), ones16(0x5A),
              0b0101, 16, 0, 0, 0))

    c.append(("sew8 vm=0 v0=0b0101 mask-agnostic", 0, ones16(9), ones16(1), ones16(0x5A),
              0b0101, 16, 0, 0, 1))

    c.append(("sew8 slice split", 0, pack(list(range(16)), 8), pack(list(range(16, 32)), 8),
              0, 0, 16, 1, 0, 0))

    c.append(("sew8 vl=0", 0, ones16(1), ones16(1), ones16(0x33), 0, 0, 1, 0, 0))
    return c


def main():
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with io.open(OUT, "w", encoding="utf-8", newline="\n") as f:
        for i, (label, sew, vs1, vs2, old, v0, vl, vm, vta, vma) in enumerate(cases()):
            exp = vadd_vv(sew, vs1, vs2, old, v0, vl, vm, vta, vma)
            f.write("%d %d %032x %032x %032x %032x %d %d %d %d %032x\n"
                    % (i, sew, vs1, vs2, old, v0, vl, vm, vta, vma, exp))
    print("wrote", OUT)
    print("cases:", len(cases()))


if __name__ == "__main__":
    main()
