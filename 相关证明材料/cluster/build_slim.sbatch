#!/usr/bin/env bash
#SBATCH --job-name=vdot-slim-compile
#SBATCH --partition=hpxg
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=90000M
#SBATCH --time=24:00:00
#SBATCH --output=vdot-slim-compile-%j.txt
set -euo pipefail
ulimit -s unlimited
: "${SUBMISSION:?set SUBMISSION to the extracted slim program directory}"
: "${RUN_ROOT:?set RUN_ROOT to a new absolute build directory}"
SUBMISSION="$(realpath "$SUBMISSION")"
export SUBMISSION RUN_ROOT
export VDOT_TOOLS="${VDOT_TOOLS:-/project/chensiyuan/vdot/tools}"
export RISCV_XPACK="${RISCV_XPACK:-$VDOT_TOOLS/riscv/xpack-riscv-none-elf-gcc-14.2.0-3}"
export PATH="$VDOT_TOOLS/firtool/bin:$VDOT_TOOLS/verilator/bin:$VDOT_TOOLS/bin:$RISCV_XPACK/bin:$PATH"
export CHISEL_FIRTOOL_PATH="$VDOT_TOOLS/firtool/bin"
export PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
export BUILD_JOBS="${BUILD_JOBS:-8}"
export NOOP_HOME="$RUN_ROOT/XiangShan" NEMU_HOME="$RUN_ROOT/NEMU"
python3 -B "$SUBMISSION/run_latency.py" build --work "$RUN_ROOT" \
  --jobs "$BUILD_JOBS" --java-heap "${JVM_XMX:-64G}"
python3 -B "$SUBMISSION/tools/run_nemu_success.py" --nemu-root "$NEMU_HOME" \
  --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --out "$SUBMISSION/results/reproduced/slim_compile/nemu_vectors.json"
python3 -B "$SUBMISSION/tools/validate_nemu_success.py" \
  --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --programs "$RUN_ROOT/programs" --out "$SUBMISSION/results/reproduced/slim_compile/nemu_programs"
python3 -B "$SUBMISSION/cluster/build_manifest.py"
echo "SLIM_FULL_COMPILE_PASS $RUN_ROOT"
