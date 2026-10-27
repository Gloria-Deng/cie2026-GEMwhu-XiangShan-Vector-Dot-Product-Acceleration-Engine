#!/usr/bin/env bash





















set -u
export PATH=/e/msys64/usr/bin:$PATH
export TMP=/tmp TEMP=/tmp TMPDIR=/tmp
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SRC=/d/nemu-vdot
DST=/d/nemu-vx
HM='D:/nemu-vx'
PY=/c/Users/lenovo/AppData/Local/Programs/Python/Python311/python
PATCHER="$HERE/nemu/apply_nemu_vx_patch.py"
CFG=configs/riscv64-xs-vdot_defconfig
LOG=/d/nemu_vx_arm.log

say () { echo "$@" | tee -a "$LOG"; }
: > "$LOG"

[ -d "$SRC" ] || { say "SETUP-FAIL: source tree $SRC missing"; exit 2; }
[ -f "$PATCHER" ] || { say "SETUP-FAIL: patcher $PATCHER missing"; exit 2; }




$PY - "$SRC" <<'PYEOF' | tee -a "$LOG"
import io, sys
src = sys.argv[1] + "/src/isa/riscv64/instr/rvv/"
vc = io.open(src + "vcompute.h", encoding="utf-8", errors="replace").read()
dc = io.open(src + "decode.h", encoding="utf-8", errors="replace").read()
ok = (vc.count("{") == vc.count("}") and "def_EHelper(vdot) {" in vc
      and "vdot_vx" not in vc and "vdot_vx" not in dc)
print("SRC_GUARD vcompute_braces=%d/%d balanced=%s  vv_helper=%s  vx_leaked=%s  ok=%s" % (
    vc.count("{"), vc.count("}"), vc.count("{") == vc.count("}"),
    "def_EHelper(vdot) {" in vc, ("vdot_vx" in vc or "vdot_vx" in dc), ok))
sys.exit(0 if ok else 1)
PYEOF
[ "${PIPESTATUS[0]}" = "0" ] || { say "SETUP-FAIL: certified tree $SRC guard did not pass"; exit 2; }

if [ ! -d "$DST" ]; then
  say "== copying the vv tree source-only (no build/, no .git) =="
  mkdir -p "$DST"
  (cd "$SRC" && tar -cf - --exclude=./build --exclude=./.git $(ls -A | grep -v '^build$') 2>/dev/null) \
    | (cd "$DST" && tar -xf -)
  say "copied: $(ls "$DST" | wc -l) top-level entries"
else
  say "== reusing existing $DST (delete it to rebuild from a fresh copy) =="
fi
[ -f "$DST/src/isa/riscv64/instr/rvv/vcompute.h" ] || { say "SETUP-FAIL: copy incomplete"; exit 2; }

say "== patch: --check, then --apply, then a read-only --check of the result =="
$PY "$PATCHER" --check "$DST" >> "$LOG" 2>&1; say "CHECK_RC=$?"
$PY "$PATCHER" --apply "$DST" >> "$LOG" 2>&1
APPLY_RC_LAST=$?; say "APPLY_RC=$APPLY_RC_LAST"
case "$APPLY_RC_LAST" in 0) ;; *) say "SETUP-FAIL: patcher exited $APPLY_RC_LAST"; exit 2;; esac
$PY "$PATCHER" --check "$DST" >> "$LOG" 2>&1; say "RECHECK_RC=$?"



LAST_CHECK=$(grep -a '^VDOTVX-PATCH-CHECK' "$LOG" | tail -1)
say "last check line: ${LAST_CHECK:-NO-VERDICT-LINE}"
case "$LAST_CHECK" in *"planned=0"*) ;; *) say "SETUP-FAIL: re-check still plans edits"; exit 2;; esac
for want in vx_name_row_present mvx_scope_has_101100 vx_helper_present vv_helper_present; do
  grep -Eq "^FACT[[:space:]]+$want[[:space:]]+True$" "$LOG" \
    || { say "SETUP-FAIL: postcondition not met: $want"; exit 2; }
  say "POSTCOND ok: $want"
done

say "== the three edits as they now read on disk =="
grep -n "VDOT_INSTR_TERNARY" "$DST/src/isa/riscv64/include/isa-all-instr.h" | tee -a "$LOG"
awk 'f&&/def_INSTR_TAB/{print NR": "$0} /def_THelper\(vopmvx\)/{f=1} f&&/^}/{f=0}' \
  "$DST/src/isa/riscv64/instr/rvv/decode.h" | grep -a "1011" | tee -a "$LOG"

say "== shrink guest RAM to what this host can actually touch (as the other cosim arms) =="
sed -i 's/^CONFIG_MSIZE=0x7ff80000000$/CONFIG_MSIZE=0x4000000/' "$DST/$CFG"
grep -n "CONFIG_MSIZE\|CUSTOM_VDOT" "$DST/$CFG" | tee -a "$LOG"

say "== compiler identity (the arm must name its own toolchain) =="
say "CC_RESOLVED=$(command -v gcc || echo NONE)  $(gcc --version 2>/dev/null | head -1)"

cd "$DST" || exit 2
rm -f .config
make NEMU_HOME="$HM" riscv64-xs-vdot_defconfig > /d/nemu_vx_cfg.log 2>&1
say "CFG_RC=$?"
grep -n "CONFIG_MSIZE" .config | tee -a "$LOG" || say "  (MSIZE not in .config)"

rm -rf build
make NEMU_HOME="$HM" CXX='g++ -include /d/nemu_shim.hpp' -j8 > /d/nemu_vx_build.log 2>&1
BUILD_RC=$?
say "BUILD_RC=$BUILD_RC"
say "objects=$(find build -name '*.o' 2>/dev/null | wc -l)  errors=$(grep -c 'error:' /d/nemu_vx_build.log)  (0 objects with 0 error: lines = a temp-dir/toolchain fault, not a source fault)"
grep -a -m6 "error:" /d/nemu_vx_build.log | tee -a "$LOG"
[ "$BUILD_RC" = "0" ] || { say "VX_ARM_DONE build_rc=$BUILD_RC verdict=BUILD-FAILED"; exit 1; }

$PY - <<'PYEOF' | tee -a "$LOG"
import hashlib, os, sys
def sha(p):
    b = open(p, 'rb').read()
    return hashlib.sha256(b).hexdigest(), len(b)
so = r'D:\nemu-vx\build\riscv64-nemu-interpreter-so.exe'
if not os.path.exists(so):
    print('VX-ARM PRODUCT MISSING'); sys.exit(1)
h, n = sha(so)
print('vx_arm_so size=%d sha256=%s' % (n, h))
for rel in ('src/isa/riscv64/instr/rvv/decode.h',
            'src/isa/riscv64/instr/rvv/vcompute.h',
            'src/isa/riscv64/include/isa-all-instr.h'):
    hh, nn = sha(os.path.join(r'D:\nemu-vx', rel))
    print('VX_TREE_FILE %s sha256=%s bytes=%d' % (rel, hh, nn))
PYEOF
[ "${PIPESTATUS[0]}" = "0" ] || { say "VX_ARM_DONE verdict=PRODUCT-MISSING"; exit 1; }
say "VX_ARM_DONE build_rc=0 verdict=OK"
