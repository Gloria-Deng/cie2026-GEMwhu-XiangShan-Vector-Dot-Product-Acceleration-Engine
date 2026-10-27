#!/usr/bin/env bash
#SBATCH --job-name=vdot-resume
#SBATCH --partition=hpxg
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=90000M
#SBATCH --time=24:00:00
#SBATCH --output=vdot-resume-%j.log
set -euo pipefail
ulimit -s unlimited
: "${SUBMISSION:?set SUBMISSION}"
: "${RUN_ROOT:?set RUN_ROOT to the EXISTING timed-out build directory}"
export VDOT_TOOLS="${VDOT_TOOLS:-$HOME/project/vdot/tools}"
export RISCV_XPACK="$VDOT_TOOLS/riscv/xpack-riscv-none-elf-gcc-14.2.0-3"
export PATH="$VDOT_TOOLS/verilator/bin:$VDOT_TOOLS/bin:$RISCV_XPACK/bin:$PATH"
export NOOP_HOME="$RUN_ROOT/XiangShan"
export NEMU_HOME="$RUN_ROOT/NEMU"
export EMU_COMPILE_JOBS="${EMU_COMPILE_JOBS:-4}"
case "$EMU_COMPILE_JOBS" in 1|2|3|4) ;; *) echo 'EMU_COMPILE_JOBS must be 1, 2, 3 or 4'; exit 1 ;; esac
compile_dir="$NOOP_HOME/build/verilator-compile"
test -f "$compile_dir/VSimTop.mk"
test -f "$NOOP_HOME/build/rtl/SimTop.sv"
test -f "$NEMU_HOME/build/riscv64-nemu-interpreter-so"
echo "Resuming existing C++ build: $compile_dir; jobs=$EMU_COMPILE_JOBS"
python3 -B "$SUBMISSION/cluster/build_configuration.py" --run-root "$RUN_ROOT" resume \
  --jobs "$EMU_COMPILE_JOBS"
make -C "$compile_dir" -f VSimTop.mk -j"$EMU_COMPILE_JOBS" \
  VM_PARALLEL_BUILDS=1 OPT_SLOW=-O0 \
  OPT_FAST='-O2 -fno-tree-slp-vectorize' \
  PGO_CFLAGS='' PGO_LDFLAGS='' OBJCACHE='' \
  > "$RUN_ROOT/emu_resume.log" 2>&1
test -x "$compile_dir/emu"
cp "$compile_dir/emu" "$NOOP_HOME/build/emu"
python3 "$SUBMISSION/tools/gen_cluster_programs.py" --out "$RUN_ROOT/programs" > "$RUN_ROOT/program_build.log" 2>&1
python3 "$SUBMISSION/tools/run_instruction_cosim.py" --nemu-root "$NEMU_HOME" \
  --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --out "$SUBMISSION/results/current/cluster_instruction_cosim.json"
python3 "$SUBMISSION/tools/validate_programs_nemu.py" --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --programs "$RUN_ROOT/programs" > "$RUN_ROOT/program_precheck.log" 2>&1
python3 "$SUBMISSION/cluster/build_manifest.py"
echo "BUILD PASS: $RUN_ROOT"
