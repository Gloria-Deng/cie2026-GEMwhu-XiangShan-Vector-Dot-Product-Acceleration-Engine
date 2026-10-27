#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import difflib
import io
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, os.pardir))
BUILD = os.path.join(ROOT, "build")

MATCH_VDOT_VV = 0xB2002057


MASK_VDOT_VV = 0xFC00707F

GIT = r"D:\git\Git\cmd"


def no_traversal(p):
    ap = os.path.abspath(p)
    if os.pardir in ap.split(os.sep):
        raise SystemExit("PATH-REFUSED: %s contains a %s component"
                         % (p, os.pardir))
    return ap


def read_bytes(path):

    with io.open(path, "rb") as f:
        return f.read().decode("latin-1")


def anchored_edit(t, old, new, tag, log, must_absent=()):
    for m in must_absent:
        if m in t:
            raise SystemExit("%s already carries %s -- refusing to "
                             "double-apply" % (tag, m))
    n = t.count(old)
    if n != 1:
        raise SystemExit("ANCHOR %s matched %d times (need exactly 1)"
                         % (tag, n))
    log.append("ok  %s (anchor x1)" % tag)
    return t.replace(old, new, 1)


def insert_after_line(t, anchor_substr, new_line, tag, log):
    n = t.count(anchor_substr)
    if n != 1:
        raise SystemExit("ANCHOR %s matched %d times (need exactly 1)"
                         % (tag, n))
    i = t.index(anchor_substr)
    j = t.index("\n", i)
    log.append("ok  %s (anchor x1)" % tag)
    return t[:j + 1] + new_line + "\n" + t[j + 1:]


def compute_edits(tree, log):

    out = {}

    p = os.path.join(tree, "riscv", "encoding.h")
    t = read_bytes(p)
    t = insert_after_line(
        t, "#define MATCH_VMACC_V ",
        "#define MATCH_VDOT_VV 0x%08x\n#define MASK_VDOT_VV 0x%08x"
        % (MATCH_VDOT_VV, MASK_VDOT_VV),
        "encoding.h MATCH/MASK defines", log)
    t = insert_after_line(
        t, "DECLARE_INSN(vmacc_v",
        "DECLARE_INSN(vdot_v, MATCH_VDOT_VV, MASK_VDOT_VV)",
        "encoding.h DECLARE_INSN", log)
    out["riscv/encoding.h"] = t

    p = os.path.join(tree, "riscv", "riscv.mk.in")
    t = read_bytes(p)
    n = t.count("vmacc_v \\")
    if n != 1:
        raise SystemExit(
            "ANCHOR riscv.mk.in vmacc_v continuation matched %d times "
            "(need exactly 1). Spike versions differ in how the insn list "
            "is generated -- do NOT guess: locate vmacc_v's registration in "
            "your tree, add vdot_vv beside it, and record what you did in "
            "docs/11. This emitter refuses to improvise an edit it cannot "
            "anchor." % n)
    t = t.replace("vmacc_v \\", "vmacc_v \\\n  vdot_vv \\", 1)
    log.append("ok  riscv.mk.in insn list (anchor x1)")
    out["riscv/riscv.mk.in"] = t

    return out


def unified(old_text, new_text, path, new_file=False):
    old_lines = old_text.splitlines(keepends=True)
    new_lines = new_text.splitlines(keepends=True)
    d = list(difflib.unified_diff(
        [] if new_file else old_lines, new_lines,
        fromfile="/dev/null" if new_file else "a/" + path,
        tofile="b/" + path))
    if not d:
        raise SystemExit("EMPTY-DIFF %s -- anchor matched but nothing "
                         "changed, refusing to emit" % path)
    head = "diff --git a/%s b/%s\n" % (path, path)
    if new_file:
        head += "new file mode 100644\n"
    return head + "".join(d)


def emit(tree, out_path):
    log = []
    tree = require_dir_(no_traversal(tree))
    edits = compute_edits(tree, log)

    body_path = os.path.join(HERE, "vdot_vv.h")
    body = read_bytes(body_path)
    required = ("require_vector(true);", "require(P.VU.vsew == e8);",
                "require(insn.v_vm() == 1);", "require(P.VU.vstart == 0);",
                "vd_acc += a * b;", "P.VU.elt<int32_t>(vd_num, 0)")
    if not all(marker in body for marker in required):
        raise SystemExit("vdot_vv.h is missing required instruction code")
    log.append("ok  insns/vdot_vv.h (new file, %d bytes)" % len(body))

    parts = [unified(read_bytes(os.path.join(tree, "riscv", "encoding.h")),
                     edits["riscv/encoding.h"], "riscv/encoding.h"),
             unified("", body, "riscv/insns/vdot_vv.h", new_file=True),
             unified(read_bytes(os.path.join(tree, "riscv", "riscv.mk.in")),
                     edits["riscv/riscv.mk.in"], "riscv/riscv.mk.in")]
    patch = "".join(parts)
    with io.open(out_path, "wb") as f:
        f.write(patch.encode("latin-1"))
    log.append("EMIT %s (%d bytes, 3 files)"
               % (os.path.relpath(out_path, ROOT), len(patch)))
    print("\n".join(log))
    return 0


def require_dir_(ap):
    if not os.path.isdir(ap):
        raise SystemExit("PATH-REFUSED: %s is not a directory" % ap)
    return ap


FIXTURE_ENCODING = """
#define MATCH_VLE8_V 0x02000057
#define MASK_VLE8_V 0xfc00707f
DECLARE_INSN(vle8_v, MATCH_VLE8_V, MASK_VLE8_V)
#define MATCH_VMACC_V 0xb4002057
#define MASK_VMACC_V 0xfc00707f
DECLARE_INSN(vmacc_v, MATCH_VMACC_V, MASK_VMACC_V)
#define MATCH_VMSEQ_VI 0x6c000057
"""

FIXTURE_MK = """\
riscv_insn_list = \\
  vle8_v \\
  vmacc_v \\
  vmseq_vi \\
"""

FIXTURE_EXPECT = [
    ("riscv/encoding.h", "#define MATCH_VDOT_VV 0xb2002057"),
    ("riscv/encoding.h", "#define MASK_VDOT_VV 0xfc00707f"),
    ("riscv/encoding.h", "DECLARE_INSN(vdot_v, MATCH_VDOT_VV, MASK_VDOT_VV)"),
    ("riscv/riscv.mk.in", "vdot_vv \\"),
]


def selftest():
    os.makedirs(BUILD, exist_ok=True)
    fx = os.path.join(BUILD, "spike_fixture")
    if os.path.exists(fx):
        shutil.rmtree(fx)
    os.makedirs(os.path.join(fx, "riscv", "insns"))
    with io.open(os.path.join(fx, "riscv", "encoding.h"), "w",
                 encoding="utf-8", newline="\n") as f:
        f.write(FIXTURE_ENCODING)
    with io.open(os.path.join(fx, "riscv", "riscv.mk.in"), "w",
                 encoding="utf-8", newline="\n") as f:
        f.write(FIXTURE_MK)

    patch_path = os.path.join(BUILD, "spike_fixture.patch")
    emit(fx, patch_path)

    env = dict(os.environ)
    env["PATH"] = GIT + os.pathsep + env.get("PATH", "")


    env["GIT_CEILING_DIRECTORIES"] = BUILD

    def git_apply(extra, label):
        r = subprocess.run([os.path.join(GIT, "git.exe"), "apply"] + extra
                           + [patch_path], cwd=fx, capture_output=True,
                           text=True, env=env)
        if r.returncode != 0:
            print("%s rc=%d stderr=%s" % (label, r.returncode, r.stderr))
            print("SPIKE-PATCH-SELFTEST VERDICT FAIL")
            return False
        if "Skipped patch" in r.stdout:
            print("%s silently skipped hunks (stdout=%s)"
                  % (label, r.stdout.strip()[:200]))
            print("SPIKE-PATCH-SELFTEST VERDICT FAIL")
            return False
        print("ok  %s on fixture" % label)
        return True

    if not git_apply(["--check"], "git apply --check"):
        return 1
    if not git_apply([], "git apply"):
        return 1

    bad = 0
    for rel, marker in FIXTURE_EXPECT:
        with io.open(os.path.join(fx, rel), encoding="utf-8") as f:
            if marker not in f.read():
                print("MARKER-MISSING %s: %s" % (rel, marker))
                bad += 1
    body = os.path.join(fx, "riscv", "insns", "vdot_vv.h")
    if not os.path.exists(body):
        print("MARKER-MISSING riscv/insns/vdot_vv.h")
        bad += 1
    else:
        print("ok  insns/vdot_vv.h landed (%d bytes)"
              % os.path.getsize(body))

    if bad == 0:
        print("SPIKE-PATCH-SELFTEST VERDICT PASS "
              "(fixture round-trip: emit -> git apply -> markers)")
        return 0
    print("SPIKE-PATCH-SELFTEST VERDICT FAIL")
    return 1


def main():
    argv = sys.argv[1:]
    if argv == ["--selftest"]:
        return selftest()
    if len(argv) != 1:
        raise SystemExit("Usage: python emit_spike_patch.py <spike-src> | --selftest")
    return emit(no_traversal(argv[0]), os.path.join(HERE, "vdot.patch"))


if __name__ == "__main__":
    sys.exit(main())
