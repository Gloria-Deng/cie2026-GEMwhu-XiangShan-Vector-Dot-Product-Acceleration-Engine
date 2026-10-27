#!/usr/bin/env bash














set -u
export PATH=/e/msys64/usr/bin:$PATH
SRC=/d/nemu-vdot
DST=/d/nemu-cosim
PY=/c/Users/lenovo/AppData/Local/Programs/Python/Python311/python

if [ ! -d "$DST" ]; then
  echo "== copying the patched+adapted tree (source files only, no build/) =="
  rm -rf "$DST"
  mkdir -p "$DST"
  (cd "$SRC" && tar -cf - --exclude=./build --exclude=./.git $(ls -A | grep -v '^build$') 2>/dev/null) \
    | (cd "$DST" && tar -xf -)
  echo "copied: $(ls "$DST" | wc -l) top-level entries"
else
  echo "== reusing existing $DST =="
fi

cd "$DST" || exit 2
HM='D:/nemu-cosim'
CFG=configs/riscv64-xs-vdot_defconfig

echo "== vdot still present in this arm? (must be >= 1) =="
grep -c "def_EHelper(vdot)" src/isa/riscv64/instr/rvv/vcompute.h || true

echo "== shrink guest RAM: 0x7ff80000000 -> 0x4000000 (64 MiB) =="
sed -i 's/^CONFIG_MSIZE=0x7ff80000000$/CONFIG_MSIZE=0x4000000/' "$CFG"
grep -n "CONFIG_MSIZE\|SDTRIG" "$CFG"

rm -f .config
make NEMU_HOME="$HM" riscv64-xs-vdot_defconfig > /d/nemu_cosim_cfg.log 2>&1
echo "CFG_RC=$?"
grep -n "CONFIG_MSIZE" .config || echo "  (MSIZE not in .config)"

rm -rf build
make NEMU_HOME="$HM" CXX='g++ -include /d/nemu_shim.hpp' -j8 > /d/nemu_cosim_build.log 2>&1
echo "BUILD_RC=$?"
echo "errors=$(grep -c 'error:' /d/nemu_cosim_build.log)"
ls -la build/*.exe 2>/dev/null
$PY -c "
import hashlib,os
p=r'D:\nemu-cosim\build\riscv64-nemu-interpreter-so.exe'
if os.path.exists(p):
    b=open(p,'rb').read()
    print('cosim_arm size=%d sha256=%s' % (len(b), hashlib.sha256(b).hexdigest()))
else:
    print('COSIM-ARM PRODUCT MISSING')
"
