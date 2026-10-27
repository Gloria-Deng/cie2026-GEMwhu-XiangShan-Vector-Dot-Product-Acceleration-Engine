#!/usr/bin/env python3
# -*- coding: utf-8 -*-































from __future__ import annotations

import io
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, os.pardir))
sys.path.insert(0, HERE)
from gen_vdot_rtl import (GATE_VS1, GATE_VS2, ZEXT_VS1, ZEXT_VS2, PROD_SLICE,
                          SEW as PINNED_SEW)

import golden_vdot as g
import gen_vectors as gv

GEN_REL = "tests/gen"
RTL_REL = "rtl/xs_vdot_unit.sv"
TB_REL = "tb/tb_vdot.sv"
GROUPS = ["pos", "neg", "bound", "rand"]


CONFIGS = [
    (0, 8, 32, 19, "pinned spec case, balanced CPA tree"),
    (1, 8, 32, 19, "pinned spec case, carry-save tree"),
    (0, 8, 8, 19, "literal 8-bit-truncation reading of vd[0]"),
    (1, 8, 8, 19, "literal reading, carry-save tree"),
    (0, 16, 32, 20, "extension: all 16 int8 lanes of a VLEN=128 register"),
    (1, 16, 32, 20, "extension, carry-save tree"),
    (2, 8, 32, 19, "positive control: serial accumulator, must be functionally identical"),
]

SPEC = dict(nlanes=8, outw=32, accw=19, tree=0)





def _wrap(acc, accw, outw):

    field = acc & ((1 << accw) - 1)
    if field >> (accw - 1):
        field -= 1 << accw
    return field & ((1 << outw) - 1)


def _sum(vs1, vs2, lanes, amap, bmap):
    return sum(amap(vs1[i]) * bmap(vs2[i]) for i in lanes)


S8 = g.as_int8
U8 = lambda b: b & 0xFF

MUT_MODELS = {


    "M1_gate_vs1_only": lambda a, b: _sum(a, b, range(8), S8, S8),
    "M2_gate_vs2_only": lambda a, b: _sum(a, b, range(8), S8, S8),
    "M3_gate_both":     lambda a, b: _sum(a, b, range(16), S8, S8),
    "M4_zext_vs1":      lambda a, b: _sum(a, b, range(8), U8, S8),
    "M5_zext_vs2":      lambda a, b: _sum(a, b, range(8), S8, U8),
    "M6_drop_lane0":    lambda a, b: _sum(a, b, range(1, 8), S8, S8),
    "M7_double_lane7":  lambda a, b: _sum(a, b, range(8), S8, S8) + S8(a[7]) * S8(b[7]),
}


MUTATIONS = [
    ("M1_gate_vs1_only", GATE_VS1,
     "assign vs1g[gl*8 +: 8] = vs1w[gl*8 +: 8];",
     "M1_gate_vs1_only", "lane gate dropped on vs1 alone -- expected EQUIVALENT"),
    ("M2_gate_vs2_only", GATE_VS2,
     "assign vs2g[gl*8 +: 8] = vs2w[gl*8 +: 8];",
     "M2_gate_vs2_only", "lane gate dropped on vs2 alone -- expected EQUIVALENT"),
    ("M3_gate_both", GATE_VS1,
     "assign vs1g[gl*8 +: 8] = vs1w[gl*8 +: 8];",
     "M3_gate_both", "both lane gates dropped: lanes 8-15 leak into the dot product"),
    ("M4_zext_vs1", ZEXT_VS1,
     "wire [2*SEW-1:0] ae = {{SEW{1'b0}}, av};",
     "M4_zext_vs1", "vs1 zero-extended instead of sign-extended"),
    ("M5_zext_vs2", ZEXT_VS2,
     "wire [2*SEW-1:0] be = {{SEW{1'b0}}, bv};",
     "M5_zext_vs2", "vs2 zero-extended instead of sign-extended"),
    ("M6_drop_lane0", PROD_SLICE,
     "assign prod_comb[gp] = (gp == 0) ? {ACCW{1'b0}} : pe[ACCW-1:0];",
     "M6_drop_lane0", "lane 0 product forced to zero"),
    ("M7_double_lane7",
     "wire [ACCW-1:0] red_cpa = cpa_l3_0;",
     "wire [ACCW-1:0] red_cpa = cpa_l3_0 + prod_r[7];",
     "M7_double_lane7", "lane 7 counted twice by the reduction"),
    ("M8_vd_upper_not_cleared",
     "assign vd    = { {(VLEN-OUTW){1'b0}}, out_field };",
     "assign vd    = { vs1[VLEN-1:OUTW], out_field };",
     None, "statement's vd[1..VLEN-1] = 0 not honoured"),
]


def sh(cmd, cwd):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True,
                          encoding="utf-8", errors="replace")


def emit_vectors(nlanes, outw):
    os.makedirs(os.path.join(ROOT, GEN_REL), exist_ok=True)
    tag = "n%d_o%d" % (nlanes, outw)
    built = {"pos": gv.build_pos(), "neg": gv.build_neg(),
             "bound": gv.build_bound(), "rand": gv.build_rand()}
    rel = {}
    for grp, cases in built.items():
        name = "cases_%s_%s.txt" % (grp, tag)
        with open(os.path.join(ROOT, GEN_REL, name), "w", encoding="utf-8", newline="\n") as f:
            for i, (label, a, b) in enumerate(cases):
                f.write("%d %s\n" % (i, gv.fmt(a, b, nlanes=nlanes, out_w=outw)))
        rel[grp] = "%s/%s" % (GEN_REL, name)
    return tag, rel, built


def run_case(defines, rtl_rel, vvp_rel, cwd):

    cmd = ["iverilog", "-g2012", "-o", vvp_rel]
    cmd += ["-D%s=%s" % (k, v) for k, v in defines.items()]
    cmd += [rtl_rel, TB_REL]
    c = sh(cmd, cwd)
    if c.returncode != 0:
        return {"verdict": "BROKEN", "why": "compile failed",
                "log": (c.stdout or "") + (c.stderr or "")}
    r = sh(["vvp", vvp_rel], cwd)
    out = (r.stdout or "") + (r.stderr or "")
    m = re.search(r"SUMMARY .*total=(\d+) pass=(\d+) fail=(\d+)", out)
    if not m:
        return {"verdict": "BROKEN", "why": "no SUMMARY line (bench never reached the end)",
                "log": out[-1500:], "vvp_rc": r.returncode}
    total, npass, nfail = int(m.group(1)), int(m.group(2)), int(m.group(3))
    if total == 0:
        return {"verdict": "BROKEN", "why": "zero cases parsed", "log": out[-800:]}
    return {"verdict": "PASS" if nfail == 0 else "FAIL", "total": total,
            "pass": npass, "fail": nfail, "vvp_rc": r.returncode,
            "failed_cases": sorted(int(x) for x in re.findall(r"CASE (\d+) FAIL", out)),
            "got": dict(re.findall(r"CASE (\d+) FAIL got=([0-9a-fA-FxX]+)", out))}


def predicted_failures(built, model, accw, outw):








    out = {}
    for grp, cases in built.items():
        bad = []
        for i, (label, a, b) in enumerate(cases):
            true_v = g.vdot_vd_bits(a, b, nlanes=8, out_w=outw)
            mut_v = _wrap(model(a, b), accw, outw)
            if mut_v != true_v:
                bad.append(i)
        out[grp] = bad
    return out


def main():
    os.chdir(ROOT)
    os.makedirs("build", exist_ok=True)
    os.makedirs("results", exist_ok=True)

    gen = sh([sys.executable, os.path.join(HERE, "gen_vdot_rtl.py")], ROOT)
    if gen.returncode != 0:
        print("RTL generation failed:\n" + gen.stdout + gen.stderr)
        return 2
    rtl_text = open(os.path.join(ROOT, RTL_REL), encoding="utf-8").read()

    report = {"configs": [], "width_probe": None, "mutations": []}
    all_ok = True

    print("=== matrix (relative paths, cwd=%s) ===" % ROOT)
    for tree, nlanes, outw, accw, note in CONFIGS:
        tag, rel, _ = emit_vectors(nlanes, outw)
        cell = {"tree": tree, "nlanes": nlanes, "outw": outw, "accw": accw,
                "note": note, "groups": {}}
        for grp in GROUPS:
            defines = {"TREE_V": tree, "NLANES_V": nlanes, "OUTW_V": outw,
                       "ACCW_V": accw, "CASE_FILE": '"%s"' % rel[grp]}
            res = run_case(defines, RTL_REL, "build/m_%d_%d_%d_%s.vvp" % (tree, nlanes, outw, grp), ROOT)
            res.pop("got", None)
            cell["groups"][grp] = res
            if res["verdict"] != "PASS":
                all_ok = False
            print("  tree=%d n=%2d ow=%2d accw=%2d %-6s %s %s" %
                  (tree, nlanes, outw, accw, grp, res["verdict"],
                   res.get("why", "%d/%d" % (res.get("pass", 0), res.get("total", 0)))))
            if res["verdict"] == "BROKEN":
                print("    log: " + res.get("log", "")[:400].replace("\n", " | "))
        report["configs"].append(cell)

    print("=== parameter-reality probe: ACCW/NLANES/OUTW must be real parameters ===")






    probe = []
    for accw in (17, 18, 19, 20, 23):
        for nl in (1, 8, 16):
            for tr in (0, 1):
                defines = {"TREE_V": tr, "NLANES_V": nl, "OUTW_V": 32, "ACCW_V": accw,
                           "CASE_FILE": '"nonexistent.txt"'}
                res = run_case(defines, RTL_REL, "build/probe_%d_%d_%d.vvp" % (accw, nl, tr), ROOT)
                compiled = res.get("why") != "compile failed"
                probe.append({"accw": accw, "nlanes": nl, "tree": tr, "compiled": compiled})
                if not compiled:
                    print("  ACCW=%d NLANES=%d TREE=%d COMPILE-FAIL: %s" %
                          (accw, nl, tr, res.get("log", "")[:200].replace("\n", " | ")))








    rtl_txt = io.open(os.path.join(ROOT, RTL_REL), encoding="utf-8").read()
    sew_uses = sum(1 for tok in re.findall("[A-Za-z_][A-Za-z0-9_]*", rtl_txt) if tok == "SEW")
    print("  SEW appears %d time(s) in the emitted RTL (1 would mean decorative)"
          % sew_uses)
    report["sew_uses"] = sew_uses
    if sew_uses < 2:
        bad_static = "SEW is only declared, never used: it is a decorative parameter"
        all_ok = False
        print("  %s" % bad_static)
        report["sew_note"] = bad_static
    else:
        report["sew_note"] = ("pinned at SEW=%d; the element width reaches the slices, "
                              "the sign extension and the product width" % PINNED_SEW)
    bad = [p for p in probe if not p["compiled"]]
    print("  %d/%d elaborations succeeded across the parameter sweep" % (len(probe) - len(bad), len(probe)))
    report["param_probe"] = {"total": len(probe), "bad": bad}
    if bad:
        all_ok = False

    print("=== width probe: identical RTL rebuilt at ACCW=18 ===")
    tag, rel, built = emit_vectors(8, 32)
    wp = {"accw": 18, "groups": {}, "corner_case0_detected": False}
    for grp in GROUPS:
        defines = {"TREE_V": 0, "NLANES_V": 8, "OUTW_V": 32, "ACCW_V": 18,
                   "CASE_FILE": '"%s"' % rel[grp]}
        res = run_case(defines, RTL_REL, "build/w18_%s.vvp" % grp, ROOT)
        broke = res["verdict"] == "FAIL"
        wp["groups"][grp] = {"verdict": res["verdict"], "fail": res.get("fail", 0),
                             "total": res.get("total", 0),
                             "failed_cases": res.get("failed_cases", [])[:16]}
        if grp == "bound" and broke and 0 in res.get("failed_cases", []):
            wp["corner_case0_detected"] = True
        print("  ACCW=18 %-6s %-6s fail=%s/%s cases=%s" %
              (grp, res["verdict"], res.get("fail", 0), res.get("total", 0),
               res.get("failed_cases", [])[:8]))
    if not wp["corner_case0_detected"]:
        print("  !! the +131072 corner did not break at ACCW=18: 19-bit claim unsupported")
        all_ok = False
    report["width_probe"] = wp

    print("=== mutations: RTL must break exactly where the model predicts ===")
    for name, old, new, model, why in MUTATIONS:
        n = rtl_text.count(old)
        if n != 1:
            report["mutations"].append({"name": name, "ok": False,
                                        "err": "anchor matched %d times, need exactly 1" % n})
            print("  %-24s ANCHOR-BAD (%d matches): %s" % (name, n, old[:60]))
            all_ok = False
            continue
        if name == "M3_gate_both":
            rtl_mut = rtl_text.replace(old, new)
            old2 = MUTATIONS[1][1]
            if rtl_mut.count(old2) != 1:
                print("  %-24s ANCHOR-BAD for second gate" % name)
                all_ok = False
                continue
            rtl_mut = rtl_mut.replace(old2, MUTATIONS[1][2])
        elif name == "M8_vd_upper_not_cleared":
            rtl_mut = rtl_text.replace(old, new)
        else:
            rtl_mut = rtl_text.replace(old, new)
        mrtl = "build/mut_%s.sv" % name
        with open(os.path.join(ROOT, mrtl), "w", encoding="utf-8", newline="\n") as f:
            f.write(rtl_mut)

        if model:
            pred = predicted_failures(built, MUT_MODELS[model], 19, 32)
        else:

            pred = {}
            for grp, cases in built.items():
                bad = []
                for i, (label, a, b) in enumerate(cases):
                    upper = int.from_bytes(a, "little") & (((1 << 96) - 1) << 32)
                    mv = g.vdot_vd_bits(a, b, nlanes=8, out_w=32) | upper
                    if mv != g.vdot_vd_bits(a, b, nlanes=8, out_w=32):
                        bad.append(i)
                pred[grp] = bad

        rec = {"name": name, "why": why, "groups": {}, "ok": True}
        for grp in GROUPS:
            defines = {"TREE_V": 0, "NLANES_V": 8, "OUTW_V": 32, "ACCW_V": 19,
                       "CASE_FILE": '"%s"' % rel[grp]}
            res = run_case(defines, mrtl, "build/mut_%s_%s.vvp" % (name, grp), ROOT)
            want = pred[grp]
            got = res.get("failed_cases", [])
            if res["verdict"] == "BROKEN":
                good = False
            elif want:
                good = (res["verdict"] == "FAIL") and (got == want)
            else:
                good = (res["verdict"] == "PASS")
            rec["groups"][grp] = {"verdict": res["verdict"], "want_fail": len(want),
                                  "got_fail": len(got), "exact_match": good}
            if not good:
                rec["ok"] = False
            print("  %-24s %-6s %-6s want=%-4d got=%-4d %s" %
                  (name, grp, res["verdict"], len(want), len(got),
                   "ok" if good else "MISMATCH"))
            res.pop("got", None)
        report["mutations"].append(rec)
        if not rec["ok"]:
            all_ok = False

    report["all_ok"] = all_ok
    with open("results/matrix.json", "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    write_md(report)
    print("\nMATRIX_ALL_OK=%s" % all_ok)
    return 0 if all_ok else 1


def write_md(rep):
    L = ["<!-- GENERATED by sim/run_matrix.py -- do not hand-edit, rerun the script. -->", ""]
    L.append("| TREE | NLANES | OUTW | ACCW | " + " | ".join(GROUPS) + " | verdict |")
    L.append("|---|---|---|---|---|---|---|---|")
    for c in rep["configs"]:
        cells, ok = [], True
        for grp in GROUPS:
            r = c["groups"][grp]
            cells.append("%s %d/%d" % (r["verdict"], r.get("pass", 0), r.get("total", 0)))
            ok = ok and r["verdict"] == "PASS"
        L.append("| %d | %d | %d | %d | %s | %s |" %
                 (c["tree"], c["nlanes"], c["outw"], c["accw"], " | ".join(cells),
                  "PASS" if ok else "FAIL"))
    L.append("")
    L.append("| mutation | expected wrong behaviour | " + " | ".join(GROUPS) + " | exact? |")
    L.append("|---|---|---|---|---|---|---|---|")
    for m in rep["mutations"]:
        if "groups" not in m:
            L.append("| %s | %s | - | - | - | - | NO |" % (m["name"], m.get("err", "")))
            continue
        cells = ["%s w%d/g%d" % (m["groups"][gr]["verdict"], m["groups"][gr]["want_fail"],
                                 m["groups"][gr]["got_fail"]) for gr in GROUPS]
        L.append("| %s | %s | %s | %s |" % (m["name"], m["why"], " | ".join(cells),
                                            "YES" if m["ok"] else "NO"))
    with open("results/matrix.md", "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(L) + "\n")


if __name__ == "__main__":
    sys.exit(main())
