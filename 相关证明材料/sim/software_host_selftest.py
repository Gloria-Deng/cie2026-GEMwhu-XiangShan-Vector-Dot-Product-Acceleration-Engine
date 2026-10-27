#!/usr/bin/env python3
# -*- coding: utf-8 -*-
































from __future__ import annotations

import argparse
import hashlib
import io
import os
import random
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, os.pardir))
BUILD = os.path.join(ROOT, "build")
RESULTS = os.path.join(ROOT, "results")
SW = os.path.join(ROOT, "software")

GCC_CANDIDATES = (
    r"E:\msys64\usr\bin\gcc.exe",
    r"E:\msys64\ucrt64\bin\gcc.exe",
    "gcc",
)

RAND_N = 10000
SEED = 20261008


def sha256_of(path):
    h = hashlib.sha256()
    with io.open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def find_gcc():
    for cand in GCC_CANDIDATES:
        if cand == "gcc" and shutil.which("gcc"):
            return shutil.which("gcc")
        if os.path.exists(cand):
            return cand
    return None


def py_model(a, b):



    return sum(int(a[i]) * int(b[i]) for i in range(8))


def gen_cases():
    rng = random.Random(SEED)
    cases = []
    for _ in range(RAND_N):
        a = [rng.randint(-128, 127) for _ in range(8)]
        b = [rng.randint(-128, 127) for _ in range(8)]
        cases.append((a, b))
    return cases


def run():
    gcc = find_gcc()
    if not gcc:
        print("SOFTWARE-HOST-SELFTEST VERDICT FAIL (no gcc found)")
        return 1

    os.makedirs(BUILD, exist_ok=True)
    exe_st = os.path.join(BUILD, "software_selftest.exe")
    exe_gm = os.path.join(BUILD, "software_gemm.exe")





    env = dict(os.environ)
    env["PATH"] = os.path.dirname(gcc) + os.pathsep + env.get("PATH", "")

    notes = []
    for src, exe in ((os.path.join(SW, "selftest.c"), exe_st),
                     (os.path.join(SW, "kernels", "gemm_i8.c"), exe_gm)):
        r = subprocess.run([gcc, "-O2", "-I", os.path.join(SW, "include"),
                            src, "-o", exe],
                           capture_output=True, text=True, env=env)
        if r.returncode != 0:
            notes.append("COMPILE-FAIL %s rc=%d" % (os.path.basename(src), r.returncode))
            print("\n".join(notes))
            print("SOFTWARE-HOST-SELFTEST VERDICT FAIL (compile)")
            return 1
        notes.append("COMPILE-OK %s" % os.path.basename(src))

    cases = gen_cases()
    stdin_text = "\n".join(
        " ".join(str(x) for x in (a + b)) for a, b in cases) + "\n"

    r = subprocess.run([exe_st], input=stdin_text, capture_output=True,
                       text=True, env=env, timeout=300)
    out = r.stdout.splitlines()

    case_rows = [l for l in out if l.startswith("CASE ")]
    if len(case_rows) != RAND_N:
        notes.append("CASE-ROWS-Short got=%d want=%d" % (len(case_rows), RAND_N))

    py_bad = c_pair_bad = 0
    for idx, (a, b) in enumerate(cases):
        want = py_model(a, b)
        row = case_rows[idx].split()
        ref, alt = int(row[2]), int(row[3])
        if ref != want:
            py_bad += 1
        if ref != alt:
            c_pair_bad += 1
    notes.append("COLLIDE python_vs_c_ref=%d c_ref_vs_c_alt=%d of %d"
                 % (py_bad, c_pair_bad, RAND_N))

    verdict_st = [l for l in out if l.startswith("VDOT-SELFTEST VERDICT")]
    notes.append("[selftest-out] " + " | ".join(
        l for l in out if not l.startswith("CASE ")))

    r2 = subprocess.run([exe_gm], capture_output=True, text=True,
                        env=env, timeout=300)
    gm_out = r2.stdout.splitlines()
    verdict_gm = [l for l in gm_out if l.startswith("GEMM-REF-EQUIV")]
    notes.append("[gemm-out] " + " | ".join(
        l for l in gm_out if not l.startswith("GEMM-MISMATCH")))
    gm_bad = sum(1 for l in gm_out if l.startswith("GEMM-MISMATCH"))
    notes.append("GEMM mismatch_rows=%d" % gm_bad)

    ok = (r.returncode == 0 and r2.returncode == 0
          and len(case_rows) == RAND_N
          and py_bad == 0 and c_pair_bad == 0 and gm_bad == 0
          and verdict_st == ["VDOT-SELFTEST VERDICT PASS"]
          and verdict_gm == ["GEMM-REF-EQUIV VERDICT PASS"])

    lines = [
        "SOFTWARE-HOST-SELFTEST v1",
        "question: software/ 的两条 C 路径、独立 Python 模型与 GEMM 双臂在宿主上"
        "是否全部一致（本机 gcc，%d 例随机 + 5 例定向 + 4 档 K）？" % RAND_N,
        "answer: " + ("一致" if ok else "不一致") +
        "（逐档判读行见下方 [selftest-out]/[gemm-out]，碰撞计数见 COLLIDE 行）",
        "scope: 只覆盖本机宿主的 C 路径；不含任何 RISC-V 执行、周期读数或"
        "汇编臂——那些是 docs/11 的待办，不在本归档的声称范围内",
        "[gcc] %s" % subprocess.run([gcc, "--version"], capture_output=True,
                                    text=True).stdout.splitlines()[0],
        "[src] sha256_selftest_c=%s" % sha256_of(os.path.join(SW, "selftest.c")),
        "[src] sha256_vdot_vv_h=%s" % sha256_of(
            os.path.join(SW, "include", "vdot_vv.h")),
        "[src] sha256_gemm_i8_c=%s" % sha256_of(
            os.path.join(SW, "kernels", "gemm_i8.c")),
        "[src] sha256_stdin_blob=%s" % hashlib.sha256(
            stdin_text.encode("utf-8")).hexdigest(),
    ] + notes + [
        "SOFTWARE-HOST-SELFTEST VERDICT %s" % ("PASS" if ok else "FAIL"),
    ]
    txt = "\n".join(lines) + "\n"
    dst = os.path.join(RESULTS, "software_host_selftest.txt")
    with io.open(dst, "w", encoding="utf-8", newline="") as f:
        f.write(txt)
    print(txt)
    return 0 if ok else 1


def selftest():



    rng = random.Random(SEED)
    broken = 0
    for _ in range(200):
        a = [rng.randint(-128, 127) for _ in range(8)]
        b = [rng.randint(-128, 127) for _ in range(8)]
        if py_model(a, b) != sum(int(a[i]) * int(b[i]) for i in range(8)):
            broken += 1
    if broken == 0:
        print("SOFTWARE-HOST-SELFTEST --selftest: py_model and its inline "
              "re-derivation agree on 200 cases, as they must (both "
              "transcribe the same loop); the bite direction is the "
              "COLLIDE counters, exercised on every real run.")
        return 0
    print("SOFTWARE-HOST-SELFTEST --selftest: unexpected disagreement")
    return 1


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--selftest", action="store_true")
    args = ap.parse_args()
    if args.selftest:
        return selftest()
    return run()


if __name__ == "__main__":
    sys.exit(main())
