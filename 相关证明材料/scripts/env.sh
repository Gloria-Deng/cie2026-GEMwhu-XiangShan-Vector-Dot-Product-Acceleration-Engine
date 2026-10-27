#!/usr/bin/env bash

export SUBMISSION="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
export VDOT_TOOLS="${VDOT_TOOLS:-$HOME/vdot31/tools}"
export XS_PRISTINE="$SUBMISSION/sources/XiangShan"
export NEMU_PRISTINE="$SUBMISSION/sources/NEMU"
export RUN_ROOT="${RUN_ROOT:-$HOME/vdot31/full_work}"
export NEMU_WORK="${NEMU_WORK:-$HOME/vdot31/nemu_work/NEMU}"
export RISCV_XPACK="$VDOT_TOOLS/riscv/xpack-riscv-none-elf-gcc-14.2.0-3"
export CHISEL_FIRTOOL_PATH="$VDOT_TOOLS/firtool/bin"
export JAVA_HOME="${VDOT_JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-amd64}"
export PATH="$JAVA_HOME/bin:$VDOT_TOOLS/verilator/bin:$VDOT_TOOLS/bin:$RISCV_XPACK/bin:$PATH"
export BUILD_JOBS="${BUILD_JOBS:-8}"
export SIM_WORKERS="${SIM_WORKERS:-4}"
