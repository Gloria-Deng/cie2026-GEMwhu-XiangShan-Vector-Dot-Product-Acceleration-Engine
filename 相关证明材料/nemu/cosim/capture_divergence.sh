#!/bin/bash











set -u
export PATH="$PATH:/e/msys64/usr/bin"
export TMP=/tmp TEMP=/tmp TMPDIR=/tmp
HERE="$(cd "$(dirname "$0")/../.." && pwd)"
TREE="${DIV_TREE:-/d/nemu-vx}"
TREE_VDOT="${DIV_TREE_VDOT:-/d/nemu-vdot}"
TREE_COSIM="${DIV_TREE_COSIM:-/d/nemu-cosim}"
LAYOUT_SRC=/d/nemu_cosim/cosim_layout.h
WORK="${DIV_WORK:-/d/nemu_div_arm}"
DLL="$TREE/build/riscv64-nemu-interpreter-so.exe"
OUT="$HERE/results/nemu_divergence.txt"

die () { echo "SETUP-FAIL: $*" >&2; exit 2; }
for f in "$LAYOUT_SRC" "$HERE/nemu/cosim/cosim_divergence.c" \
         "$HERE/nemu/cosim/cc.sh"; do
  [ -e "$f" ] || die "missing $f"
done
mkdir -p "$WORK" || die "cannot create $WORK"

echo "== compile cosim_divergence.c against the $TREE tree =="
cp "$HERE/nemu/cosim/cosim_divergence.c" "$WORK/cosim_divergence.c" || die "copy harness"
cp "$LAYOUT_SRC" "$WORK/cosim_layout.h" || die "copy layout header"
( cd "$WORK" && NEMU_TREE="$TREE" bash "$HERE/nemu/cosim/cc.sh" cosim_divergence.c \
    cosim_divergence.exe > div_cc.log 2>&1 ) || { tail -25 "$WORK/div_cc.log"; die "compile failed"; }
grep -q "CC_RC=0" "$WORK/div_cc.log" || { tail -25 "$WORK/div_cc.log"; die "cc.sh did not report CC_RC=0"; }


if grep -qiE "format|varargs" "$WORK/div_cc.log"; then
  grep -iE "format|varargs" "$WORK/div_cc.log" | head -6
  die "the harness compiled with a format warning -- fix the format string, do not run it"
fi
[ -f "$WORK/cosim_divergence.exe" ] || die "harness exe not produced"

echo "== run the three arms on every reference-machine build that is on disk =="



DLLS=""
for spec in "cosim:$TREE_COSIM" "vdot:$TREE_VDOT" "vx:$TREE"; do
  label="${spec%%:*}"; dir="${spec#*:}"; dll="$dir/build/riscv64-nemu-interpreter-so.exe"
  if [ -e "$dll" ]; then DLLS="$DLLS $label=$dll"; else echo "note: no build at $dll (arm skipped)"; fi
done
[ -n "$DLLS" ] || die "no reference-machine build found (looked in $TREE_VDOT and $TREE)"
ALL="$WORK/div_all.log"; : > "$ALL"
NTREE=0
for spec in $DLLS; do
  label="${spec%%=*}"; dll="${spec#*=}"
  echo "[tree] $label dll_sha=$(sha256sum "$dll" | cut -d' ' -f1)" >> "$ALL"
  for armname in all; do
    logf="$WORK/div_${label}_${armname}.log"
    ( cd "$WORK" && ./cosim_divergence.exe "$dll" "$label" "--arm=$armname" \
        > "$logf" 2>&1 )
    rc=$?
    if grep -aqE "^ARM [^ ]+ [^ ]+ " "$logf"; then
      grep -a '^LIBRARY size\|^ARM \|^COSIM_DIV' "$logf" >> "$ALL"
    else







      died=$(grep -aq "died-in-signal" "$logf" && echo yes || echo no)
      lastphase=$(grep -a '  phase: ' "$logf" | tail -1 | sed 's/.*phase: //' | tr -d '\r')
      firsterr=$(grep -a 'SETUP-FAIL' "$logf" | head -1 | cut -c1-70 | tr -d '\r')
      echo "ARM $label $armname retired=CRASH rc=$rc signal_seen=$died vd_written=unknown" \
           "last_phase=${lastphase:-none} first_error=${firsterr:-none}" >> "$ALL"
      grep -a '^LIBRARY size\|^COSIM_DIV' "$logf" >> "$ALL"
    fi
  done
  NTREE=$((NTREE+1))
done

{
  echo "# 由 nemu/cosim/capture_divergence.sh 生成：NEMU 侧对 vm=0 / vstart!=0 的真实反应。"
  echo "# 对侧（SoC 包装层）的读数在 results/xs_soc/wrapper.txt，两边的对账由"
  echo "# sim/nemu_divergence_proof.py 现读两份归档做，判决在本文件末尾。"
  echo "# harness: nemu/cosim/cosim_divergence.c   参考机树数=$NTREE"
  echo "[harness] $(sha256sum "$HERE/nemu/cosim/cosim_divergence.c" | cut -d' ' -f1)"
  echo "[layout]  $(sha256sum "$LAYOUT_SRC" | cut -d' ' -f1)"
  echo
  cat "$ALL"
} > "$OUT" || die "cannot write $OUT"

echo "== cross-check against the SoC side and print the verdict =="
PY=${PY:-/c/Users/lenovo/AppData/Local/Programs/Python/Python311/python}
"$PY" "$HERE/sim/nemu_divergence_proof.py" --from-capture --capture "$(cygpath -w "$OUT" 2>/dev/null || echo "$OUT")" \
  || die "the in-package proof refused the readings"
tail -2 "$OUT"
