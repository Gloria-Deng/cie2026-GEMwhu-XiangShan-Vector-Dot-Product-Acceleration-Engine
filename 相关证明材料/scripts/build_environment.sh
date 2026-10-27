#!/usr/bin/env bash
set -euo pipefail
ulimit -s unlimited
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
export SUBMISSION="${SUBMISSION:-$(dirname "$SCRIPT_DIR")}"
export XS_PRISTINE="${XS_PRISTINE:-$SUBMISSION/sources/XiangShan}"
export NEMU_PRISTINE="${NEMU_PRISTINE:-$SUBMISSION/sources/NEMU}"
: "${RUN_ROOT:?set RUN_ROOT to a new absolute directory}"
SUBMISSION="$(realpath "$SUBMISSION")"
export SUBMISSION XS_PRISTINE NEMU_PRISTINE RUN_ROOT
export VDOT_TOOLS="${VDOT_TOOLS:-$HOME/vdot-basic/tools}"
export RISCV_XPACK="${RISCV_XPACK:-$VDOT_TOOLS/riscv/xpack-riscv-none-elf-gcc-14.2.0-3}"
export PATH="$VDOT_TOOLS/verilator/bin:$VDOT_TOOLS/bin:$RISCV_XPACK/bin:$PATH"
export CHISEL_FIRTOOL_PATH="${CHISEL_FIRTOOL_PATH:-$VDOT_TOOLS/firtool/bin}"
export BUILD_JOBS="${BUILD_JOBS:-2}"
export JVM_XMX="${JVM_XMX:-40G}"
for command in python3 gcc g++ make java mill verilator riscv64-unknown-elf-as; do
  command -v "$command" >/dev/null
done
test ! -e "$RUN_ROOT"
python3 "$SUBMISSION/scripts/check_materials.py"
python3 "$SUBMISSION/tools/prepare_latency_sources.py"
export NOOP_HOME="$RUN_ROOT/XiangShan"
export NEMU_HOME="$RUN_ROOT/NEMU"
export WITH_CHISELDB=0 WITH_CONSTANTIN=0
chmod u+x "$NOOP_HOME/src/main/resources/espresso"
chmod u+x "$NOOP_HOME/yunsuan/src/main/resources/espresso"
find "$NOOP_HOME/scripts" -type f -name '*.sh' -exec chmod u+x {} +
chmod u+x "$NOOP_HOME/scripts/vlsi_mem_gen"
bash "$SUBMISSION/rtl/xiangshan-patch/install.sh" "$NOOP_HOME" > "$RUN_ROOT/xs_install.txt" 2>&1
python3 "$SUBMISSION/nemu/apply_nemu_patch.py" "$NEMU_PRISTINE" "$NEMU_HOME" > "$RUN_ROOT/nemu_install.txt" 2>&1
python3 -B "$SUBMISSION/cluster/build_configuration.py" --run-root "$RUN_ROOT" full \
  --java-heap "$JVM_XMX" --jobs "$BUILD_JOBS" --nemu-jobs "$BUILD_JOBS"
make -C "$NEMU_HOME" riscv64-xs-vdot_sdtrig_defconfig > "$RUN_ROOT/nemu_config.txt" 2>&1
make -C "$NEMU_HOME" -j"$BUILD_JOBS" SHARE=1 > "$RUN_ROOT/nemu_build.txt" 2>&1
make -C "$NOOP_HOME" emu CONFIG=KunminghuV2Config NUM_CORES=1 JVM_XMX="$JVM_XMX" JVM_XSS=32m \
  WITH_CHISELDB=0 WITH_CONSTANTIN=0 EMU_THREADS=0 EMU_TRACE=fst \
  OPT_FAST='-O2 -fno-tree-slp-vectorize' -j"$BUILD_JOBS" > "$RUN_ROOT/emu_build.txt" 2>&1
python3 "$SUBMISSION/scripts/prepare_tests.py" --out "$RUN_ROOT/programs"
test -x "$NOOP_HOME/build/emu"
test -f "$NEMU_HOME/build/riscv64-nemu-interpreter-so"
echo "ENVIRONMENT_BUILD_PASS"
echo "Next: python3 scripts/run_tests.py --run-root \"$RUN_ROOT\" --group all"
