#!/usr/bin/env python3
# -*- coding: utf-8 -*-









from __future__ import annotations

import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, os.pardir))
CASE = "tests/cases_vadd.txt"


def sh(cmd):
    return subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True,
                          encoding="utf-8", errors="replace")


def main():
    os.chdir(ROOT)
    os.makedirs("build", exist_ok=True)
    os.makedirs("results", exist_ok=True)
    for p in (r"E:\msys64\ucrt64\bin", r"E:\msys64\usr\bin"):
        if os.path.isdir(p):
            os.environ["PATH"] = p + os.pathsep + os.environ.get("PATH", "")

    if not os.path.exists(CASE):
        print("case file %s missing -- run sim/gen_vadd_vectors.py first" % CASE)
        return 2

    c = sh(["iverilog", "-g2012", "-o", "build/tb_vadd.vvp",
            '-DCASE_FILE="%s"' % CASE, "rtl/vadd_vv_path.sv", "tb/tb_vadd.sv"])
    if c.returncode != 0:
        print("compile failed:\n" + (c.stdout + c.stderr)[-1500:])
        return 1

    r = sh(["vvp", "build/tb_vadd.vvp", "+DUMP"])
    out = (r.stdout or "") + (r.stderr or "")
    with open(os.path.join("results", "vadd_sim.txt"), "w", encoding="utf-8",
              newline="\n") as f:
        f.write(out)

    m = re.search(r"SUMMARY vadd total=(\d+) pass=(\d+) fail=(\d+)", out)
    if not m:


        print("BROKEN: no SUMMARY line in the vvp output:\n" + out[-800:])
        return 1
    total, npass, nfail = map(int, m.groups())
    if total == 0:
        print("BROKEN: 0 cases parsed from %s" % CASE)
        return 1







    here_vcd = "wave_vadd.vcd"
    build_vcd = os.path.join("build", "wave_vadd.vcd")
    dst_vcd = os.path.join("results", "wave_vadd.vcd")
    src_vcd = here_vcd if os.path.exists(here_vcd) else (
        build_vcd if os.path.exists(build_vcd) else None)
    if src_vcd:
        import shutil
        shutil.move(src_vcd, dst_vcd)
        for stale in (here_vcd, build_vcd):
            if os.path.exists(stale):
                os.remove(stale)
        a = sh([sys.executable, "sim/analyze_vadd_wave.py", "--selftest"])
        if a.returncode != 0:
            print("waveform analysis failed:\n" + (a.stdout + a.stderr)[-800:])
            return 1
    else:
        print("BROKEN: no wave_vadd.vcd was produced to analyse (looked in . and build/)")
        return 1

    print("vadd: total=%d pass=%d fail=%d" % (total, npass, nfail))
    if nfail != 0:
        print("VADD FAIL")
        return 1
    print("VADD PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
