#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import io
import os
import sys

MARK = "#ifdef stdout\n#undef stdout\n#endif\n#ifdef stderr\n#undef stderr\n#endif"
ANCHOR = "#include <string>\n\nnamespace NEMUNS {"

BLOCK = """#include <string>

#include <cstdio>


#ifdef stdout
#undef stdout
#endif
#ifdef stderr
#undef stderr
#endif

namespace NEMUNS {"""


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    smoke = "--smoke" in sys.argv
    if not args:
        print("usage: python nemu/patch_msys_output_h.py <NEMU tree> [--smoke]")
        return 2
    target = os.path.join(args[0], "include", "base", "output.h")
    if not os.path.exists(target):
        print("SETUP-FAIL: %s not found" % target)
        return 2
    txt = io.open(target, encoding="utf-8", errors="replace").read()
    has_mark, n_anchor = MARK in txt, txt.count(ANCHOR)
    print("before: marker_present=%s anchor_hits=%d" % (has_mark, n_anchor))
    if smoke:
        print("--smoke verdict=%s"
              % ("already patched" if has_mark
                 else ("patchable" if n_anchor == 1 else "BLOCKED")))
        return 0 if (has_mark or n_anchor == 1) else 1
    if has_mark:
        print("already patched; nothing written")
        return 0
    if n_anchor != 1:
        print("SETUP-FAIL: anchor matched %d times (need exactly 1) -- the tree "
              "moved, do not guess" % n_anchor)
        return 1
    io.open(target + ".bak-stdout", "w", encoding="utf-8", newline="\n").write(txt)
    io.open(target, "w", encoding="utf-8", newline="\n").write(
        txt.replace(ANCHOR, BLOCK, 1))
    after = io.open(target, encoding="utf-8", errors="replace").read()
    ok = (MARK in after and after.count("#undef stdout") == 1
          and after.count("#undef stderr") == 1)
    print("after : marker_present=%s undef_stdout=%d undef_stderr=%d bytes=%d->%d"
          % (MARK in after, after.count("#undef stdout"),
             after.count("#undef stderr"), len(txt), len(after)))
    print("MSYS_OUTPUT_H_PATCH %s" % ("OK" if ok else "FAIL"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
