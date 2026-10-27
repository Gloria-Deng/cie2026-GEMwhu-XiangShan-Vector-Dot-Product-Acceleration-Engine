#!/usr/bin/env bash
#SBATCH --job-name=vdot-test
#SBATCH --partition=9a14b
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=96
#SBATCH --mem=100G
#SBATCH --time=24:00:00
#SBATCH --output=vdot-test-%j.log
set -euo pipefail
ulimit -s unlimited
: "${SUBMISSION:?set SUBMISSION}"
: "${RUN_ROOT:?set RUN_ROOT from the completed build job}"
export NOOP_HOME="$RUN_ROOT/XiangShan"
export NEMU_HOME="$RUN_ROOT/NEMU"
python3 "$SUBMISSION/cluster/run_suite.py" --run-root "$RUN_ROOT" --workers "${SIM_WORKERS:-8}" --repeat 3

