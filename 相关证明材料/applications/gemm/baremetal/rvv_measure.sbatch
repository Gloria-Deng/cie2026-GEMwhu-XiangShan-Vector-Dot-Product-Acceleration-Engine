#!/bin/bash
#SBATCH --job-name=gemm-rvv-t4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=90000M
#SBATCH --time=24:00:00
#SBATCH --output=gemm-rvv-%j.txt
set -euo pipefail
ulimit -s unlimited
: "${PROOF_ROOT:?set PROOF_ROOT to the source material directory}"
: "${NOOP_HOME:?set NOOP_HOME to the XiangShan source directory}"
: "${NEMU_HOME:?set NEMU_HOME to the matching NEMU source directory}"
cd "$PROOF_ROOT"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
STAMP="$(date +%Y%m%d)_${SLURM_JOB_ID:?submit this file with sbatch}"
OUT="applications/gemm/measured_${STAMP}"
test ! -e "$OUT" || { echo "output directory exists: $OUT" >&2; exit 1; }
mkdir -p "$OUT"
python3 -B experiments/throughput/build_reference.py --nemu-source "$NEMU_HOME" --out "$OUT/reference"
python3 -B applications/gemm/rvv_benchmark.py generate --out "$OUT/programs" \
  --prefix "${RISCV_PREFIX:-riscv64-unknown-elf-}"
python3 -B applications/gemm/rvv_benchmark.py functional --programs "$OUT/programs" \
  --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --layout "$OUT/reference/cosim_layout.h" --out "$OUT/functional"
python3 -B applications/gemm/rvv_benchmark.py execute --programs "$OUT/programs" \
  --emu "$NOOP_HOME/build/emu" --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --out "$OUT/execution" --repeat 3 --workers 16 --seconds-limit 7200
echo T4_MEASUREMENT_COMPLETE
