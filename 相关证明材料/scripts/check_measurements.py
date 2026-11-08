import argparse
import csv
import os
from pathlib import Path
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    if args.out is None:
        out = Path(tempfile.mkdtemp(prefix="vdot-measured-"))
    else:
        out = args.out.resolve()
        if out == ROOT or ROOT in out.parents or out.exists():
            parser.error("Choose a new output directory outside the supplied material")
        out.mkdir(parents=True)
    rows = []
    env = dict(os.environ, PYTHONUTF8="1", PYTHONDONTWRITEBYTECODE="1")
    jobs=[("optimized_dot", "scripts/check_measurements_opt.py",
           ["--results", str(ROOT / "experiments/throughput/measured_20261103")]),
          ("rvv_gemm", "applications/gemm/rvv_benchmark.py",
           ["analyze", "--results", str(ROOT / "applications/gemm/measured_20261103"),
            "--programs", str(ROOT / "applications/gemm/measured_20261103/programs")])]
    records,groups=420,140
    for name, relative, extra in jobs:
        command = [sys.executable, "-B", str(ROOT / relative), *extra, "--out", str(out / name)]
        result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=1200)
        (out / f"{name}.txt").write_text(result.stdout + result.stderr, encoding="utf-8")
        rows.append({"check": name, "status": "PASS" if result.returncode == 0 else "FAIL", "return_code": result.returncode, "output": f"{name}.txt"})
        print(name, rows[-1]["status"], flush=True)
    with (out / "checks.csv").open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    failed = sum(row["status"] != "PASS" for row in rows)
    print(f"MEASURED_RESULTS_{'PASS' if failed == 0 else 'FAIL'} records={records} groups={groups} expected_repeats=3")
    print(f"OUTPUT {out}")
    return int(failed > 0)


if __name__ == "__main__":
    raise SystemExit(main())
