from __future__ import annotations

import argparse
from pathlib import Path
import subprocess
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]


def main():
    parser = argparse.ArgumentParser(description="Recompute the current 72 matrix executions from their complete outputs.")
    parser.add_argument("--package", type=Path, default=HERE / "measured_20261103")
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    package, out = args.package.resolve(), args.out.resolve()
    if out == ROOT or ROOT in out.parents or out.exists():
        parser.error("Choose a new output directory outside the supplied material")
    command = [sys.executable, "-B", str(HERE / "rvv_benchmark.py"), "analyze",
               "--results", str(package), "--programs", str(package / "programs"),
               "--out", str(out), "--repeat", "3"]
    return subprocess.run(command).returncode


if __name__ == "__main__":
    raise SystemExit(main())
