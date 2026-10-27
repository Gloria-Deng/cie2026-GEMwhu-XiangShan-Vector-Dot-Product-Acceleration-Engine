#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import io
import os
import shutil
import subprocess
import sys

ENC = "utf-8"


def load(path):
    return io.open(path, encoding=ENC, errors="replace").read()


def save(path, text):
    with io.open(path, "w", encoding=ENC, newline="") as f:
        f.write(text)


def sub(text, old, new, tag, log):
    n = text.count(old)
    if n != 1:
        raise SystemExit("ANCHOR %s matched %d times (need exactly 1)" % (tag, n))
    log.append("ok  %s" % tag)
    return text.replace(old, new)


def sub_in(text, scope_start, old, new, tag, log):

    i = text.index(scope_start)
    j = text.index("\n}", i)
    body = text[i:j]
    n = body.count(old)
    if n != 1:
        raise SystemExit("ANCHOR %s matched %d times inside %s (need exactly 1)"
                         % (tag, n, scope_start))
    log.append("ok  %s (scoped to %s)" % (tag, scope_start.split("{")[0].strip()))
    return text[:i] + body.replace(old, new, 1) + text[j:]


KCONFIG_ANCHOR = """config CUSTOM_XVEXP2
  bool "RISC-V Xvexp2 Custom Vector Extension"
  depends on RVV
  default n
  help
    Enable the non-standard vfexp2.v instruction for FP16 and FP32.
"""

KCONFIG_NEW = KCONFIG_ANCHOR + """
config CUSTOM_VDOT
  bool "RISC-V vdot.vv Custom Vector Dot Product Instruction"
  depends on RVV
  default n
  help
    Enable the non-standard vdot.vv instruction: a signed int8 dot product
    over the low 8 elements of vs1/vs2 written to vd element 0, with the rest
    of the destination register cleared. SEW=8, VLEN=128, unmasked.
"""

NAME_LIST_ANCHOR = """#ifdef CONFIG_RVV
#define VECTOR_INSTR_TERNARY(f) \\
"""

NAME_LIST_NEW = """#ifdef CONFIG_CUSTOM_VDOT
#define VDOT_INSTR_TERNARY(f) f(vdot)
#else
#define VDOT_INSTR_TERNARY(f)
#endif

#ifdef CONFIG_RVV
#define VECTOR_INSTR_TERNARY(f) \\
"""

WIRE_ANCHOR = "  XVEXP2_INSTR_TERNARY(f) \\\n  XVEXP2_BF16_INSTR_TERNARY(f)"
WIRE_NEW = ("  XVEXP2_INSTR_TERNARY(f) \\\n"
            "  XVEXP2_BF16_INSTR_TERNARY(f) \\\n"
            "  VDOT_INSTR_TERNARY(f)")

DECODE_ANCHOR = '  def_INSTR_TAB("101101 ? ????? ????? ??? ????? ????? ??", vmacc);'
DECODE_NEW = ("""

  def_INSTR_TAB("101100 ? ????? ????? ??? ????? ????? ??", vdot);
"""
              + DECODE_ANCHOR)

HELPER_ANCHOR = """//op-m
def_EHelper(vredsum) {"""

HELPER_NEW = """//op-m


#define VDOT_NLANES 8
#define VDOT_SEW_INDEX 0

def_EHelper(vdot) {
  require_vector(true);
  if (vtype->vsew != VDOT_SEW_INDEX) {
    Log("vdot.vv requires SEW=8, vtype.vsew=%u", (unsigned)vtype->vsew);
    longjmp_exception(EX_II);
  }
  if (s->vm == 0) {
    Log("vdot.vv is defined unmasked, but vm=0");
    longjmp_exception(EX_II);
  }
  if (vtype->vlmul != 0 || vstart->val != 0) {
    longjmp_exception(EX_II);
  }

  int64_t acc = 0;
  for (word_t idx = 0; idx < VDOT_NLANES; idx++) {


    rtlreg_t a, b;
    get_vreg(id_src2->reg, idx, &a, vtype->vsew, vtype->vlmul, 1, 0);
    get_vreg(id_src->reg,  idx, &b, vtype->vsew, vtype->vlmul, 1, 0);
    acc += (int64_t)a * (int64_t)b;
  }


  for (int i = 0; i < VLEN / 8; i++) {
    set_vreg(id_dest->reg, i, 0, VDOT_SEW_INDEX, vtype->vlmul, 0);
  }

  set_vreg(id_dest->reg, 0, (rtlreg_t)(uint32_t)acc,
           2  , 0  , 0);
  vp_set_dirty();
  vstart->val = 0;
}

""" + HELPER_ANCHOR


VCOMMON_ANCHOR = "    vtype->val = id_src2->val;\n    vl->val = vl_num;\n  }\n"
VCOMMON_INSERT = "  IFDEF(CONFIG_SHARE, csr_difftest_mark_dirty());\n"


BUILD_MK_ANCHOR = "CFLAGS  := -MMD -Wall -Werror $(INCLUDES) $(CFLAGS) $(PGO_FLAGS)"
BUILD_MK_NEW = "CFLAGS  := -MMD -Wall -Wno-error $(INCLUDES) $(CFLAGS) $(PGO_FLAGS)"


LDFLAGS_ANCHOR = "LDFLAGS += -static-libstdc++ -Wl,--gc-sections -Wl,--exclude-libs,ALL"
LDFLAGS_NEW = "LDFLAGS += -Wl,--gc-sections -Wl,--exclude-libs,ALL"


def main():
    src, dst = sys.argv[1], sys.argv[2]
    log = []
    if os.path.exists(dst):
        raise SystemExit("destination exists; use a fresh NEMU destination: " + dst)
    src = os.path.abspath(src)
    def ignore_builds(directory, names):
        rel = os.path.relpath(directory, src).replace(os.sep, "/")
        ignored = {".git", "__pycache__"}.intersection(names)

        if rel in (".", "tools/kconfig", "tools/fixdep", "resource/softfloat"):
            ignored.update({"build"}.intersection(names))
        return ignored
    shutil.copytree(src, dst, ignore=ignore_builds)

    p = os.path.join(dst, "src/isa/riscv64/Kconfig")
    save(p, sub(load(p), KCONFIG_ANCHOR, KCONFIG_NEW, "Kconfig CUSTOM_VDOT", log))

    p = os.path.join(dst, "src/isa/riscv64/include/isa-all-instr.h")
    t = load(p)
    t = sub(t, NAME_LIST_ANCHOR, NAME_LIST_NEW, "isa-all-instr.h name macro", log)
    t = sub(t, WIRE_ANCHOR, WIRE_NEW, "isa-all-instr.h INSTR_LIST wiring", log)
    save(p, t)

    p = os.path.join(dst, "src/isa/riscv64/instr/rvv/decode.h")
    save(p, sub_in(load(p), "def_THelper(vopmvv) {", DECODE_ANCHOR, DECODE_NEW,
                   "rvv/decode.h vopmvv row", log))

    p = os.path.join(dst, "src/isa/riscv64/instr/rvv/vcompute.h")
    save(p, sub(load(p), HELPER_ANCHOR, HELPER_NEW, "rvv/vcompute.h def_EHelper(vdot)", log))

    p = os.path.join(dst, "src/isa/riscv64/instr/rvv/vcommon.c")
    t = load(p)
    if "csr_difftest_mark_dirty" in t:
        raise SystemExit("rvv/vcommon.c already carries the mark_dirty line -- "
                         "refusing to double-apply the difftest fix")
    save(p, sub(t, VCOMMON_ANCHOR, VCOMMON_ANCHOR + VCOMMON_INSERT,
                "rvv/vcommon.c set_vtype_vl mark_dirty", log))

    p = os.path.join(dst, "scripts/build.mk")
    t = load(p)
    if "-Wno-error" in t:
        raise SystemExit("scripts/build.mk already carries -Wno-error -- "
                         "refusing to double-apply the build-host softening")
    save(p, sub(t, BUILD_MK_ANCHOR, BUILD_MK_NEW,
                "scripts/build.mk -Wall -Wno-error", log))
    save(p, sub(load(p), LDFLAGS_ANCHOR, LDFLAGS_NEW,
                "scripts/build.mk LDFLAGS -static-libstdc++", log))


    ref = os.path.join(dst, "configs/riscv64-xs-ref_defconfig")
    if os.path.exists(ref):
        cfg = load(ref)
        if "CONFIG_CUSTOM_VDOT" not in cfg:
            cfg = cfg.replace("CONFIG_RVV=y", "CONFIG_RVV=y\nCONFIG_CUSTOM_VDOT=y", 1)
            save(os.path.join(dst, "configs/riscv64-xs-vdot_sdtrig_defconfig"), cfg)
            log.append("ok  configs/riscv64-xs-vdot_sdtrig_defconfig (RV_SDTRIG=y, emu arm)")
            cfgw = cfg.replace("CONFIG_RV_SDTRIG=y", "# CONFIG_RV_SDTRIG is not set", 1)
            save(os.path.join(dst, "configs/riscv64-xs-vdot_defconfig"), cfgw)
            log.append("ok  configs/riscv64-xs-vdot_defconfig (RV_SDTRIG off, local arm)")
    else:
        log.append("MISSING configs/riscv64-xs-ref_defconfig")

    print("\n".join(log))
    return 0


if __name__ == "__main__":
    sys.exit(main())
