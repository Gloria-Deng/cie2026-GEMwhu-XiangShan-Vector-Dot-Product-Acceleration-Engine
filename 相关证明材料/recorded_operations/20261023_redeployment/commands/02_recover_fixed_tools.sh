#!/usr/bin/env bash
set -Eeuo pipefail
trap 'r=$?; echo "FIXED_TOOLS_FAILED $r at $(date --iso-8601=seconds)"; exit "$r"' ERR
set -x
date --iso-8601=seconds
echo 'Continue after the direct Linux GitHub connection failed.'
/mnt/c/Users/lenovo/AppData/Local/Programs/Python/Python311/python.exe 'D:\Desktop\全国RISC-V高水平创新及应用大赛-CIE-香山社区-RISC-V应用创新赛道\_文档整理工作_20261023\真实重新部署\download_assets_windows.py'

mkdir -p "$DOWNLOADS/firtool-unpacked" "$VDOT_TOOLS/firtool/bin" "$VDOT_TOOLS/riscv"
cp '/mnt/d/Desktop/全国RISC-V高水平创新及应用大赛-CIE-香山社区-RISC-V应用创新赛道/_文档整理工作_20261023/真实重新部署/downloads/firtool.tar.gz' "$DOWNLOADS/firtool.tar.gz"
cp '/mnt/d/Desktop/全国RISC-V高水平创新及应用大赛-CIE-香山社区-RISC-V应用创新赛道/_文档整理工作_20261023/真实重新部署/downloads/riscv.tar.gz' "$DOWNLOADS/riscv.tar.gz"
cp '/mnt/d/Desktop/全国RISC-V高水平创新及应用大赛-CIE-香山社区-RISC-V应用创新赛道/_文档整理工作_20261023/真实重新部署/downloads/verilator.tar.gz' "$DOWNLOADS/verilator.tar.gz"

tar -xzf "$DOWNLOADS/firtool.tar.gz" -C "$DOWNLOADS/firtool-unpacked"
mapfile -t FT < <(find "$DOWNLOADS/firtool-unpacked" -type f -name firtool)
test "${#FT[@]}" -eq 1
cp "${FT[0]}" "$VDOT_TOOLS/firtool/bin/firtool"
chmod u+x "$VDOT_TOOLS/firtool/bin/firtool"
tar -xzf "$DOWNLOADS/riscv.tar.gz" -C "$VDOT_TOOLS/riscv"
export RISCV_XPACK="$VDOT_TOOLS/riscv/xpack-riscv-none-elf-gcc-14.2.0-3"
for tool in as ld objcopy objdump gcc nm; do ln -sf "$RISCV_XPACK/bin/riscv-none-elf-$tool" "$VDOT_TOOLS/bin/riscv64-unknown-elf-$tool"; done
tar -xzf "$DOWNLOADS/verilator.tar.gz" -C "$DOWNLOADS"
cd "$DOWNLOADS/verilator-5.052"
autoconf
./configure --prefix="$VDOT_TOOLS/verilator"
make -j2
make install
export PATH="$VDOT_TOOLS/verilator/bin:$VDOT_TOOLS/bin:$PATH"
"$VDOT_TOOLS/bin/mill" --version
"$VDOT_TOOLS/firtool/bin/firtool" --version
"$RISCV_XPACK/bin/riscv-none-elf-gcc" --version
"$VDOT_TOOLS/verilator/bin/verilator" --version
printf 'FIXED_TOOLS_COMPLETE %s\n' "$(date --iso-8601=seconds)"
