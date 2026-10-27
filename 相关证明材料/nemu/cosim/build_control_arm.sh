#!/usr/bin/env bash










set -u
export PATH=/e/msys64/usr/bin:$PATH
SRC=/d/nemu-vanilla
DST=/d/nemu-vanilla-cosimarm
PY=/c/Users/lenovo/AppData/Local/Programs/Python/Python311/python

if [ ! -d "$DST" ]; then
  mkdir -p "$DST"
  (cd "$SRC" && tar -cf - --exclude=./build $(ls -A | grep -v '^build$')) | (cd "$DST" && tar -xf -)
fi
cd "$DST" || exit 2

echo "== this arm must be UNPATCHED (vdot helper count = 0) =="
grep -c "def_EHelper(vdot)" src/isa/riscv64/instr/rvv/vcompute.h || echo 0

CFG=configs/riscv64-xs-ref_defconfig
grep -q "^# CONFIG_RV_SDTRIG is not set" "$CFG" || \
  sed -i 's/^CONFIG_RV_SDTRIG=y$/# CONFIG_RV_SDTRIG is not set/' "$CFG"
sed -i 's/^CONFIG_MSIZE=0x7ff80000000$/CONFIG_MSIZE=0x4000000/' "$CFG"
grep -n "SDTRIG\|CONFIG_MSIZE\|USE_MMAP" "$CFG"

"$PY" /d/nemu_patch_output_h.py "$DST" || exit 1

rm -f .config
make NEMU_HOME='D:/nemu-vanilla-cosimarm' riscv64-xs-ref_defconfig > /d/vctrl_cfg.log 2>&1
echo "CFG_RC=$?"
rm -rf build
make NEMU_HOME='D:/nemu-vanilla-cosimarm' CXX='g++ -include /d/nemu_shim.hpp' -j8 \
     > /d/vctrl_build.log 2>&1
echo "BUILD_RC=$?  errors=$(grep -c 'error:' /d/vctrl_build.log || true)"
ls -la build/*.exe 2>/dev/null
"$PY" -c "
import hashlib
p=r'D:\nemu-vanilla-cosimarm\build\riscv64-nemu-interpreter-so.exe'
b=open(p,'rb').read()
print('vanilla_arm size=%d sha256=%s' % (len(b), hashlib.sha256(b).hexdigest()))
"
echo "== vdot must NOT be exported by this arm =="
objdump -p build/riscv64-nemu-interpreter-so.exe 2>/dev/null \
  | grep -aE "^\s+\[\s*[0-9]+\]\s+\+base" | grep -ac vdot || echo 0
