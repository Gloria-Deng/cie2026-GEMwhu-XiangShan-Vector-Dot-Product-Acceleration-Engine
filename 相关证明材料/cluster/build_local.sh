#!/usr/bin/env bash

set -euo pipefail
ulimit -s unlimited

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
export SUBMISSION="${SUBMISSION:-$(dirname "$SCRIPT_DIR")}"
SUBMISSION="$(realpath "$SUBMISSION")"
export XS_PRISTINE="${XS_PRISTINE:-$SUBMISSION/sources/XiangShan}"
export NEMU_PRISTINE="${NEMU_PRISTINE:-$SUBMISSION/sources/NEMU}"
: "${RUN_ROOT:?set RUN_ROOT to a NEW absolute working directory}"
export RUN_ROOT
test ! -e "$RUN_ROOT" || { echo 'RUN_ROOT already exists; use a new directory'; exit 1; }
for cmd in python3 gcc g++ make git java mill verilator riscv64-unknown-elf-as riscv64-unknown-elf-ld riscv64-unknown-elf-objcopy riscv64-unknown-elf-nm riscv64-unknown-elf-objdump; do
  command -v "$cmd" >/dev/null || { echo "missing $cmd"; exit 1; }
done
export BUILD_JOBS="${BUILD_JOBS:-2}"
export JVM_XMX="${JVM_XMX:-40G}"
export WITH_CHISELDB=0 WITH_CONSTANTIN=0
export REPRO_OUTPUT="$SUBMISSION/results/reproduced"
mkdir -p "$REPRO_OUTPUT"

python3 "$SUBMISSION/tools/prepare_latency_sources.py"
export NOOP_HOME="$RUN_ROOT/XiangShan"
export NEMU_HOME="$RUN_ROOT/NEMU"
for espresso in \
  "$NOOP_HOME/src/main/resources/espresso" \
  "$NOOP_HOME/yunsuan/src/main/resources/espresso"; do
  test -f "$espresso" && chmod u+x "$espresso"
done
find "$NOOP_HOME/scripts" -type f -name '*.sh' -exec chmod u+x {} +
test -f "$NOOP_HOME/scripts/vlsi_mem_gen" && chmod u+x "$NOOP_HOME/scripts/vlsi_mem_gen"

bash "$SUBMISSION/rtl/xiangshan-patch/apply.sh" "$NOOP_HOME" > "$RUN_ROOT/xs_patch.log" 2>&1
python3 "$SUBMISSION/nemu/apply_nemu_patch.py" "$NEMU_PRISTINE" "$NEMU_HOME" > "$RUN_ROOT/nemu_patch.log" 2>&1
python3 -B "$SUBMISSION/cluster/build_configuration.py" --run-root "$RUN_ROOT" full \
  --java-heap "$JVM_XMX" --jobs "$BUILD_JOBS" --nemu-jobs "$BUILD_JOBS"
make -C "$NEMU_HOME" riscv64-xs-vdot_sdtrig_defconfig > "$RUN_ROOT/nemu_config.log" 2>&1
make -C "$NEMU_HOME" -j"$BUILD_JOBS" SHARE=1 > "$RUN_ROOT/nemu_build.log" 2>&1
make -C "$NOOP_HOME" emu CONFIG=KunminghuV2Config NUM_CORES=1 JVM_XMX="$JVM_XMX" JVM_XSS=32m \
  WITH_CHISELDB=0 WITH_CONSTANTIN=0 EMU_THREADS=0 EMU_TRACE=fst \
  OPT_FAST='-O2 -fno-tree-slp-vectorize' -j"$BUILD_JOBS" > "$RUN_ROOT/emu_build.log" 2>&1
python3 "$SUBMISSION/tools/gen_cluster_programs.py" --out "$RUN_ROOT/programs" > "$RUN_ROOT/program_build.log" 2>&1
python3 "$SUBMISSION/tools/run_nemu_success.py" --nemu-root "$NEMU_HOME" \
  --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --out "$REPRO_OUTPUT/nemu_success.json"
python3 "$SUBMISSION/tools/validate_nemu_success.py" \
  --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --programs "$RUN_ROOT/programs" --out "$REPRO_OUTPUT/programs_nemu" \
  > "$RUN_ROOT/program_precheck.log" 2>&1
python3 "$SUBMISSION/cluster/build_manifest.py"
python3 - <<'PY'
import hashlib
import json
import os
from pathlib import Path
root = Path(os.environ['SUBMISSION'])
path = Path(os.environ['RUN_ROOT']) / 'build_manifest.json'
data = json.loads(path.read_text())
for name in ('cluster/build_local.sh', 'cluster/test_local.sh',
             'scripts/run_full.py', 'scripts/run_one.py',
             'tools/run_nemu_success.py', 'tools/validate_nemu_success.py'):
    data['inputs'][name] = hashlib.sha256((root / name).read_bytes()).hexdigest()
path.write_text(json.dumps(data, indent=2) + '\n')
PY
echo "BUILD PASS: $RUN_ROOT"
echo "Next: bash $SUBMISSION/cluster/test_local.sh"
