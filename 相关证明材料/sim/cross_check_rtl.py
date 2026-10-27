#!/usr/bin/env python3
# -*- coding: utf-8 -*-













from __future__ import annotations

import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, os.pardir))
GEN = os.path.join(ROOT, "gen", "chisel")
RESULTS = os.path.join(ROOT, "results")



CONFIGS = [(0, 8, 32, 19), (1, 8, 32, 19), (0, 8, 8, 19), (1, 8, 8, 19),
           (0, 16, 32, 20), (1, 16, 32, 20)]
GROUPS = ["pos", "neg", "bound", "rand"]
TB_REL = "tb/tb_vdot.sv"


def sh(cmd, cwd=None):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True,
                          encoding="utf-8", errors="replace")


def need_env():

    for p in (r"E:\msys64\ucrt64\bin",):
        if os.path.exists(os.path.join(p, "iverilog.exe")):
            os.environ["PATH"] = p + os.pathsep + os.environ.get("PATH", "")
            return True
    return False


def chisel_svs():
    out = {}
    if not os.path.isdir(GEN):
        return out
    for fn in os.listdir(GEN):
        m = re.fullmatch(r"VDotUnit_t(\d+)_n(\d+)_o(\d+)_a(\d+)\.sv", fn)
        if m:
            out[tuple(int(x) for x in m.groups())] = os.path.join(GEN, fn)
    return out


def run(rtl_path, defines, tag, cwd, chisel):
    vvp = "build/xc_%s.vvp" % tag
    cmd = ["iverilog", "-g2012", "-o", vvp]
    cmd += ["-D%s=%s" % (k, v) for k, v in defines.items()]
    if chisel:
        cmd += ["-DDUT_CHISEL"]
    cmd += [rtl_path.replace("\\", "/"), TB_REL]
    c = sh(cmd, cwd)
    if c.returncode != 0:
        return None, "compile: " + (c.stdout + c.stderr)[-500:]
    r = sh(["vvp", vvp], cwd)
    out = r.stdout + r.stderr
    got = dict(re.findall(r"CASE (\d+) (?:PASS|FAIL) vd=([0-9a-fx]+)", out))
    if "SUMMARY" not in out:
        return None, "no SUMMARY: " + out[-300:]
    return got, None


def main():
    os.chdir(ROOT)
    os.makedirs(RESULTS, exist_ok=True)
    if not need_env():
        print("iverilog not found on PATH; configure the MSYS2 ucrt64 bin directory")
        return 2
    svs = chisel_svs()
    if not svs:
        print("no generated Chisel SV in gen/chisel -- run mill first:")
        print("  see docs/00_build_environment.md")
        return 2

    lines, failures = [], []
    for cfg in CONFIGS:
        tree, nl, ow, accw = cfg
        if cfg not in svs:
            lines.append("SKIP %s : no Chisel netlist (regenerate with --tree %d --nlanes %d --outw %d)"
                         % (cfg, tree, nl, accw))
            continue
        for grp in GROUPS:
            case_rel = "tests/gen/cases_%s_n%d_o%d.txt" % (grp, nl, ow)
            if not os.path.exists(os.path.join(ROOT, case_rel)):
                failures.append("%s %s: case file missing" % (cfg, grp))
                continue
            d = {"NLANES_V": nl, "OUTW_V": ow, "ACCW_V": accw,
                 "TREE_V": tree, "CASE_FILE": '"%s"' % case_rel}
            a, ea = run(os.path.join(ROOT, "rtl", "xs_vdot_unit.sv"), d,
                        "gen_%s_%s" % ("_".join(map(str, cfg)), grp), ROOT, False)
            b, eb = run(svs[cfg], d, "chisel_%s_%s" % ("_".join(map(str, cfg)), grp), ROOT, True)
            if ea or eb:
                failures.append("%s %s: %s%s" % (cfg, grp, ea or "", eb or ""))
                continue
            diff = [k for k in sorted(set(a) | set(b), key=lambda x: int(x))
                    if a.get(k) != b.get(k)]
            status = "MATCH" if not diff else "DIFF %s" % diff[:6]
            lines.append("cfg t%d n%d o%d a%d %-6s cases=%d %s"
                         % (tree, nl, ow, accw, grp, len(a), status))
            if diff:
                failures.append("%s %s: %d cases differ, e.g. %s" % (cfg, grp, len(diff), diff[:5]))

    report = "\n".join(lines) + "\n\nFAILURES: %d\n" % len(failures)
    for f in failures:
        report += "  " + f + "\n"
    report += "CROSS_CHECK %s\n" % ("PASS" if not failures else "FAIL")
    with open(os.path.join(RESULTS, "cross_check_rtl.txt"), "w", encoding="utf-8", newline="\n") as fh:
        fh.write(report)



    sys.stdout.write(report.encode("ascii", "replace").decode("ascii"))
    return 0 if not failures else 1


if __name__ == "__main__":
    sys.exit(main())
