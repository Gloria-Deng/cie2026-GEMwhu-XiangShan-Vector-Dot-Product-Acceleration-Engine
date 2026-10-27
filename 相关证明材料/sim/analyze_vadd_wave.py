#!/usr/bin/env python3
# -*- coding: utf-8 -*-













from __future__ import annotations

import io
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))




VCD = os.path.join(HERE, os.pardir, "results", "wave_vadd.vcd")
OUT = os.path.join(HERE, os.pardir, "results", "vadd_waveform.txt")

WATCH = ["clock", "valid", "dut.valid_r", "wb_valid", "wb_idx", "vd_out", "sew", "vl"]


def parse(path):
    text = io.open(path, encoding="utf-8", errors="replace").read()

    ids = {}
    scope = []
    for line in text.splitlines():
        s = line.strip()
        if s.startswith("$scope"):
            m = re.search(r"\$\scope\s+(\w+)\s+(\S+)", s)
            if m:
                scope.append(m.group(2))
        elif s.startswith("$upscope"):
            if scope:
                scope.pop()
        elif s.startswith("$var"):
            m = re.search(r"\$var\s+\w+\s+\S+\s+(\S+)\s+(\S+)", s)
            if m:
                ident, name = m.group(1), m.group(2)
                full = ".".join(scope[1:] + [name]) if len(scope) > 1 else name
                ids.setdefault(full, ident)
                ids.setdefault(name, ident)





    inv = {}
    for name, ident in ids.items():
        inv.setdefault(ident, []).append(name)

    body = text.split("$enddefinitions", 1)[1]
    t = 0
    changes = []
    for line in body.splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith("#"):
            t = int(line[1:])
            continue



        def record(ident, value):
            for nm in inv.get(ident, ()):
                changes.append((t, nm, value))

        if line[0] in "01xzXZ" and " " not in line:
            record(line[1:], line[0])
        elif line.startswith("r") or (line[0] in "01" and line[1:2] == "!"):
            parts = line.split()
            if len(parts) >= 2:
                record(parts[-1], parts[0])
        elif line[0] in "bB":
            parts = line.split()
            if len(parts) == 2:
                record(parts[1], parts[0][1:])
    return changes


SLICES = ("res_lo", "res_hi")


def slice_stats(changes):








    out = {}
    for nm in SLICES:
        vals = [v for _t, s, v in changes if s == nm]
        out[nm] = (len(vals), len(set(vals)), set(vals))
    return out


def main():
    path = VCD
    if not os.path.exists(path):
        print("no VCD at %s -- run the vadd bench with +DUMP first"
              % os.path.relpath(path, os.path.join(HERE, os.pardir)))
        return 1
    changes = parse(path)
    if not changes:


        print("PARSED 0 signal changes from %s -- id map failed, refusing to report" % path)
        return 1





    clk = [t for t, s, v in changes if s == "clock"]
    period = (clk[2] - clk[0]) if len(clk) >= 3 else ((clk[1] - clk[0]) * 2 if len(clk) >= 2 else 2000)

    try:
        shown = os.path.relpath(path, HERE).replace(os.sep, "/")
    except ValueError:
        shown = path.replace(os.sep, "/")
    lines = ["source VCD: %s" % shown,
             "total value changes parsed: %d" % len(changes),
             "clock period from the trace: %d ps" % period, ""]


    req = next((t for t, s, v in changes if s == "valid" and v == "1"), None)
    if req is None:
        lines.append("no asserted `valid` edge found in the trace")
    else:
        lines.append("scenario 0 request edge (valid -> 1) at t=%dns = cycle %d"
                     % (req, req // period))
        lines.append("")
        lines.append("cycle  t(ns)  event")
        seen = set()
        rows = []
        for t, s, v in changes:
            if s not in WATCH or t < req - period:
                continue
            if s in ("sew", "vl") and t != req:
                continue
            key = (s, v)
            if key in seen:
                continue
            seen.add(key)
            rows.append((t, s, v))
        for t, s, v in sorted(rows)[:24]:
            lines.append("%6d %7d  %s = %s" % (t // period, t, s, v))
        lines.append("")
        cap = next((t for t, s, v in changes if s == "dut.valid_r" and v == "1"), None)
        wb = next((t for t, s, v in changes if s == "wb_valid" and v == "1"), None)
        fpr = next((t for t, s, v in changes if s.startswith("dut.fpr")), None)
        lines.append("latency read off the trace:")
        if cap is not None and req is not None:
            lines.append("  request -> stage register captured : %d ns = %d cycles"
                         % (cap - req, (cap - req) // period))
        if wb is not None and req is not None:
            lines.append("  request -> wb_valid asserted       : %d ns = %d cycles"
                         % (wb - req, (wb - req) // period))
        if fpr is not None and req is not None:
            lines.append("  request -> destination register written : %d ns = %d cycles"
                         % (fpr - req, (fpr - req) // period))
        lines.append("")
        lines.append("What the trace cannot show: the real design splits vadd.vv")
        lines.append("into micro-ops and the destination write-back competes with")
        lines.append("other write ports; this model has one FU and one port, so the")
        lines.append("cycle counts here are the model's, not measured Kunminghu")
        lines.append("timing. They are quoted as 'the pipeline depth the model was")
        lines.append("built to', and the design documents say so.")


    stat = slice_stats(changes)
    rc = 0
    dead = [nm for nm in SLICES if stat[nm][0] == 0]
    if dead:
        print("SLICE-VISIBILITY: no value changes for %s -- docs/02 quotes readings off "
              "these two signals, so printing a number for a signal the trace never "
              "toggled would be the report inventing its own evidence" % ", ".join(dead))
        rc = 1
    differ = stat[SLICES[0]][2] != stat[SLICES[1]][2]
    lines.append("")
    lines.append("slice visibility (counted from the id->name map, NOT from a grep for "
                 "the name -- a VCD mentions each signal once in its header):")
    for nm in SLICES:
        lines.append("  %-8s %d value changes, %d distinct values"
                     % (nm, stat[nm][0], stat[nm][1]))
    lines.append("  both slices together: %d changes"
                 % sum(stat[nm][0] for nm in SLICES))
    lines.append("  the two value sets are different: %s" % ("yes" if differ else "NO"))
    if not differ and rc == 0:


        print("SLICE-VISIBILITY: res_lo and res_hi show the SAME value set -- docs/02's "
              "「两个集合不相同」 is no longer true of this trace")
        rc = 1
    lines.append("SLICE_VISIBILITY %s" % ("ok" if rc == 0 else "FAIL"))

    io.open(OUT, "w", encoding="utf-8", newline="\n").write("\n".join(lines) + "\n")
    sys.stdout.write("\n".join(lines).encode("ascii", "replace").decode("ascii")[:1800] + "\n")
    if "--selftest" in sys.argv:
        return selftest() or rc
    return rc


def selftest():

    problems = []
    fake = [(0, "res_lo", "b0"), (10, "res_lo", "b1"), (20, "res_lo", "b0"),
             (30, "res_hi", "b1"), (40, "res_hi", "b1")]
    st = slice_stats(fake)
    if st["res_lo"][:2] != (3, 2):
        problems.append("synthetic res_lo chain gave %s, expected 3 changes / 2 distinct"
                        % (st["res_lo"][:2],))
    if st["res_hi"][:2] != (2, 1):
        problems.append("synthetic res_hi chain gave %s, expected 2 changes / 1 distinct"
                        % (st["res_hi"][:2],))
    if st["res_lo"][2] == st["res_hi"][2]:
        problems.append("the two synthetic value sets compared equal -- the differ check "
                        "cannot tell a shared set from a distinct one")
    empty = slice_stats([(0, "clock", "1")])
    if empty["res_lo"][0] != 0 or empty["res_hi"][0] != 0:
        problems.append("a trace with no slice changes did NOT read as zero -- the "
                        "fail-closed branch would never fire")
    print("[WAVE-SLICE-SELFTEST] problems=%d" % len(problems))
    for p in problems:
        print("  !! " + p)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
