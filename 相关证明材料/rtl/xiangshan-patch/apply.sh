#!/usr/bin/env bash
# Compatibility entry used by cluster scripts; install.sh owns the implementation.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
exec bash "$SCRIPT_DIR/install.sh" "$@"
