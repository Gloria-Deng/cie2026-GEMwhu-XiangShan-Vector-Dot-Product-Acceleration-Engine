#!/usr/bin/env bash
#SBATCH --job-name=vdot-build-free
#SBATCH --partition=hpxg
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=90000M
#SBATCH --time=24:00:00
#SBATCH --output=vdot-build-%j.log
set -euo pipefail
ulimit -s unlimited
: "${SUBMISSION:?set SUBMISSION to the uploaded submission directory}"
: "${XS_PRISTINE:?set XS_PRISTINE to the unpatched XiangShan source with populated submodules}"
: "${NEMU_PRISTINE:?set NEMU_PRISTINE to the unpatched NEMU source with populated submodules}"
: "${RUN_ROOT:?set RUN_ROOT to a NEW absolute working directory}"
SUBMISSION="$(realpath "$SUBMISSION")"
export SUBMISSION RUN_ROOT XS_PRISTINE NEMU_PRISTINE
export VDOT_TOOLS="${VDOT_TOOLS:-$HOME/project/vdot/tools}"
export RISCV_XPACK="${RISCV_XPACK:-$VDOT_TOOLS/riscv/xpack-riscv-none-elf-gcc-14.2.0-3}"
export PATH="$VDOT_TOOLS/verilator/bin:$VDOT_TOOLS/bin:$RISCV_XPACK/bin:$PATH"
export CHISEL_FIRTOOL_PATH="${CHISEL_FIRTOOL_PATH:-$VDOT_TOOLS/firtool/bin}"
test ! -e "$RUN_ROOT" || { echo 'RUN_ROOT already exists; use a new directory'; exit 1; }
for cmd in python3 gcc g++ make java mill verilator riscv64-unknown-elf-as; do
  command -v "$cmd" >/dev/null || { echo "missing $cmd"; exit 1; }
done
python3 "$SUBMISSION/cluster/prepare_sources.py"
export NOOP_HOME="$RUN_ROOT/XiangShan"
export NEMU_HOME="$RUN_ROOT/NEMU"
export WITH_CHISELDB=0 WITH_CONSTANTIN=0


for espresso in \
  "$NOOP_HOME/src/main/resources/espresso" \
  "$NOOP_HOME/yunsuan/src/main/resources/espresso"; do
  test -f "$espresso" && chmod u+x "$espresso"
done
find "$NOOP_HOME/scripts" -type f -name '*.sh' -exec chmod u+x {} +
test -f "$NOOP_HOME/scripts/vlsi_mem_gen" && chmod u+x "$NOOP_HOME/scripts/vlsi_mem_gen"

export BUILD_JOBS="${BUILD_JOBS:-8}"
export NEMU_COMPILE_JOBS="${NEMU_COMPILE_JOBS:-8}"
export JVM_XMX="${JVM_XMX:-64G}"
bash "$SUBMISSION/rtl/xiangshan-patch/apply.sh" "$NOOP_HOME" > "$RUN_ROOT/xs_patch.log" 2>&1
python3 "$SUBMISSION/nemu/apply_nemu_patch.py" "$NEMU_PRISTINE" "$NEMU_HOME" > "$RUN_ROOT/nemu_patch.log" 2>&1
python3 -B "$SUBMISSION/cluster/build_configuration.py" --run-root "$RUN_ROOT" full \
  --java-heap "$JVM_XMX" --jobs "$BUILD_JOBS" --nemu-jobs "$NEMU_COMPILE_JOBS"
make -C "$NEMU_HOME" riscv64-xs-vdot_sdtrig_defconfig > "$RUN_ROOT/nemu_config.log" 2>&1
make -C "$NEMU_HOME" -j"$NEMU_COMPILE_JOBS" SHARE=1 > "$RUN_ROOT/nemu_build.log" 2>&1
make -C "$NOOP_HOME" emu CONFIG=KunminghuV2Config NUM_CORES=1 JVM_XMX="$JVM_XMX" JVM_XSS=32m \
  WITH_CHISELDB=0 WITH_CONSTANTIN=0 EMU_THREADS=0 EMU_TRACE=fst \
  OPT_FAST='-O2 -fno-tree-slp-vectorize' -j"$BUILD_JOBS" > "$RUN_ROOT/emu_build.log" 2>&1
python3 "$SUBMISSION/tools/gen_cluster_programs.py" --out "$RUN_ROOT/programs" > "$RUN_ROOT/program_build.log" 2>&1
python3 "$SUBMISSION/tools/run_instruction_cosim.py" --nemu-root "$NEMU_HOME" \
  --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --out "$SUBMISSION/results/current/cluster_instruction_cosim.json"
python3 "$SUBMISSION/tools/validate_programs_nemu.py" --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --programs "$RUN_ROOT/programs" > "$RUN_ROOT/program_precheck.log" 2>&1
python3 "$SUBMISSION/cluster/build_manifest.py"
echo "BUILD PASS: $RUN_ROOT. Next: sbatch --export=ALL cluster/test.sbatch"
