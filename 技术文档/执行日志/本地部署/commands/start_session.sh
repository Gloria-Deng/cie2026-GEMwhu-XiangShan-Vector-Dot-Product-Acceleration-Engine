#!/usr/bin/env bash
set -eu
export TZ=Asia/Shanghai LC_ALL=C.UTF-8
OUT='/mnt/d/Desktop/全国RISC-V高水平创新及应用大赛-CIE-香山社区-RISC-V应用创新赛道/香山向量点积加速引擎-官网提交/相关证明材料/recorded_operations/20261023_redeployment'
test ! -e "$OUT/continuous_terminal.txt"
printf 'Recording continuous terminal output and timing.\n'
script --quiet --flush --return --log-out "$OUT/continuous_terminal.txt" --log-timing "$OUT/terminal_timing.txt" --command 'bash --noprofile --norc -i'
