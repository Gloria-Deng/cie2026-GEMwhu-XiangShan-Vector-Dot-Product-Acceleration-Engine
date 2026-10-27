#!/usr/bin/env bash
set -Eeuo pipefail
trap 'ret=$?; printf "\nSTEP_FAILED status=%s line=%s at %s\n" "$ret" "$LINENO" "$(date --iso-8601=seconds)"; exit "$ret"' ERR
set -x

cd "$SUBMISSION"
bash -x scripts/install_tools.sh
printf 'FIXED_TOOLS_COMPLETE %s\n' "$(date --iso-8601=seconds)"
