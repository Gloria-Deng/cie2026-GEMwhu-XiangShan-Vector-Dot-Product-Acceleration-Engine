
import io
import os
import re
import sys

NAME_H = "src/isa/riscv64/include/isa-all-instr.h"
DECODE_H = "src/isa/riscv64/instr/rvv/decode.h"
VCOMP_H = "src/isa/riscv64/instr/rvv/vcompute.h"

VV_NAME_ROW = "#define VDOT_INSTR_TERNARY(f) f(vdot)"
VX_NAME_ROW = "#define VDOT_INSTR_TERNARY(f) f(vdot) f(vdot_vx)"


VV_DECODE_ROW = '  def_INSTR_TAB("101100 ? ????? ????? ??? ????? ????? ??", vdot);'
VX_DECODE_ROW = ("""


  def_INSTR_TAB("101100 ? ????? ????? ??? ????? ????? ??", vdot_vx);
""")
MVX_VMACC_ROW = '  def_INSTR_TAB("101101 ? ????? ????? ??? ????? ????? ??", vmacc);'
MVX_SCOPE = "def_THelper(vopmvx)"


HELPER_ANCHOR = "//op-m\ndef_EHelper(vredsum) {"
HELPER_ANCHOR_COUNT = 1

VX_HELPER = ("""


def_EHelper(vdot_vx) {
  require_vector(true);
  if (vtype->vsew != VDOT_SEW_INDEX) {
    Log("vdot.vx requires SEW=8, vtype.vsew=%lu", vtype->vsew);
    longjmp_exception(EX_II);
  }
  if (s->vm == 0) {
    Log("vdot.vx is defined unmasked, but vm=0");
    longjmp_exception(EX_II);
  }
  check_vstart_exception(s);
  if (check_vstart_ignore(s)) {
    vp_set_dirty();
    return;
  }


  rtl_lr(s, &(id_src->val), id_src1->reg, 4);
  rtl_mv(s, s1, &id_src->val);
  rtl_sext(s, s1, s1, 1 << vtype->vsew);
  int64_t scalar = (int64_t)*s1;

  int64_t acc = 0;
  for (word_t idx = 0; idx < VDOT_NLANES; idx++) {
    rtlreg_t a;
    get_vreg(id_src2->reg, idx, &a, vtype->vsew, vtype->vlmul, 1, 0);
    acc += (int64_t)a * scalar;
  }

  for (int i = 0; i < VLEN / 8; i++) {
    set_vreg(id_dest->reg, i, 0, VDOT_SEW_INDEX, vtype->vlmul, 0);
  }
  if (vl->val == 0) {
    Log("vdot.vx.vl==0: acc=%ld written to element 0 suppressed", acc);
  } else {
    set_vreg(id_dest->reg, 0, (rtlreg_t)(uint32_t)acc, 2, vtype->vlmul, 0);
  }
  vp_set_dirty();
  vstart->val = 0;
}

//op-m
def_EHelper(vredsum) {""")


def die(msg):
    sys.stdout.write("VDOTVX-PATCH-SETUP-FAIL %s\n" % msg[:300])
    sys.exit(2)


def read(tree, rel):
    p = os.path.join(tree, rel)
    if not os.path.exists(p):
        die("missing %s" % rel)
    return io.open(p, encoding="utf-8", errors="replace").read()


def mvx_region(text):

    i = text.index(MVX_SCOPE)
    j = text.index("\n}", i)
    return i, j


def scoped(text, old, new, scope):

    if scope is None:
        return text.replace(old, new, 1), text.count(old)
    if scope not in text:
        die("scope %s absent" % scope)
    a, b = mvx_region(text)
    region = text[a:b]
    hits = region.count(old)
    if hits != 1:
        return text, hits
    return text[:a] + region.replace(old, new, 1) + text[b:], hits


def plan(tree):

    edits = []
    facts = {}

    nm = read(tree, NAME_H)
    facts["vv_name_row_present"] = VV_NAME_ROW in nm
    facts["vx_name_row_present"] = "f(vdot_vx)" in nm
    if not facts["vv_name_row_present"]:
        die("precondition: %s has no %s" % (NAME_H, VV_NAME_ROW))
    if facts["vx_name_row_present"]:
        facts["name_edit"] = "already"
    else:
        facts["name_edit"] = "planned"
        edits.append((NAME_H, VV_NAME_ROW, VX_NAME_ROW, "name", None))

    dc = read(tree, DECODE_H)
    if MVX_SCOPE not in dc:
        die("precondition: %s has no %s" % (DECODE_H, MVX_SCOPE))
    a, b = mvx_region(dc)
    body = dc[a:b]
    facts["vv_decode_row_present"] = VV_DECODE_ROW in dc
    facts["mvx_scope_has_101100"] = '101100 ? ????? ????? ??? ????? ????? ??", vdot_vx' in body
    facts["mvx_vmac_anchors"] = body.count(MVX_VMACC_ROW)
    facts["whole_file_vmac_anchors"] = dc.count(MVX_VMACC_ROW)
    if not facts["vv_decode_row_present"]:
        die("precondition: %s has no OPMVV vdot row" % DECODE_H)
    if facts["mvx_scope_has_101100"]:
        facts["decode_edit"] = "already"
    else:
        if facts["mvx_vmac_anchors"] != 1:
            die("anchor %s occurs %d times inside %s"
                % (MVX_VMACC_ROW.strip()[:40], facts["mvx_vmac_anchors"], MVX_SCOPE))
        facts["decode_edit"] = "planned"
        edits.append((DECODE_H, MVX_VMACC_ROW, VX_DECODE_ROW + MVX_VMACC_ROW, "decode",
                       MVX_SCOPE))

    vc = read(tree, VCOMP_H)
    facts["vv_helper_present"] = "def_EHelper(vdot) {" in vc
    facts["vx_helper_present"] = "def_EHelper(vdot_vx) {" in vc
    facts["helper_tail_anchors"] = vc.count(HELPER_ANCHOR)
    if not facts["vv_helper_present"]:
        die("precondition: %s has no def_EHelper(vdot)" % VCOMP_H)
    if facts["vx_helper_present"]:
        facts["helper_edit"] = "already"
    elif "VLEN / 8" not in vc:
        die("precondition: %s has no VLEN/8 clearing idiom to mirror" % VCOMP_H)
    else:
        if facts["helper_tail_anchors"] != HELPER_ANCHOR_COUNT:
            die("helper tail anchor occurs %d times" % facts["helper_tail_anchors"])
        facts["helper_edit"] = "planned"
        edits.append((VCOMP_H, HELPER_ANCHOR, VX_HELPER, "helper", None))


    for rel, old, new, tag, scope in edits:
        if old not in new:
            die("edit %s drops its anchor -- the replacement must contain it" % tag)


    sys.stdout.write("IDEMPOTENCE-KEY name=%s decode=%s helper=%s\n"
                     % (facts["vx_name_row_present"], facts["mvx_scope_has_101100"],
                        facts["vx_helper_present"]))
    return edits, facts


def main():
    mode = "check"
    args = []
    for a in sys.argv[1:]:
        if a == "--check":
            mode = "check"
        elif a == "--apply":
            mode = "apply"
        else:
            args.append(a)
    if len(args) != 1:
        die("usage: round9_vx_nemu_patch.py [--check|--apply] <nemu-tree>")
    tree = args[0]
    if not os.path.isdir(tree):
        die("no such tree: %s" % tree)

    edits, facts = plan(tree)
    for k in sorted(facts):
        sys.stdout.write("FACT %-26s %s\n" % (k, facts[k]))
    for rel, old, new, tag, scope in edits:
        sys.stdout.write("EDIT %-8s %s\n" % (tag, rel))

    if mode == "check":
        sys.stdout.write("VDOTVX-PATCH-CHECK tree=%s planned=%d already=%d anchors_ok=1\n"
                         % (tree, len(edits), 3 - len(edits)))
        return 0

    if not edits:
        sys.stdout.write("VDOTVX-PATCH-APPLY nothing to do\n")
        return 0


    texts = {}
    for rel, old, new, tag, scope in edits:
        cur = texts.get(rel) or read(tree, rel)
        cur2, hits = scoped(cur, old, new, scope)
        if hits != 1:
            die("apply-time anchor drift in %s (%s): count=%d"
                % (rel, scope or "whole-file", hits))
        texts[rel] = cur2
        sys.stdout.write("STAGED %-8s %s (%s)\n" % (tag, rel, scope or "whole-file"))
    for rel in texts:
        io.open(os.path.join(tree, rel), "w", encoding="utf-8", newline="\n").write(texts[rel])
        sys.stdout.write("WROTE %s\n" % rel)


    again, facts2 = plan(tree)
    if again:
        die("readback: %d edit(s) did not land" % len(again))
    for k in ("vx_name_row_present", "mvx_scope_has_101100", "vx_helper_present"):
        if not facts2[k]:
            die("readback: %s is false after apply" % k)


    for rel in {e[0] for e in edits}:
        if not rel.endswith(".h"):
            continue
        body = read(tree, rel)
        o, c = body.count("{"), body.count("}")
        sys.stdout.write("BRACES %s open=%d close=%d balanced=%s\n" % (rel, o, c, o == c))
        if o != c:
            die("readback: %s brace imbalance after apply (open=%d close=%d)" % (rel, o, c))
    sys.stdout.write("VDOTVX-PATCH-APPLY edits=%d readback_ok=1\n" % len(edits))
    return 0


if __name__ == "__main__":
    sys.exit(main())
