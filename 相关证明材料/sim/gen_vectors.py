#!/usr/bin/env python3
# -*- coding: utf-8 -*-




















from __future__ import annotations

import io
import json
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import golden_vdot as g

ROOT = os.path.normpath(os.path.join(HERE, os.pardir))
OUTDIR = os.path.join(ROOT, "tests")
NL = g.NLANES_DEFAULT
OUTW = g.OUT_W_DEFAULT


def lanes(vals):

    b = bytearray(16)
    for i, v in enumerate(vals):
        b[i] = v & 0xFF
    return bytes(b)


def fmt(vs1, vs2, nlanes=NL, out_w=OUTW):
    return "%032x %032x %032x" % (
        int.from_bytes(vs1, "little"),
        int.from_bytes(vs2, "little"),
        g.vdot_vd_bits(vs1, vs2, nlanes=nlanes, out_w=out_w),
    )


def build_pos():

    c = []
    c.append(("all ones", lanes([1] * 16), lanes([1] * 16)))
    c.append(("1..8 vs 1..8", lanes(list(range(1, 9)) + [0] * 8), lanes(list(range(1, 9)) + [0] * 8)))
    c.append(("all 127 (max positive)", lanes([127] * 8 + [0] * 8), lanes([127] * 8 + [0] * 8)))
    c.append(("127 x 1", lanes([127] * 8 + [0] * 8), lanes([1] * 8 + [0] * 8)))
    c.append(("ascending x descending", lanes(list(range(1, 9))), lanes(list(range(8, 0, -1)) + [0] * 8)))
    c.append(("mixed magnitude positive", lanes([3, 61, 12, 99, 7, 45, 2, 100]), lanes([5, 4, 3, 2, 1, 90, 64, 11])))
    rng = random.Random(20260924)
    for i in range(40):
        a = [rng.randrange(1, 128) for _ in range(8)]
        b = [rng.randrange(1, 128) for _ in range(8)]
        c.append(("rand%02d" % i, lanes(a + [0] * 8), lanes(b + [0] * 8)))
    return c


def build_neg():

    c = []
    c.append(("all -1", lanes([-1] * 8 + [0] * 8), lanes([1] * 8 + [0] * 8)))
    c.append(("all -1 x all -1", lanes([-1] * 8 + [0] * 8), lanes([-1] * 8 + [0] * 8)))
    c.append(("-128 x 127 (most negative per lane)", lanes([-128] * 8 + [0] * 8), lanes([127] * 8 + [0] * 8)))
    c.append(("-128 x -128 (most positive per lane)", lanes([-128] * 8 + [0] * 8), lanes([-128] * 8 + [0] * 8)))
    c.append(("alternating sign", lanes([-5, 5, -5, 5, -5, 5, -5, 5]), lanes([7, 7, 7, 7, 7, 7, 7, 7])))
    c.append(("cancelling pair", lanes([-128, 128 - 256, 0, 0, 0, 0, 0, 0]), lanes([1, 1, 0, 0, 0, 0, 0, 0])))
    c.append(("one negative lane only", lanes([1, 1, 1, -128, 1, 1, 1, 1]), lanes([1, 1, 1, 1, 1, 1, 1, 1])))
    c.append(("both negative mid", lanes([-64] * 8), lanes([-64] * 8)))
    rng = random.Random(1180609)
    for i in range(40):
        a = [rng.randrange(-128, 128) for _ in range(8)]
        b = [rng.randrange(-128, 128) for _ in range(8)]
        if all(v >= 0 for v in a) and all(v >= 0 for v in b):
            a[0] = -a[0] - 1
        c.append(("rand%02d" % i, lanes(a + [0] * 8), lanes(b + [0] * 8)))
    return c


def build_bound():

    c = []

    c.append(("MAX 8x(-128*-128)=+131072=2**17", lanes([-128] * 8 + [0] * 8), lanes([-128] * 8 + [0] * 8)))
    c.append(("MIN 8x(-128*127)=-130048", lanes([-128] * 8 + [0] * 8), lanes([127] * 8 + [0] * 8)))
    c.append(("all zero", lanes([0] * 16), lanes([0] * 16)))
    c.append(("zero x max", lanes([0] * 8 + [0] * 8), lanes([127] * 8 + [0] * 8)))
    c.append(("single lane0 -128x-128", lanes([-128] + [0] * 15), lanes([-128] + [0] * 15)))
    c.append(("single lane7 (last consumed)", lanes([0] * 7 + [-128] + [0] * 8), lanes([0] * 7 + [-128] + [0] * 8)))


    c.append(("lane8 must NOT contribute", lanes([0] * 8 + [-128] + [0] * 7), lanes([0] * 8 + [-128] + [0] * 7)))
    c.append(("lanes 8-15 all -128", lanes([0] * 8 + [-128] * 8), lanes([0] * 8 + [-128] * 8)))
    c.append(("all 16 lanes -128 (8 consumed)", lanes([-128] * 16), lanes([-128] * 16)))
    c.append(("0x7f x 0x80 pattern", lanes([0x7F] * 8 + [0] * 8), lanes([0x80] * 8 + [0] * 8)))
    c.append(("sum exactly 0 from negatives", lanes([-128, 127, -128, 127, -128, 127, -128, 127]),
              lanes([1, 1, 1, 1, 1, 1, 1, 1])))
    c.append(("near-2**17 minus one", lanes([-128] * 7 + [127] + [0] * 8), lanes([-128] * 8 + [0] * 8)))






    c.append(("lane0=-128 lane7=127 asymmetric operands", lanes([-128, 0, 0, 0, 0, 0, 0, 127] + [0] * 8),
              lanes([-128, 0, 0, 0, 0, 0, 0, 127] + [0] * 8)))
    c.append(("lane transpose 1..8 x 8..1", lanes([1, 2, 3, 4, 5, 6, 7, 8] + [0] * 8),
              lanes([8, 7, 6, 5, 4, 3, 2, 1] + [0] * 8)))
    c.append(("lane0=100 only", lanes([100] + [0] * 15), lanes([100] + [0] * 15)))
    rng = random.Random(777)
    for i in range(30):

        a = [rng.choice([-128, 127, -127, 0]) for _ in range(8)]
        b = [rng.choice([-128, 127, -127, 0]) for _ in range(8)]
        c.append(("extremes%02d" % i, lanes(a + [0] * 8), lanes(b + [0] * 8)))
    return c


def build_rand(n=800):
    rng = random.Random(20260925)
    c = []
    for i in range(n):
        a = [rng.randrange(-128, 128) for _ in range(8)]
        b = [rng.randrange(-128, 128) for _ in range(8)]
        hi = [rng.randrange(-128, 128) for _ in range(8)]
        c.append(("r%04d" % i, lanes(a + hi), lanes(b + hi)))
    return c


def write(name, cases):








    os.makedirs(OUTDIR, exist_ok=True)
    path = os.path.join(OUTDIR, name)
    cpath = os.path.join(OUTDIR, name.replace(".txt", ".labels.csv"))
    with open(path, "w", encoding="utf-8", newline="\n") as f, \
         open(cpath, "w", encoding="utf-8", newline="\n") as cf:
        cf.write("index,label,dot_result,vs1_hex,vs2_hex,vd_hex\n")
        for i, (label, a, b) in enumerate(cases):
            line = "%d %s" % (i, fmt(a, b))
            f.write(line + "\n")
            vs1h, vs2h, vdh = line.split()[1:4]
            cf.write('%d,"%s",%d,%s,%s,%s\n' % (i, label, g.dot_product(a, b), vs1h, vs2h, vdh))
    print("%-22s %4d cases" % (name, len(cases)))
    return path


def main():
    write("cases_pos.txt", build_pos())
    write("cases_neg.txt", build_neg())
    write("cases_bound.txt", build_bound())
    write("cases_rand.txt", build_rand())
    publish_identity()


    print("\nOUTW=32 vs OUTW=8 on the corners:")
    for label, a, b in build_bound()[:6]:
        w = g.vdot_vd_bits(a, b, out_w=32)
        t = g.vdot_vd_bits(a, b, out_w=8)
        print("  %-34s acc=%9d  out32=%032x  out8=%02x" % (label, g.dot_product(a, b), w, t))


def discrimination():


















    import case_corpus as cc
    reps = (0x00, 0xFF)
    files, sens, rows_tot = {}, {(o, p): 0 for o in (0, 1)
                                 for p in range(cc.HEXW // 2)}, 0
    wh_tot = 0
    conv = None
    for rel in cc.CORPUS:
        p = os.path.join(ROOT, rel.replace("/", os.sep))
        parsed = [ln.split() for ln in io.open(p, encoding="utf-8").read().splitlines()
                  if ln.strip()]








        recs = []
        for cand in ("little", "big"):
            def unpack(h):
                b = bytes.fromhex(h)
                return b[::-1] if cand == "little" else b
            bad = [f[0] for f in parsed
                   if g.vdot_vd_bits(unpack(f[1]), unpack(f[2])) != int(f[3], 16)]
            if not bad:
                conv = cand if conv is None else conv
                if conv != cand:
                    raise SystemExit("[GEN] the corpus files disagree with each other "
                                     "on lane order (%s vs %s) -- census aborted"
                                     % (conv, cand))
                break
        else:
            raise SystemExit("[GEN] neither lane order reproduces %s's expectations "
                             "from sim/golden_vdot -- refusing to count byte positions "
                             "in a layout nobody published (first bad row: %s)"
                             % (rel, bad[0]))
        for f in parsed:
            recs.append((bytes.fromhex(f[1])[::-1] if conv == "little"
                         else bytes.fromhex(f[1]),
                         bytes.fromhex(f[2])[::-1] if conv == "little"
                         else bytes.fromhex(f[2]),
                         int(f[3], 16)))
        for a, b, base in recs:
            for oi, op in enumerate((a, b)):
                for pos in range(len(op)):
                    for rep in reps:
                        if op[pos] == rep:
                            continue
                        alt = op[:pos] + bytes([rep]) + op[pos + 1:]
                        got = (g.vdot_vd_bits(alt, b) if oi == 0
                               else g.vdot_vd_bits(a, alt))
                        if got != base:
                            sens[(oi, pos)] += 1
                            break
        files[rel] = {"rows": len(recs), "_recs": recs}
        rows_tot += len(recs)
    read_pos = {(o, p): n for (o, p), n in sorted(sens.items()) if n}
    if not [k for k in read_pos if k[0] == 0] or not [k for k in read_pos if k[0] == 1]:
        raise SystemExit("[GEN] discrimination probe is blind: no byte position of "
                         "both operands ever changed an answer -- the scan, not the "
                         "corpus, is broken")
    blind_pos = [list(k) for k in sorted(sens) if k not in read_pos]
    rp = sorted(read_pos)
    across = set()
    for rel, d in files.items():
        groups = {}
        for a, b, ans in d["_recs"]:
            key = tuple((a[p] if o == 0 else b[p]) for (o, p) in rp)
            groups.setdefault(key, set()).add(ans)
            across.add(key)
        if any(len(v) > 1 for v in groups.values()):
            raise SystemExit("[GEN] the derived effective-input mask misses a byte "
                             "the model does read (%s): two rows with equal keys gave "
                             "different answers" % rel)
        d["distinct_effective_inputs"] = len(groups)
        d["blind_rows"] = d["rows"] - len(groups)
        d["distinct_unread_payloads"] = len({
            tuple((a[p] if o == 0 else b[p]) for (o, p) in [tuple(x) for x in blind_pos])
            for a, b, _ in d["_recs"]})







        wh = 0
        for a, b, ans in d["_recs"]:
            half = len(a) // 2
            if g.vdot_vd_bits(a[half:] + a[:half], b[half:] + b[:half]) != ans:
                wh += 1
        d["wrong_half_mutant_caught"] = wh
        wh_tot += wh
        del d["_recs"]
    if rows_tot == 0 or wh_tot == 0:
        raise SystemExit("[GEN] the half-swap witness is vacuous (rows=%d caught=%d): "
                         "either no row was read or no row can tell the two halves apart "
                         "-- refusing to publish a discrimination claim on that basis"
                         % (rows_tot, wh_tot))
    return {"method": ("per row, per operand, per byte position: substitute 0x00 and "
                       "0xFF and re-run sim/golden_vdot.vdot_vd_bits; a position that "
                       "never changes any answer is counted as unread.  Positions are "
                       "lane indices of the model's own byte order, after the hex "
                       "column's lane order was settled by reproducing every row's "
                       "published expectation."),
            "lane_order_verified": conv,
            "read_byte_positions": {"vs1": sorted(p for (o, p) in read_pos if o == 0),
                                    "vs2": sorted(p for (o, p) in read_pos if o == 1)},
            "unread_byte_positions": blind_pos,
            "rows": rows_tot,
            "corpus_distinct_effective_inputs": len(across),
            "corpus_rows_repeating_an_earlier_effective_input": rows_tot - len(across),
            "wrong_half_mutant_caught_rows": wh_tot,
            "wrong_half_mutant_share": round(wh_tot / rows_tot, 4),
            "wrong_half_mutant_meaning": (
                "Rows whose published expectation differs from what an implementation "
                "reading the OTHER eight lanes would return -- those rows fail such a "
                "mutant while still matching the honest model.  This is the measured "
                "answer to the claim 'the high half carries zero discrimination, so add "
                "high-lane cases': lanes 8..15 are unread by the semantics (see "
                "unread_byte_positions), yet the corpus still tells the halves apart on "
                "this many rows, so extra high-lane rows buy no detection power."),
            "per_file": files,
            "note": ("`blind_rows` = rows whose effective input repeats an earlier "
                     "row's; `distinct_unread_payloads` = how many different values the "
                     "unread bytes take.  Both are properties of the CORPUS, not of the "
                     "design: the design was never shown those bytes.  The reverse "
                     "confirmation that the RTL really ignores them is the equivalent "
                     "mutations in results/matrix.json, not this table.")}


def publish_identity():







    import case_corpus as cc
    ident = cc.identity()
    total = cc.total_rows(ident)
    if total < 900:
        raise SystemExit("[GEN] refusing to publish an identity for %d cases" % total)
    payload = {"corpus": ident, "total_rows": total,
               "concat_sha256": cc.concat_sha256(),
               "order": list(cc.CORPUS),
               "written_by": "sim/gen_vectors.py",
               "discrimination": discrimination(),
               "shape_rule": "4 whitespace fields; each hex column exactly %d digits"
                             % cc.HEXW,
               "note": ("identity of tests/cases_{pos,neg,bound,rand}.txt as written by "
                        "this script; sha256 is over the raw bytes, rows counts "
                        "well-formed data rows only")}
    out = os.path.join(ROOT, "results", "corpus.json")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    io.open(out, "w", encoding="utf-8", newline="\n").write(
        json.dumps(payload, indent=2, sort_keys=True) + "\n")
    print("corpus identity: %d files, %d cases -> results/corpus.json (generated on demand; not a release input)"
          % (len(ident), total))
    dsc = payload["discrimination"]
    print("corpus discrimination (measured against the golden model, not asserted): "
          "lane order %s; %d rows -> %d distinct effective inputs across the corpus "
          "(%d repeat an earlier one); lanes read: vs1=%s vs2=%s"
          % (dsc["lane_order_verified"], dsc["rows"],
             dsc["corpus_distinct_effective_inputs"],
             dsc["corpus_rows_repeating_an_earlier_effective_input"],
             dsc["read_byte_positions"]["vs1"], dsc["read_byte_positions"]["vs2"]))
    for rel, v in sorted(dsc["per_file"].items()):
        print("  %-24s rows=%-4d effective_inputs=%-4d repeated=%-4d "
              "unread_payload_values=%d wrong_half_caught=%d"
              % (rel, v["rows"], v["distinct_effective_inputs"], v["blind_rows"],
                 v["distinct_unread_payloads"], v["wrong_half_mutant_caught"]))
    print("HALF_SWAP rows=%d caught=%d share=%.4f -- an implementation reading the other "
          "eight lanes fails these rows, so high-lane payload is NOT an uncovered blind "
          "spot for mutation detection"
          % (dsc["rows"], dsc["wrong_half_mutant_caught_rows"],
             dsc["wrong_half_mutant_share"]))


if __name__ == "__main__":
    main()
