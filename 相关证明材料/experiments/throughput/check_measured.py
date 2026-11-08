from __future__ import annotations

import argparse
import csv
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_PACKAGE = Path(__file__).resolve().parent / "measured_20261103"


def verify_package(package, out):
    package, out = Path(package).resolve(), Path(out).resolve()
    if out == ROOT or ROOT in out.parents or out.exists():
        raise ValueError("Choose a new output directory outside the supplied material")
    subprocess.run([sys.executable, "-B", str(ROOT / "scripts/check_measurements_opt.py"),
                    "--results", str(package), "--out", str(out)], check=True)
    with (package / "runs.csv").open(encoding="utf-8-sig", newline="") as stream:
        records = list(csv.DictReader(stream))
    return {"records": len(records)}


def main():
    parser = argparse.ArgumentParser(description="Recompute the current 348 dot-product executions from their complete outputs.")
    parser.add_argument("--package", type=Path, default=DEFAULT_PACKAGE)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    try:
        result = verify_package(args.package, args.out)
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print("THROUGHPUT_MEASURED_FAIL", str(error), file=sys.stderr)
        return 1
    print("THROUGHPUT_MEASURED_PASS records=" + str(result["records"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
