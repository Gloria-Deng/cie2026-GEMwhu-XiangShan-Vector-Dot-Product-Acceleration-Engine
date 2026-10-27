#!/usr/bin/env bash









set -u
export PATH=/e/msys64/usr/bin:$PATH
NM="${NEMU_TREE:-/d/nemu-vdot}"
SRC="$1"; OUT="$2"
gcc -o "$OUT" "$SRC" \
  -I"$NM/include" -I"$NM/lib-include" -I"$NM/src/isa/riscv64/include" \
  -I"$NM/src/engine/interpreter" \
  -I"$NM/resource/softfloat/repo/source/include" \
  -I"$NM/resource/softfloat/repo/source/RISCV" \
  -D__ISA__=riscv64 -D__ISA_riscv64__=1 -D_SHARE=1 \
  -include "$NM/include/generated/autoconf.h" \
  -Wall -Wno-error -O0 -g
rc=$?
echo "CC_RC=$rc"
exit $rc
