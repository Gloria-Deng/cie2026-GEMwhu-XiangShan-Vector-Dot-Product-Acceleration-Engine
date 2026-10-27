#!/usr/bin/env bash

set -euo pipefail
test "$(uname -m)" = x86_64 || { echo 'Linux x86_64 is required'; exit 1; }
VDOT_TOOLS="${VDOT_TOOLS:-$HOME/vdot31/tools}"
DOWNLOADS="${DOWNLOADS:-$HOME/vdot31/downloads}"
mkdir -p "$VDOT_TOOLS/bin" "$DOWNLOADS"
sudo apt-get update
sudo apt-get install -y build-essential git curl ca-certificates \
  python3 python3-venv python3-pip openjdk-17-jdk iverilog \
  autoconf automake flex bison help2man perl zlib1g-dev libzstd-dev \
  libreadline-dev libsdl2-dev libfl-dev liblz4-dev libnuma-dev \
  ccache cmake ninja-build diffutils
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
test -x "$JAVA_HOME/bin/java"
export PATH="$JAVA_HOME/bin:$PATH"
"$JAVA_HOME/bin/java" -version 2>&1 | head -n 1 | grep '"17\.'

curl -fL --retry 3 -o "$VDOT_TOOLS/mill.jar" \
  https://repo.maven.apache.org/maven2/com/lihaoyi/mill-dist/0.12.3/mill-dist-0.12.3.jar
cat > "$VDOT_TOOLS/bin/mill" <<'EOF'
#!/usr/bin/env bash
set -e
TOOLS_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"
exec "$TOOLS_DIR/mill.jar" "$@"
EOF
chmod u+x "$VDOT_TOOLS/mill.jar" "$VDOT_TOOLS/bin/mill"
"$VDOT_TOOLS/bin/mill" --version

curl -fL --retry 3 -o "$DOWNLOADS/firtool.tar.gz" \
  https://github.com/llvm/circt/releases/download/firtool-1.62.1/firrtl-bin-linux-x64.tar.gz
mkdir -p "$DOWNLOADS/firtool-unpacked" "$VDOT_TOOLS/firtool/bin"
tar -xzf "$DOWNLOADS/firtool.tar.gz" -C "$DOWNLOADS/firtool-unpacked"
mapfile -t FIRTOOL_FILES < <(find "$DOWNLOADS/firtool-unpacked" -type f -name firtool)
test "${#FIRTOOL_FILES[@]}" -eq 1
cp "${FIRTOOL_FILES[0]}" "$VDOT_TOOLS/firtool/bin/firtool"
chmod u+x "$VDOT_TOOLS/firtool/bin/firtool"

curl -fL --retry 3 -o "$DOWNLOADS/riscv.tar.gz" \
  https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v14.2.0-3/xpack-riscv-none-elf-gcc-14.2.0-3-linux-x64.tar.gz
mkdir -p "$VDOT_TOOLS/riscv"
tar -xzf "$DOWNLOADS/riscv.tar.gz" -C "$VDOT_TOOLS/riscv"
RISCV_XPACK="$VDOT_TOOLS/riscv/xpack-riscv-none-elf-gcc-14.2.0-3"
for TOOL_NAME in as ld objcopy objdump gcc nm; do
  ln -sf "$RISCV_XPACK/bin/riscv-none-elf-$TOOL_NAME" \
    "$VDOT_TOOLS/bin/riscv64-unknown-elf-$TOOL_NAME"
done

if test ! -d "$DOWNLOADS/verilator-src"; then
  git clone --branch v5.052 --depth 1 \
    https://github.com/verilator/verilator.git "$DOWNLOADS/verilator-src"
fi
test "$(git -C "$DOWNLOADS/verilator-src" describe --tags --exact-match)" = v5.052
pushd "$DOWNLOADS/verilator-src" >/dev/null
autoconf
./configure --prefix="$VDOT_TOOLS/verilator"
make -j4
make install
popd >/dev/null
echo 'TOOLS_INSTALL_PASS'
