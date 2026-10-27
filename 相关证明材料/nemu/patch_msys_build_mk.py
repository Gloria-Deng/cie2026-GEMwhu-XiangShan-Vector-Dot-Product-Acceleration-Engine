#!/usr/bin/env python3
# -*- coding: utf-8 -*-



























from __future__ import annotations

import io
import os
import re
import sys

REL = os.path.join("scripts", "build.mk")
LINE_RE = re.compile(r"^CFLAGS\s*:=.*-MMD.*-Wall")
TOKENS = ("-Werror", "-Wno-error")


def cflags_line(lines):
    hits = [i for i, l in enumerate(lines) if LINE_RE.match(l)]
    return hits


def strip_flags(line):






    out = line.replace(" -Wno-error", "").replace(" -Werror", "")
    return out


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    smoke = "--smoke" in sys.argv
    flag = None
    if "--flag" in sys.argv:
        i = sys.argv.index("--flag")
        if i + 1 >= len(sys.argv):
            print("SETUP-FAIL: --flag needs an argument (error | no-error)")
            return 2
        flag = sys.argv[i + 1]
        if flag not in ("error", "no-error"):
            print("SETUP-FAIL: --flag must be error or no-error, got %r" % flag)
            return 2
    if not args:
        print("usage: python nemu/patch_msys_build_mk.py <NEMU tree> "
              "[--smoke|--flag error|--flag no-error]")
        return 2
    target = os.path.join(args[0], REL)
    if not os.path.exists(target):
        print("SETUP-FAIL: %s not found" % target)
        return 2

    txt = io.open(target, encoding="utf-8", newline="").read()
    lines = txt.split("\n")
    hits = cflags_line(lines)
    if len(hits) != 1:
        print("BEFORE line=ABSENT hits=%d" % len(hits))
        print("SETUP-FAIL: the studied CFLAGS line matched %d times (need exactly 1)"
              " -- the tree moved, do not guess" % len(hits))
        return 1
    i = hits[0]
    before = lines[i]
    want = "-Wno-error" if flag is None else ("-Werror" if flag == "error" else "-Wno-error")
    present = [t for t in TOKENS if t in before.split()]
    print("BEFORE line=%d hits=%d tokens=%s" % (i + 1, len(hits), ",".join(present) or "none"))
    print("BEFORE text=%s" % before)

    base = strip_flags(before)
    if "-Wall " not in base:
        print("SETUP-FAIL: no -Wall to anchor on: %r" % base)
        return 1
    new = base.replace("-Wall ", "-Wall " + want + " ", 1)
    if want not in new.split():
        print("SETUP-FAIL: the token did not land: %r" % new)
        return 1
    noop = (new == before)

    if smoke:
        print("--smoke verdict=%s" % ("already-patched" if noop else "patchable"))
        return 0
    if noop:
        print("already set; nothing written (want=%s)" % want)
        print("MSYS_BUILD_MK_PATCH %s" % ("NOOP" if flag is None else "FORCED-OK"))
        return 0

    lines[i] = new




    io.open(target, "w", encoding="utf-8", newline="").write("\n".join(lines))
    after_txt = io.open(target, encoding="utf-8", newline="").read()
    after_hits = cflags_line(after_txt.split("\n"))
    after_line = after_txt.split("\n")[after_hits[0]] if len(after_hits) == 1 else ""
    ok = (len(after_hits) == 1 and want in after_line.split()
          and all(t not in after_line.split() for t in TOKENS if t != want)
          and len(after_txt.split("\n")) == len(lines))
    print("AFTER  text=%s" % after_line)
    print("FORCE=%d lines=%d->%d" % (0 if flag is None else 1, len(lines),
                                     len(after_txt.split("\n"))))
    print("MSYS_BUILD_MK_PATCH %s" % ("OK" if ok else "FAIL"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
