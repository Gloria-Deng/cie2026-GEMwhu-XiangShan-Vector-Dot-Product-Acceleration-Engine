#!/usr/bin/env bash























set -u
export PATH="$PATH:/e/msys64/usr/bin"
export TMP=/tmp TEMP=/tmp TMPDIR=/tmp
HERE="$(cd "$(dirname "$0")/../.." && pwd)"
PY=/c/Users/lenovo/AppData/Local/Programs/Python/Python311/python
WORK="${VX_WORK:-/d/nemu_vx_arm}"
TREE="${VX_TREE:-/d/nemu-vx}"
CORPUS="${VX_CORPUS:-/d/nemu_cosim/cases_rtl.txt}"
LAYOUT_SRC=/d/nemu_cosim/cosim_layout.h
DLL_VX="$TREE/build/riscv64-nemu-interpreter-so.exe"
DLL_VVONLY=/d/nemu-cosim/build/riscv64-nemu-interpreter-so.exe
DLL_VANILLA=/d/nemu-vanilla-cosimarm/build/riscv64-nemu-interpreter-so.exe
OUT="$HERE/results/vdot_vx_reference.txt"

die () { echo "SETUP-FAIL: $*" >&2; exit 2; }


winp () { cygpath -w "$1" 2>/dev/null || echo "$1"; }
for f in "$DLL_VX" "$DLL_VVONLY" "$DLL_VANILLA" "$CORPUS" "$LAYOUT_SRC" \
         "$HERE/nemu/cosim/cosim_vx.c" "$HERE/sim/golden_vx.py"; do
  [ -e "$f" ] || die "missing $f"
done
mkdir -p "$WORK" || die "cannot create $WORK"

echo "== compile the harness against the vx tree (same include flags NEMU uses) =="
cp "$HERE/nemu/cosim/cosim_vx.c" "$WORK/cosim_vx.c" || die "copy harness"
cp "$LAYOUT_SRC" "$WORK/cosim_layout.h" || die "copy layout header"
( cd "$WORK" && NEMU_TREE="$TREE" bash "$HERE/nemu/cosim/cc.sh" cosim_vx.c cosim_vx.exe \
    > vx_cc.log 2>&1 ) || { tail -20 "$WORK/vx_cc.log"; die "harness compile failed"; }
grep -q "CC_RC=0" "$WORK/vx_cc.log" || die "cc.sh did not report CC_RC=0"
[ -f "$WORK/cosim_vx.exe" ] || die "harness exe not produced"

echo "== expectations, from sim/golden_vx.py (integer-register route) =="
$PY "$HERE/sim/golden_vx.py" --emit-cases "$(cygpath -w "$CORPUS" 2>/dev/null || echo "$CORPUS")" \
   "$(cygpath -w "$WORK/vx_cases.txt" 2>/dev/null || echo "$WORK/vx_cases.txt")" \
   || die "expectation generator failed"
EMIT_LINE=$($PY - "$(winp "$WORK/vx_cases.txt")" <<'PYEOF'
import sys
rows = [l for l in open(sys.argv[1], encoding="utf-8") if l.strip() and not l.startswith("#")]
print("rows=%d first=%s" % (len(rows), rows[0].split()[1] if rows else "NONE"))
PYEOF
) || die "could not count case rows"
echo "cases $EMIT_LINE"
NCASE=$(echo "$EMIT_LINE" | sed -n 's/rows=\([0-9]*\).*/\1/p')
[ -n "$NCASE" ] || die "NCASE came out empty"

sha_line () {
  local h n
  h=$(sha256sum "$1" | cut -d' ' -f1)
  n=$(wc -c < "$1")
  [ -n "$h" ] && [ -n "$n" ] || { echo "SETUP-FAIL: sha/size empty for $1" >&2; return 2; }
  echo "sha256=$h bytes=$n"
}

run_arm () {
  local label="$1" dll="$2"; shift 2
  local log="$WORK/arm_$label.log"
  ( cd "$WORK" && ./cosim_vx.exe "$dll" vx_cases.txt --verbose=0 "$@" > "$log" 2>&1 )






  declare -g "RC_$label=$?"
  local rc verdict
  rc=$(eval "echo \$RC_$label")
  verdict=$(grep -a '^ARM\|^COSIM_VX' "$log" | tr '\n' ' ')
  [ -n "$verdict" ] || die "arm $label left no ARM/COSIM_VX line in $log (rc=$rc)"
  echo "[$label] rc=$rc $verdict"
}
run_arm patched "$DLL_VX"
run_arm vvonly  "$DLL_VVONLY"
run_arm vanilla "$DLL_VANILLA"
run_arm inject  "$DLL_VX" --inject-bug

pick () { grep -a "$2" "$WORK/arm_$1.log" | tail -1; }
PARSE=$($PY - "$(winp "$WORK")" <<'PYEOF'
import re, sys
w = sys.argv[1]
def get(label):
    txt = open(w + "/arm_" + label + ".log", encoding="utf-8", errors="replace").read()
    arm = re.search(r"^ARM vx_mismatches=(\d+) vv_mismatches=(\d+) x0_witness_mismatches=(\d+)",
                    txt, re.M)
    ver = re.search(r"^COSIM_VX cases=(\d+) steps=(\d+) mismatches=(\d+) pc_bad=(\d+) inject=(\S+)",
                    txt, re.M)
    enc = re.search(r"^ENCODE vv=(\S+) vx=(\S+) xor=(\S+) funct3_only=(\S+)", txt, re.M)
    ins = re.search(r"^INSTR-COUNT g_nr_guest_instr delta=(\d+)", txt, re.M)
    if not (arm and ver and enc):
        raise SystemExit("PARSE-FAIL %s: arm=%s ver=%s enc=%s" % (label, bool(arm), bool(ver), bool(enc)))
    return dict(vx=int(arm.group(1)), vv=int(arm.group(2)), x0=int(arm.group(3)),
                cases=int(ver.group(1)), steps=int(ver.group(2)), mm=int(ver.group(3)),
                pcbad=int(ver.group(4)), inject=ver.group(5),
                encvv=enc.group(1), encvx=enc.group(2), xor=enc.group(3),
                f3only=enc.group(4), instrs=(ins.group(1) if ins else "NA"))
p, v, x, j = get("patched"), get("vvonly"), get("vanilla"), get("inject")
print("PATCHED cases=%d steps=%d vx_bad=%d vv_bad=%d x0_bad=%d pc_bad=%d mm=%d"
      % (p["cases"], p["steps"], p["vx"], p["vv"], p["x0"], p["pcbad"], p["mm"]))
print("CONTROL_VVONLY cases=%d vx_bad=%d vv_bad=%d x0_bad=%d pc_bad=%d"
      % (v["cases"], v["vx"], v["vv"], v["x0"], v["pcbad"]))
print("CONTROL_VANILLA cases=%d vx_bad=%d vv_bad=%d x0_bad=%d"
      % (x["cases"], x["vx"], x["vv"], x["x0"]))
print("POSITIVE_CONTROL cases=%d vx_bad=%d mm=%d detected=%s"
      % (j["cases"], j["vx"], j["mm"], "yes" if j["mm"] > 0 else "no"))
print("ENCODE vv=%s vx=%s xor=%s funct3_only=%s agree_across_arms=%s"
      % (p["encvv"], p["encvx"], p["xor"], p["f3only"],
         "yes" if len({(a["encvv"], a["encvx"]) for a in (p, v, x, j)}) == 1 else "NO"))
print("INSTR_COUNTS patched=%s vvonly=%s vanilla=%s" % (p["instrs"], v["instrs"], x["instrs"]))
# the four things this archive is allowed to claim
ok = (p["mm"] == 0 and p["pcbad"] == 0 and p["vx"] == 0 and p["vv"] == 0 and p["x0"] == 0
      and v["vx"] > 0 and v["vv"] == 0 and x["vx"] > 0 and x["vv"] > 0
      and j["mm"] > 0 and p["f3only"] == "yes"
      and p["cases"] == v["cases"] == x["cases"] == j["cases"])
print("PATTERN ok=%s" % ("yes" if ok else "NO"))
sys.exit(0 if ok else 1)
PYEOF
) || { echo "$PARSE"; die "the four arms did not produce the pattern this archive claims"; }
echo "$PARSE"

IDENT=$($PY "$HERE/sim/golden_vx.py")
echo "$IDENT"



for l in patched vvonly vanilla inject; do
  v="RC_$l"



  [ -n "${!v+SET}" ] || die "internal: $v was never recorded -- arm $l did not run"
  [ -n "${!v}" ] || die "internal: $v came out empty -- cannot print rc= with no value"
done

{
  echo "# generated by nemu/cosim/capture_vdot_vx_ref.sh -- do not edit"
  echo "# requirement 4.7 / docs-03 5.2: the SECOND custom instruction executed by a reference machine"
  echo "[harness] pkg nemu/cosim/cosim_vx.c $(sha_line "$HERE/nemu/cosim/cosim_vx.c")"
  echo "[harness] work copy $WORK/cosim_vx.c $(sha_line "$WORK/cosim_vx.c")"
  echo "[harness] exe $WORK/cosim_vx.exe $(sha_line "$WORK/cosim_vx.exe")"
  echo "[expectations] sim/golden_vx.py $(sha_line "$HERE/sim/golden_vx.py")"
  echo "[expectations] $IDENT"
  echo "[cases] corpus $CORPUS $(sha_line "$CORPUS")"
  echo "[cases] $WORK/vx_cases.txt $(sha_line "$WORK/vx_cases.txt") rows=$NCASE"
  echo "[layout] cosim_layout.h $(sha_line "$WORK/cosim_layout.h")"
  echo "[tree] build driver nemu/build_vx_arm.sh; arm source tree $TREE"
  for rel in src/isa/riscv64/include/isa-all-instr.h src/isa/riscv64/instr/rvv/decode.h \
             src/isa/riscv64/instr/rvv/vcompute.h; do
    echo "[tree] file $TREE/$rel $(sha_line "$TREE/$rel")"
  done
  echo "[dll] patched  $DLL_VX $(sha_line "$DLL_VX")"
  echo "[dll] vv-only  $DLL_VVONLY $(sha_line "$DLL_VVONLY")"
  echo "[dll] vanilla  $DLL_VANILLA $(sha_line "$DLL_VANILLA")"
  echo "[cc] harness $(grep -a CC_RC "$WORK/vx_cc.log" | tail -1) | library $(grep -a '^CC_RESOLVED' /d/nemu_vx_arm.log | tail -1)  (nemu/build_vx_arm.sh header says why the compiler layer matters)"
  echo ""
  echo "=== per-step trace of the first case, patched arm (the whole guest sequence) ==="
  ( cd "$WORK" && ./cosim_vx.exe "$DLL_VX" vx_cases.txt --verbose=1 2>&1 | head -22 )
  echo ""
  echo "=== arm verdicts ==="
  echo "$PARSE"
  echo ""
  echo "=== raw arm tails ==="
  for l in patched vvonly vanilla inject; do
    v="RC_$l"
    echo "--- arm=$l rc=${!v}"
    grep -a "^library\|^INSTR-COUNT\|^CHECKS\|^ARM\|^COSIM_VX" "$WORK/arm_$l.log" | head -6
  done
} > "$OUT" 2>&1

PATCHED_LINE=$(pick patched "^COSIM_VX")
PATCHED_ARM=$(pick patched "^ARM")
VVONLY_ARM=$(pick vvonly "^ARM")
VANILLA_ARM=$(pick vanilla "^ARM")
PATTERN_LINE=$(echo "$PARSE" | grep -a '^PATTERN' | tail -1)
num () { echo "$1" | sed -n "s/.*$2=\([0-9]*\).*/\1/p"; }
P_MM=$(num "$PATCHED_ARM" vx_mismatches)
V_VX=$(num "$VVONLY_ARM" vx_mismatches)
V_VV=$(num "$VVONLY_ARM" vv_mismatches)
X_VX=$(num "$VANILLA_ARM" vx_mismatches)
POS=$(echo "$PARSE" | grep -a POSITIVE_CONTROL | grep -oa 'detected=[a-z]*')
PAT=$(echo "$PATTERN_LINE" | grep -oa 'ok=[a-z]*')



for kv in P_MM V_VX V_VV X_VX POS PAT PATCHED_LINE; do
  [ -n "${!kv}" ] || die "verdict field $kv came out empty (see $WORK/arm_*.log)"
done
{
  echo ""
  echo "[patched-arm] $PATCHED_LINE"
  echo "$PATTERN_LINE"
  echo "VXREF cases=$NCASE patched_mismatches=$P_MM vvonly_vx_bad=$V_VX vvonly_vv_bad=$V_VV vanilla_both_bad=$X_VX pos_control=$POS pattern=$PAT"
} >> "$OUT"
VX_LINE=$(grep -a "^VXREF" "$OUT" | tail -1)
echo "$VX_LINE"
echo "$VX_LINE" | grep -Eq \
  "^VXREF cases=[0-9]+ patched_mismatches=[0-9]+ vvonly_vx_bad=[0-9]+ vvonly_vv_bad=[0-9]+ vanilla_both_bad=[0-9]+ pos_control=detected=[a-z]+ pattern=ok=[a-z]+" \
  || die "the VXREF line does not have every field filled: $VX_LINE"
[ "$PAT" = "ok=yes" ] || { echo "VERDICT-NOT-PASS: $PAT"; exit 1; }
echo "VXREF_RC=0 out=$(basename "$OUT")"
