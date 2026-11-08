#!/bin/bash
#SBATCH --job-name=rvv-opt
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=48:00:00
#SBATCH --output=rvv-opt-%j.out

# Created after 116 local NEMU programs passed on 2026-10-29.
# This file does not submit itself. Configure partition/account as required.
set -euo pipefail
: "${VDOT_MATERIALS:?请设置相关证明材料的Linux绝对路径}"
: "${VDOT_PROGRAMS:?请设置由--optimized生成的程序目录}"
: "${VDOT_NEMU_RUNNER:?请设置匹配的NEMU执行器}"
: "${VDOT_NEMU_LIBRARY:?请设置支持CUSTOM_VDOT的NEMU共享库}"
: "${VDOT_EMU:?请设置支持vdot及DiffTest的香山emu}"
cd "$VDOT_MATERIALS"
OUT="${VDOT_OPT_RESULTS:-experiments/throughput/measured_$(date +%Y%m%d)_optimized}"
WORKERS="${VDOT_OPT_WORKERS:-${SLURM_CPUS_PER_TASK:-1}}"
if [[ -e "$OUT" || -e "${OUT}_functional" ]]; then
    printf '%s\n' '输出目录已存在，请使用新目录' >&2
    exit 1
fi
python3 experiments/throughput/study.py estimate --programs "$VDOT_PROGRAMS" \
    --repeat 3 --workers "$WORKERS" --cycle-limit 250000 --seconds-limit 7200
python3 experiments/throughput/study.py functional --programs "$VDOT_PROGRAMS" \
    --runner "$VDOT_NEMU_RUNNER" --library "$VDOT_NEMU_LIBRARY" --out "${OUT}_functional"
python3 experiments/throughput/study.py execute --programs "$VDOT_PROGRAMS" \
    --emu "$VDOT_EMU" --library "$VDOT_NEMU_LIBRARY" --out "$OUT" \
    --repeat 3 --workers "$WORKERS" --cycle-limit 250000 --seconds-limit 7200
python3 scripts/check_measurements_opt.py --results "$OUT" --out "$OUT/reviewed" --plot
