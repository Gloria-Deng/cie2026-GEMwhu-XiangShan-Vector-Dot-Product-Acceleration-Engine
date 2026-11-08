#!/usr/bin/env bash
#SBATCH --job-name=gemwhu-vdot-wave
#SBATCH --partition=hpxg
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=90000M
#SBATCH --time=02:30:00
#SBATCH --output=vdot-wave-%j.txt
set -euo pipefail
: "${MATERIALS:?set MATERIALS}"
: "${EMU:?set EMU to a waveform-enabled build/emu}"
: "${NEMU_REF:?set NEMU_REF to the patched reference library}"
: "${NEMU_ROOT:?set NEMU_ROOT to its matching source tree}"
export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 MKL_NUM_THREADS=1
ulimit -s unlimited
cd "$MATERIALS"
out="$MATERIALS/results/vdot_wave_$(date +%Y%m%d_%H%M%S)_${SLURM_JOB_ID:-manual}"
python3 tools/build_vdot_wave.py --out "$out" --ref "$NEMU_REF" --nemu-root "$NEMU_ROOT"
# Bounds are simulator cycles, not physical time; widen after inspecting actual coverage.
begin="${WAVE_BEGIN:-0}"
end="${WAVE_END:-30000}"
"$EMU" -i "$out/vdot_wave.bin" --diff="$NEMU_REF" --ram-size=256MB --no-squash \
  -s 1 -C "$end" -b "$begin" -e "$end" --dump-wave --wave-path="$out/vdot.fst" > "$out/emu.txt" 2>&1
python3 tools/check_vdot_wave.py --results "$out"
