#!/usr/bin/env bash
set -Eeuo pipefail
trap 'ret=$?; printf "\nSTEP_FAILED status=%s line=%s at %s\n" "$ret" "$LINENO" "$(date --iso-8601=seconds)"; exit "$ret"' ERR
set -x

cd "$SUBMISSION"
source scripts/env.sh
python3 -m venv "$DEPLOY_BASE/python-env"
source "$DEPLOY_BASE/python-env/bin/activate"
python3 -m pip install --no-cache-dir -r requirements-local-check.txt
python3 -B tools/fsttool/build_reader.py --out tools/fsttool/libfstapi.so
java -version
mill --version
"$CHISEL_FIRTOOL_PATH/firtool" --version
verilator --version
iverilog -V
riscv64-unknown-elf-gcc --version
python3 --version
python3 -m pip freeze
python3 -B stage1/hello_xiangshan_anyos.py
python3 -B run_latency.py check
python3 -B check_programs.py --out "$DEPLOY_BASE/checks"
printf 'LOCAL_REDEPLOYMENT_COMPLETE %s\n' "$(date --iso-8601=seconds)"
cp -a "$DEPLOY_BASE/checks" "$RECORD_OUT/local_checks"
date --iso-8601=seconds
