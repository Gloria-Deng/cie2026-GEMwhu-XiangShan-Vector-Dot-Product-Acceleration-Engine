#!/usr/bin/env bash
#SBATCH --job-name=vdot-landing-smoke
#SBATCH --partition=hpxg
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16000M
#SBATCH --time=00:20:00
#SBATCH --output=vdot-landing-smoke-%j.log
set -euo pipefail
: "${SUBMISSION:?}"; : "${RUN_ROOT:?}"
export VDOT_TOOLS="${VDOT_TOOLS:-$HOME/project/vdot/tools}"
export RISCV_XPACK="$VDOT_TOOLS/riscv/xpack-riscv-none-elf-gcc-14.2.0-3"
export PATH="$VDOT_TOOLS/verilator/bin:$VDOT_TOOLS/bin:$RISCV_XPACK/bin:$PATH"
OUT="$RUN_ROOT/landing_smoke"; mkdir -p "$OUT"
riscv64-unknown-elf-gcc -march=rv64gcv -mabi=lp64d -nostdlib -ffreestanding -O2 \
  -mcmodel=medany -Wl,--build-id=none -T "$SUBMISSION/sim/baremetal/link_landing.ld" -e _start \
  -o "$OUT/smoke.elf" "$SUBMISSION/sim/baremetal/min_landing.S" "$SUBMISSION/sim/baremetal/landing.S"
riscv64-unknown-elf-objcopy -O binary "$OUT/smoke.elf" "$OUT/smoke.bin"
riscv64-unknown-elf-nm -n "$OUT/smoke.elf" | grep -E 'LANDING_BASE|_start'
"$RUN_ROOT/XiangShan/build/emu" -i "$OUT/smoke.bin" \
  --diff="$RUN_ROOT/NEMU/build/riscv64-nemu-interpreter-so" \
  --ram-size=256MB --no-squash -s 1 -C 20000 > "$OUT/smoke.emu.log" 2>&1 || true
tail -30 "$OUT/smoke.emu.log"
echo SMOKE_DONE
