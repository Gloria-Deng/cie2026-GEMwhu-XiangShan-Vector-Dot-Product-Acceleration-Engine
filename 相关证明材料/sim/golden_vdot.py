#!/usr/bin/env python3
# -*- coding: utf-8 -*-





































from __future__ import annotations

VLEN_DEFAULT = 128
SEW_DEFAULT = 8
NLANES_DEFAULT = 8
OUT_W_DEFAULT = 32




DOT_MIN = 8 * (-128 * 127)
DOT_MAX = 8 * (-128 * -128)


ACC_BITS_MIN = 19


def as_int8(b: int) -> int:

    b &= 0xFF
    return b - 256 if b & 0x80 else b


def as_int(b: int, sew: int) -> int:






    if sew not in (8, 16, 32, 64):
        raise ValueError("sew must be an RVV element width (8/16/32/64), got %r" % sew)
    b &= (1 << sew) - 1
    return b - (1 << sew) if b & (1 << (sew - 1)) else b


def dot_product(vs1: bytes, vs2: bytes, nlanes: int = NLANES_DEFAULT,
                sew: int = SEW_DEFAULT, allow_extension: bool = False) -> int:







    if sew != 8 and not allow_extension:
        raise NotImplementedError("the statement pins SEW=8; other widths are RTL extensions")
    step = sew // 8
    if len(vs1) < nlanes * step or len(vs2) < nlanes * step:
        raise ValueError("source register shorter than %d lanes at SEW=%d"
                         % (nlanes, sew))




    def elem(buf, i):
        return int.from_bytes(buf[i * step:(i + 1) * step], "little")
    return sum(as_int(elem(vs1, i), sew) * as_int(elem(vs2, i), sew)
               for i in range(nlanes))


def dot_product_bcast(vs1: bytes, vs2: bytes, nlanes: int = NLANES_DEFAULT,
                        sew: int = SEW_DEFAULT) -> int:





    step = sew // 8
    scalar = as_int(int.from_bytes(vs1[0:step], "little"), sew)
    return sum(scalar * as_int(int.from_bytes(vs2[i * step:(i + 1) * step], "little"), sew)
               for i in range(nlanes))


def vdot_vd_bits(vs1: bytes, vs2: bytes, nlanes: int = NLANES_DEFAULT,
                 out_w: int = OUT_W_DEFAULT, vlen: int = VLEN_DEFAULT) -> int:

    acc = dot_product(vs1, vs2, nlanes)
    if out_w > vlen:
        raise ValueError("out_w exceeds VLEN")
    field = acc & ((1 << out_w) - 1)
    return field


def vdot_vd_bytes(vs1: bytes, vs2: bytes, nlanes: int = NLANES_DEFAULT,
                  out_w: int = OUT_W_DEFAULT, vlen: int = VLEN_DEFAULT) -> bytes:
    return vdot_vd_bits(vs1, vs2, nlanes, out_w, vlen).to_bytes(vlen // 8, "little")


def acc_range(nlanes: int = NLANES_DEFAULT, sew: int = SEW_DEFAULT) -> tuple:








    lo, hi = -(1 << (sew - 1)), (1 << (sew - 1)) - 1
    per_lane = [a * b for a in (lo, hi) for b in (lo, hi)]
    return min(per_lane) * nlanes, max(per_lane) * nlanes


def acc_bits_required(nlanes: int = NLANES_DEFAULT, sew: int = SEW_DEFAULT) -> int:








    lo, hi = acc_range(nlanes, sew)
    return max(hi.bit_length(), (-lo).bit_length()) + 1


if __name__ == "__main__":


    lo, hi = acc_range()
    assert (lo, hi) == (DOT_MIN, DOT_MAX), (lo, hi, DOT_MIN, DOT_MAX)




    assert dot_product(bytes([0xFE, 0x01]), bytes([0xFE, 0x01]), nlanes=1, sew=16,
                       allow_extension=True) == 510 * 510, "SEW=16 element read is wrong"
    assert acc_bits_required(8, 16) == 35, acc_bits_required(8, 16)
    assert hi == 131072 and lo == -130048
    assert not (-2**17 <= hi <= 2**17 - 1), "18 bits should be enough -- re-derive ACC_BITS_MIN"
    assert -2**18 <= hi <= 2**18 - 1 and -2**18 <= lo <= 2**18 - 1

    a = bytes([1, 2, 3, 4, 5, 6, 7, 8])
    b = bytes([1, 1, 1, 1, 1, 1, 1, 1])
    assert dot_product(a, b) == 36
    assert vdot_vd_bits(a, b, out_w=32) == 36
    assert vdot_vd_bits(a, b, out_w=8) == 36

    n = bytes([0x80] * 8)
    assert dot_product(n, n) == 131072
    assert vdot_vd_bits(n, n, out_w=32) == 131072
    assert vdot_vd_bits(n, n, out_w=8) == (131072 & 0xFF) == 0
    print("golden self-check OK  range=[%d, %d] acc_bits_min=%d" % (DOT_MIN, DOT_MAX, ACC_BITS_MIN))
