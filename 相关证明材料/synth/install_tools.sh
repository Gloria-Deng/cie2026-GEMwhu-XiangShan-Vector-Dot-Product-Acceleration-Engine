#!/usr/bin/env bash
set -euo pipefail
TOOLS_DIR="${TOOLS_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/cie-vdot-synth}"
BUILD_JOBS="${BUILD_JOBS:-2}"
mkdir -p "$TOOLS_DIR"
TOOLS_DIR="$(cd "$TOOLS_DIR" && pwd)"
for tool in curl tar unzip make cmake gcc g++ bison flex swig yosys; do
  if ! command -v "$tool" >/dev/null; then
    echo "Missing $tool. Install dependencies from synth/README.md." >&2
    exit 1
  fi
done
fetch() { curl --fail --location --retry 3 "$1" -o "$2"; }
if [[ ! -x "$TOOLS_DIR/sv2v-Linux/sv2v" ]]; then
  fetch https://github.com/zachjs/sv2v/releases/download/v0.0.13/sv2v-Linux.zip "$TOOLS_DIR/sv2v.zip"
  unzip -o "$TOOLS_DIR/sv2v.zip" -d "$TOOLS_DIR"
  chmod +x "$TOOLS_DIR/sv2v-Linux/sv2v"
fi
if [[ ! -f "$TOOLS_DIR/cudd-install/lib/libcudd.so" ]]; then
  fetch https://codeload.github.com/ivmai/cudd/tar.gz/refs/tags/cudd-3.0.0 "$TOOLS_DIR/cudd.tar.gz"
  mkdir -p "$TOOLS_DIR/cudd"
  tar xf "$TOOLS_DIR/cudd.tar.gz" -C "$TOOLS_DIR/cudd" --strip-components=1
  (
    cd "$TOOLS_DIR/cudd"
    ./configure --prefix="$TOOLS_DIR/cudd-install" --enable-shared --enable-obj --enable-dddmp
    make -j"$BUILD_JOBS"
    make install
  )
fi
if [[ ! -x "$TOOLS_DIR/opensta/build/sta" ]]; then
  fetch https://codeload.github.com/The-OpenROAD-Project/OpenSTA/tar.gz/a50641666c6e2fd19ff0226f9b6300d876bf8613 "$TOOLS_DIR/opensta.tar.gz"
  mkdir -p "$TOOLS_DIR/opensta"
  tar xf "$TOOLS_DIR/opensta.tar.gz" -C "$TOOLS_DIR/opensta" --strip-components=1
  cmake -S "$TOOLS_DIR/opensta" -B "$TOOLS_DIR/opensta/build" \
    -DCUDD_DIR="$TOOLS_DIR/cudd-install" -DUSE_TCL_READLINE=OFF -DBUILD_TESTS=OFF
  cmake --build "$TOOLS_DIR/opensta/build" -j"$BUILD_JOBS"
fi
fetch https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD-flow-scripts/6c6fc7e21b2d0b5b88b1a52d0a5860ea4d88e9e5/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib \
  "$TOOLS_DIR/NangateOpenCellLibrary_typical.lib"
printf 'TOOLS_READY %s\n' "$TOOLS_DIR"
