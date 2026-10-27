import argparse
import csv
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time


ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    if args.out is None:
        out = Path(tempfile.mkdtemp(prefix="vdot-improvements-"))
    else:
        out = args.out.resolve()
        if out == ROOT or ROOT in out.parents:
            parser.error("Choose an output directory outside the supplied material")
        if out.exists():
            parser.error("Output directory already exists; choose a new name")
        out.mkdir(parents=True)
    steps = [("application", "applications/gemm/check.py"), ("throughput", "experiments/throughput/check.py"), ("functional", "verification/check.py")]
    rows = []
    env = dict(os.environ, PYTHONUTF8="1", PYTHONDONTWRITEBYTECODE="1")
    for name, script in steps:
        started = time.monotonic()
        command = [sys.executable, "-B", str(ROOT / script), "--out", str(out / name)]
        try:
            result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=900)
            code = result.returncode
            output = result.stdout + result.stderr
        except subprocess.TimeoutExpired as error:
            code = 124
            output = f"TIME_LIMIT seconds=900\n{error}"
        (out / f"{name}.txt").write_text(output, encoding="utf-8")
        rows.append({"check": name, "status": "PASS" if code == 0 else "FAIL", "return_code": code, "seconds": f"{time.monotonic() - started:.3f}", "output": f"{name}.txt"})
        print(f"{name}: {rows[-1]['status']}", flush=True)
    with (out / "checks.csv").open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    failed = sum(row["status"] != "PASS" for row in rows)
    print(f"IMPROVEMENTS_{'PASS' if failed == 0 else 'FAIL'} checks={len(rows)} failed={failed}")
    print(f"OUTPUT {out}")
    return int(failed > 0)


if __name__ == "__main__":
    raise SystemExit(main())
