#!/usr/bin/env bash
#SBATCH --job-name=vdot-test-free
#SBATCH --partition=hpxg
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=90000M
#SBATCH --time=24:00:00
#SBATCH --output=vdot-test-%j.log
set -euo pipefail
ulimit -s unlimited
: "${SUBMISSION:?set SUBMISSION}"
: "${RUN_ROOT:?set RUN_ROOT from the completed build job}"
export VDOT_TOOLS="${VDOT_TOOLS:-$HOME/project/vdot/tools}"
export RISCV_XPACK="${RISCV_XPACK:-$VDOT_TOOLS/riscv/xpack-riscv-none-elf-gcc-14.2.0-3}"
export PATH="$VDOT_TOOLS/verilator/bin:$VDOT_TOOLS/bin:$RISCV_XPACK/bin:$PATH"
export NOOP_HOME="$RUN_ROOT/XiangShan"
export NEMU_HOME="$RUN_ROOT/NEMU"
python3 "$SUBMISSION/cluster/run_suite.py" --run-root "$RUN_ROOT" --workers "${SIM_WORKERS:-4}" --repeat 3

