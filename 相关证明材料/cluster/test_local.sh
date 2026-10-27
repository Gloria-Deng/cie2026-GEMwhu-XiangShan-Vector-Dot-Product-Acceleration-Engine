#!/usr/bin/env bash

set -euo pipefail
ulimit -s unlimited
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
export SUBMISSION="${SUBMISSION:-$(dirname "$SCRIPT_DIR")}"
: "${RUN_ROOT:?set RUN_ROOT to the completed build directory}"
export NOOP_HOME="$RUN_ROOT/XiangShan"
export NEMU_HOME="$RUN_ROOT/NEMU"
python3 "$SUBMISSION/scripts/run_full.py" --run-root "$RUN_ROOT" \
  --workers "${SIM_WORKERS:-4}" --repeat 3
