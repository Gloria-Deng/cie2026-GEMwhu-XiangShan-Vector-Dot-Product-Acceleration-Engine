#!/usr/bin/env bash
#SBATCH --job-name=gemwhu-hello
#SBATCH --partition=hpxg
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=90000M
#SBATCH --time=02:30:00
#SBATCH --output=hello-%j.txt
set -euo pipefail
: "${MATERIALS:?set MATERIALS to the uploaded materials directory}"
: "${EMU:?set EMU to XiangShan/build/emu}"
: "${NEMU:?set NEMU to a standalone UARTLite-enabled NEMU executable}"
: "${NEMU_REF:?set NEMU_REF to the matching shared reference library}"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
ulimit -s unlimited
cd "$MATERIALS"
bash stage1/run_all_hello.sh
