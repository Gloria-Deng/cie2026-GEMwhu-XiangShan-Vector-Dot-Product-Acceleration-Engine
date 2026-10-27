#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
: "${XS_EMU:?Set XS_EMU to the compatible KunminghuV2 emu executable}"
: "${NEMU_REF:?Set NEMU_REF to the compatible 128-bit NEMU reference library}"
out=${1:?Pass a new absolute output directory}
case "$out" in /*) ;; *) printf '%s\n' 'Output directory must be absolute' >&2; exit 2;; esac
if [[ -e "$out" ]]; then printf '%s\n' 'Output directory already exists' >&2; exit 2; fi
mkdir -p -- "$out"
"$XS_EMU" -i "$root/gen/cluster_programs/vadd_full_register.bin" \
  --diff="$NEMU_REF" --ram-size=256MB --no-squash \
  -C 30000 -b 0 -e 10000 --dump-wave --wave-path="$out/vadd.fst" \
  >"$out/simulation_output.txt" 2>&1
