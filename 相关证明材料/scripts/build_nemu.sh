#!/usr/bin/env bash
set -euo pipefail
PROJECT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
NEMU_PRISTINE="$PROJECT/sources/NEMU"
NEMU_WORK="${NEMU_WORK:-$HOME/vdot31/nemu_work/NEMU}"
for command in python3 gcc g++ make; do
  command -v "$command" >/dev/null || { echo "Missing required program: $command"; exit 1; }
done
test -f "$NEMU_PRISTINE/src/nemu-main.c" || { echo 'Missing sources/NEMU'; exit 1; }
test ! -e "$NEMU_WORK" || { echo "Choose a new NEMU_WORK directory: $NEMU_WORK"; exit 1; }
mkdir -p "$(dirname -- "$NEMU_WORK")"
python3 "$PROJECT/nemu/apply_nemu_patch.py" "$NEMU_PRISTINE" "$NEMU_WORK"
export NEMU_HOME="$NEMU_WORK"
make -C "$NEMU_HOME" riscv64-xs-vdot_sdtrig_defconfig
make -C "$NEMU_HOME" -j"${BUILD_JOBS:-8}" SHARE=1
python3 "$PROJECT/tools/run_nemu_success.py" \
  --nemu-root "$NEMU_HOME" \
  --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --out "$PROJECT/results/reproduced/nemu.txt"
echo "NEMU_BUILD_PASS $NEMU_HOME/build/riscv64-nemu-interpreter-so"
