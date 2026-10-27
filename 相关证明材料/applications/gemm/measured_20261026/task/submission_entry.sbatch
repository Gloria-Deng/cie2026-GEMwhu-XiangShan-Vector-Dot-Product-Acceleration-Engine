#!/bin/bash
#SBATCH --job-name=vdot-new-measure
#SBATCH --partition=hpxg
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=90000M
#SBATCH --time=24:00:00
#SBATCH --output=measure-%j.txt
set -euo pipefail
ulimit -s unlimited
TASK_ROOT="${TASK_ROOT:-${1:-}}"
: "${TASK_ROOT:?set TASK_ROOT or pass the new measurement directory as the first argument}"
cd "$TASK_ROOT"
export PATH="/project/chensiyuan/vdot/tools/bin:/project/chensiyuan/vdot/tools/riscv/xpack-riscv-none-elf-gcc-14.2.0-3/bin:/usr/bin:/bin"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
export NOOP_HOME=/project/chensiyuan/vdot/run_20261016_m/XiangShan
export NEMU_HOME=/project/chensiyuan/vdot/run_20261016_m/NEMU
EMU="$NOOP_HOME/build/emu"
LIB="$NEMU_HOME/build/riscv64-nemu-interpreter-so"
printf '%s\n' 'a13197d9519a7546e4c6bcae3e4890161f6c07404b57e0288783f27bf5bb7485  /project/chensiyuan/vdot/run_20261016_m/XiangShan/build/emu' 'fcf124d533eb0459a5861717b63c2db4aea608f46cff49edf933500d0cc633ff  /project/chensiyuan/vdot/run_20261016_m/NEMU/build/riscv64-nemu-interpreter-so' | sha256sum --check
test "$SLURM_CPUS_PER_TASK" -eq 16
date -u > started_utc.txt
scontrol show job "$SLURM_JOB_ID" > allocation.txt
python3 cluster/measure_new.py prepare --task-root "$TASK_ROOT"
set +e
python3 applications/gemm/api_benchmark.py execute --programs "$TASK_ROOT/api_programs" \
  --emu "$EMU" --library "$LIB" --out "$TASK_ROOT/api_measurements" \
  --repeat 3 --workers 16 --seconds-limit 7200 > api_execution.txt 2>&1
API_CODE=$?
python3 experiments/throughput/study.py execute --programs "$TASK_ROOT/throughput_programs" \
  --emu "$EMU" --library "$LIB" --out "$TASK_ROOT/throughput_measurements" \
  --repeat 3 --workers 16 --cycle-limit 250000 --seconds-limit 7200 > throughput_execution.txt 2>&1
THROUGHPUT_CODE=$?
set -e
printf 'task,exit_code\napi,%s\nthroughput,%s\n' "$API_CODE" "$THROUGHPUT_CODE" > task_status.csv
date -u > finished_utc.txt
if [ "$API_CODE" -ne 0 ] || [ "$THROUGHPUT_CODE" -ne 0 ]; then exit 1; fi
echo ALL_MEASUREMENTS_COMPLETE
