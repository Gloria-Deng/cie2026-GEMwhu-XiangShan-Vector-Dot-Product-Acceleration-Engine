#!/usr/bin/env python3
"""Emit the scheduler task only after all programs pass NEMU execution."""
from __future__ import annotations

import argparse
from datetime import datetime
import os
from pathlib import Path
import shlex
import subprocess

import study


def main():
    parser = argparse.ArgumentParser()
    for name in ("programs", "runner", "library", "emu", "out"):
        parser.add_argument("--" + name, type=Path, required=True)
    parser.add_argument("--date", default=datetime.now().strftime("%Y%m%d"))
    parser.add_argument("--workers", type=int, default=1)
    parser.add_argument("--cycle-limit", type=int, default=250000)
    parser.add_argument("--seconds-limit", type=int, default=7200)
    args = parser.parse_args()
    try:
        if os.name == "nt":
            raise ValueError("请在实际执行任务的 Linux 环境准备，以便校验本机执行文件")
        if not args.date.isdigit() or len(args.date) != 8 or not 1 <= args.workers <= 16:
            raise ValueError("日期须为八位数字，并发数量须为1至16")
        if args.cycle_limit <= 0 or args.seconds_limit <= 0:
            raise ValueError("执行限制必须为正数")
        datetime.strptime(args.date, "%Y%m%d")
        for value in (args.runner, args.library, args.emu):
            if not value.is_file():
                raise ValueError("缺少执行文件：" + str(value))
        rows = study.load_programs(args.programs)
        if not any(r["implementation"] == "rvv_opt2" for r in rows):
            raise ValueError("程序清单未包含优化 RVV 对照")
        out = study.fresh_directory(args.out)
        study.functional(args.programs, args.runner, args.library, out / "functional")
        # This point is reached only after every full-register comparison passes.
        measured = study.HERE / ("measured_" + args.date + "_optimized")
        if measured.exists():
            raise ValueError("测量目录已存在，请换日期或移动已有任务")
        command = ["python3", "experiments/throughput/study.py", "execute", "--programs", str(args.programs.resolve()),
                   "--emu", str(args.emu.resolve()), "--library", str(args.library.resolve()), "--out", str(measured),
                   "--repeat", "3", "--workers", str(args.workers), "--cycle-limit", str(args.cycle_limit),
                   "--seconds-limit", str(args.seconds_limit)]
        script = "#!/bin/bash\n#SBATCH --job-name=rvv-opt\n#SBATCH --nodes=1\n#SBATCH --ntasks=1\n"
        script += "#SBATCH --cpus-per-task=%d\n#SBATCH --time=24:00:00\n#SBATCH --output=rvv-opt-%%j.out\n" % args.workers
        script += "set -euo pipefail\ncd " + shlex.quote(str(study.ROOT)) + "\n"
        # Recheck the same images and reference library immediately before use.
        script += shlex.join(["python3", "experiments/throughput/study.py", "functional", "--programs", str(args.programs.resolve()),
                             "--runner", str(args.runner.resolve()), "--library", str(args.library.resolve()),
                             "--out", str(out / "functional_on_node")]) + "\n"
        script += shlex.join(command) + "\n"
        script += shlex.join(["python3", "scripts/check_measurements_opt.py", "--results", str(measured),
                             "--out", str(measured / "reviewed"), "--plot"]) + "\n"
        (out / "measure_optimized.sbatch").write_text(script, encoding="utf-8")
        (out / "execution_plan.txt").write_text("programs=%d\nattempts=%d\nworkers=%d\nmeasured=%s\n" %
                                               (len(rows), len(rows) * 3, args.workers, measured), encoding="utf-8")
        print("OPT_TASK_PREPARED", out / "measure_optimized.sbatch")
        return 0
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print("OPT_TASK_PREPARE_FAIL", error)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
