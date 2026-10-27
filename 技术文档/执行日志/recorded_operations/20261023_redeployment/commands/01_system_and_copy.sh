#!/usr/bin/env bash
set -Eeuo pipefail
trap 'ret=$?; printf "\nSTEP_FAILED status=%s line=%s at %s\n" "$ret" "$LINENO" "$(date --iso-8601=seconds)"; exit "$ret"' ERR
set -x

date --iso-8601=seconds
cat /etc/os-release
uname -a
free -h
df -h /
for tool in python3 gcc g++ make git java mill firtool verilator iverilog riscv64-unknown-elf-as; do command -v "$tool" || true; done
test ! -e "$DEPLOY_BASE"
mkdir -p "$SUBMISSION"
tar -C "$ORIGINAL" --exclude=./recorded_operations/20261023_redeployment --exclude=./__pycache__ -cf - . | tar -C "$SUBMISSION" -xf -
printf 'COPY_COMPLETE %s\n' "$(date --iso-8601=seconds)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -o Acquire::Retries=2 -o Acquire::http::Timeout=45 -o Acquire::https::Timeout=45
apt-get install --reinstall -y build-essential git curl ca-certificates python3 python3-venv python3-pip openjdk-17-jdk iverilog autoconf automake flex bison help2man perl zlib1g-dev libzstd-dev libreadline-dev libsdl2-dev libfl-dev liblz4-dev libnuma-dev ccache cmake ninja-build diffutils
printf 'SYSTEM_REINSTALL_COMPLETE %s\n' "$(date --iso-8601=seconds)"
