from __future__ import annotations

import argparse
from collections import Counter, defaultdict
from datetime import datetime
import math
from pathlib import Path
import re
import statistics

import study


DEFAULT_PACKAGE = study.HERE / "measured_20261026"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def compare_table(path, expected, keys):
    actual = study.read_rows(path)
    left = {tuple(str(row[key]) for key in keys): row for row in actual}
    right = {tuple(str(row[key]) for key in keys): row for row in expected}
    require(len(left) == len(actual) and set(left) == set(right), path.name + " 的分组数量不一致")
    count = 0
    for key, row in right.items():
        saved = left[key]
        require(set(saved) == set(row), path.name + " 的内容项目不一致")
        for column, value in row.items():
            if isinstance(value, (int, float)):
                try:
                    number = float(saved[column])
                except (ValueError, TypeError):
                    raise ValueError(path.name + " 存在无效数值") from None
                require(math.isfinite(number) and math.isclose(number, value, rel_tol=1e-12, abs_tol=1e-10),
                        path.name + " 的数值与逐次结果不一致：" + str(key) + " / " + column)
            else:
                require(saved[column] == str(value), path.name + " 的状态或名称不一致")
            count += 1
    return count


def validate_runs(programs, runs, info):
    expected_ns = [int(value) for value in info["iterations"].split(";")]
    repeat = int(info["expected_repeats"])
    study.validate_program_grid(programs, expected_ns)
    require(len(programs) == int(info["programs"]) == 72, "程序数量应为72")
    require(len(runs) == len(programs) * repeat == 216, "逐次结果数量应为216")
    lookup = {row["name"]: row for row in programs}
    require(len(lookup) == len(programs), "程序名称重复")
    require(len({(row["name"], int(row["repeat"])) for row in runs}) == len(runs), "重复条目不唯一")
    per_program = defaultdict(list)
    planned = [(row["name"], r) for r in range(repeat)
               for row in (programs if r % 2 == 0 else list(reversed(programs)))]
    orders = set()
    for row in runs:
        require(row["name"] in lookup, "结果中出现清单之外的程序")
        program = lookup[row["name"]]
        for key in ("mode", "width", "implementation", "iterations"):
            require(str(program[key]) == str(row[key]), "程序说明与逐次结果不一致：" + row["name"])
        require(row["status"] == "PASS" and int(row["exit_code"]) == 0, "存在未成功结束的程序")
        require(row["measurement_kind"] == "XIANGSHAN_CYCLES", "逐次表含非香山周期")
        grid = int(program["cycle_grid"])
        require(grid == int(row["cycle_grid"]) == 8, "计时单位不一致")
        offset = int(row["terminal_pc"], 0) - int(program["LANDING"], 0)
        require(0 <= offset < int(program["landing_bytes"]) and offset % 4 == 0,
                "终止位置不在完成结果比较后的允许范围")
        require(int(row["cycles_lower"]) == offset // 4 * grid,
                "周期与终止位置不一致：" + row["name"])
        require(0 <= int(row["cycles_lower"]) < int(info["cycle_limit"]), "周期超过本批执行上限")
        require(re.fullmatch(r"[0-9a-f]{64}", row["output_sha256"]) is not None,
                "原始输出内容值格式无效")
        require(row["output"] == row["name"] + "_r" + row["repeat"] + ".txt", "原始输出名称不一致")
        elapsed = float(row["seconds"])
        require(math.isfinite(elapsed) and 0 < elapsed <= float(info["seconds_limit"]), "执行用时无效或超过设置上限")
        started = datetime.fromisoformat(row["started_utc"])
        require(started.tzinfo is not None, "开始时间没有时区")
        order = int(row["submission_order"])
        require(0 <= order < len(planned) and planned[order] == (row["name"], int(row["repeat"])),
                "提交次序与交替正序倒序安排不一致")
        orders.add(order)
        per_program[row["name"]].append(row)
    require(orders == set(range(len(runs))), "提交次序不完整")
    spread = []
    for program in programs:
        selected = per_program[program["name"]]
        require(len(selected) == repeat and {int(row["repeat"]) for row in selected} == set(range(repeat)),
                "某程序缺少计划的重复")
        values = [int(row["cycles_lower"]) for row in selected]
        spread.append({"name": program["name"], "mode": program["mode"], "width": program["width"],
                       "implementation": program["implementation"], "iterations": program["iterations"],
                       "repeats": repeat, "cycles_min": min(values), "cycles_median": statistics.median(values),
                       "cycles_max": max(values), "spread_cycles": max(values) - min(values), "cycle_grid": 8})
    return spread


def remote_records(package, runs):
    checks = study.read_rows(package / "remote_checks/completion_checks.csv")
    lookup = {row["check"]: row for row in checks}
    require(len(lookup) == len(checks), "远端完成记录出现重复项目")
    for name, count in (("source_files_match_execution_inputs", 98),
                        ("throughput_programs_and_repetitions_complete", 216),
                        ("throughput_all_fits_accepted", 18),
                        ("throughput_all_comparisons_accepted", 12),
                        ("throughput_all_speedups_accepted", 6)):
        require(name in lookup and lookup[name]["status"] == "PASS" and int(lookup[name]["count"]) == count,
                "缺少通过的远端完成记录：" + name)
    for row in runs:
        suffix = row["name"] + "_r" + row["repeat"]
        for prefix in ("throughput_output_", "throughput_result_"):
            name = prefix + suffix
            require(name in lookup and lookup[name]["status"] == "PASS" and int(lookup[name]["count"]) == 1,
                    "某次原始输出的远端核对记录缺失")
    status = (package / "remote_checks/status.txt").read_text(encoding="utf-8-sig")
    completed = [line.split("|") for line in status.splitlines() if line.startswith("3772882|")]
    require(len(completed) == 1 and completed[0][1] == "COMPLETED" and completed[0][-1] == "0:0",
            "缺少任务3772882成功完成的记录")
    require("ALL_MEASUREMENTS_COMPLETE" in status, "缺少全部测量结束标记")
    tasks = study.read_rows(package / "remote_checks/task_status.csv")
    require(any(row["task"] == "throughput" and row["exit_code"] == "0" for row in tasks), "独立点积执行状态不正确")
    return 2 * len(runs) + 5


def verify_package(package, out):
    package = Path(package).resolve()
    out = study.fresh_directory(out)
    checks = []
    try:
        info = {row["setting"]: row["value"] for row in study.read_rows(package / "measurement_info.csv")}
        require(info["job_id"] == "3772882" and info["raw_outputs_included"] == "0", "结果包任务或原始输出范围不正确")
        files = study.read_rows(package / "files.csv")
        require(files and len({row["file"] for row in files}) == len(files), "结果包文件清单为空或重复")
        for row in files:
            path = (package / row["file"]).resolve()
            require(path.is_relative_to(package) and path.is_file() and study.sha(path) == row["content"],
                    "随附文件内容发生变化：" + row["file"])
        checks.append({"check": "saved_files", "status": "PASS", "count": len(files), "detail": "已保存表格与状态原件内容一致"})
        parameters = {row["setting"]: row["value"] for row in study.read_rows(package / "study_parameters.csv")}
        require(study.sha(package / "programs.csv") == parameters["programs_content_sha256"], "程序清单与生成参数不一致")
        require(parameters["iterations"] == info["iterations"] and parameters["widths"] == info["widths"] and
                int(parameters["program_count"]) == int(info["programs"]), "生成参数与测量安排不一致")
        programs = study.read_rows(package / "programs.csv")
        inputs = {row["path"]: row["content"] for row in study.read_rows(package / "execution_inputs.csv")}
        for program in programs:
            require(inputs.get("throughput_programs/" + program["name"] + ".S") == program["source_sha256"],
                    "程序文本内容值与执行输入清单不一致")
            expected = study.expected_registers(program["mode"], int(program["width"]), program["implementation"], int(program["iterations"]))
            require(program["checked_registers"] == ";".join(str(reg) for reg, _ in expected) and
                    program["expected_registers"] == ";".join(value.hex() for _, value in expected),
                    "目标寄存器及完整期望值不正确")
        checks.append({"check": "programs_and_expected_results", "status": "PASS", "count": len(programs), "detail": "程序清单、输入说明和完整128位期望值一致"})
        runs = study.read_rows(package / "runs.csv")
        spread = validate_runs(programs, runs, info)
        checks.append({"check": "runs_and_terminal_intervals", "status": "PASS", "count": len(runs), "detail": "三次重复、计时单位、终止位置、周期和提交次序均完整"})
        count = remote_records(package, runs)
        checks.append({"check": "saved_remote_completion_records", "status": "PASS", "count": count,
                       "detail": "检查已取回的远端核对记录；本次没有重新读取原始执行输出"})
        fits, comparison = study.summarize(programs, runs, int(info["expected_repeats"]),
                                           [int(value) for value in info["iterations"].split(";")])
        require(all(row["status"] == "PASS" for row in fits + comparison), "存在不满足既定条件的拟合或周期比较")
        ratios = []
        for mode, width in [("independent", value) for value in study.WIDTHS] + [("dependent", 1)]:
            rvv = next(row for row in comparison if row["mode"] == mode and row["width"] == width and row["implementation"] == "rvv")
            vdot = next(row for row in comparison if row["mode"] == mode and row["width"] == width and row["implementation"] == "vdot")
            ratios.append({"mode": mode, "width": width, "status": "PASS",
                           "gross_speedup": rvv["gross_cycles_per_dot"] / vdot["gross_cycles_per_dot"],
                           "adjusted_speedup": rvv["adjusted_cycles_per_dot"] / vdot["adjusted_cycles_per_dot"]})
        comparisons = 0
        for name, rows in (("fits", fits), ("comparison", comparison), ("speedup", ratios)):
            comparisons += compare_table(package / "analysis" / (name + ".csv"), rows,
                                         ("mode", "width", "implementation") if name != "speedup" else ("mode", "width"))
            study.write_rows(out / (name + ".csv"), tuple(rows[0]), rows)
        checks.append({"check": "recomputed_fits_and_comparisons", "status": "PASS", "count": comparisons,
                       "detail": "从216条逐次结果重算18组拟合、12组周期比较和6组倍率，与随附分析一致"})
        study.write_rows(out / "repetition_spread.csv", tuple(spread[0]), spread)
        order = sorted(runs, key=lambda row: row["started_utc"])
        study.write_rows(out / "execution_order.csv", ("submission_order", "name", "repeat", "started_utc", "seconds"), order)
        summary = {"programs": len(programs), "records": len(runs), "repeats": int(info["expected_repeats"]),
                   "fits": len(fits), "comparisons": len(comparison), "speedups": len(ratios),
                   "changed_repetition_groups": sum(row["spread_cycles"] != 0 for row in spread),
                   "max_repetition_spread_cycles": max(row["spread_cycles"] for row in spread),
                   "cycle_grid": 8, "raw_outputs_reopened": 0, "job_id": info["job_id"]}
        study.write_rows(out / "summary.csv", ("item", "value"), [{"item": key, "value": value} for key, value in summary.items()])
        (out / "scope.txt").write_text(
            "本次仅在本地核对随附逐次表、程序清单、终止位置说明、已保存的远端完成记录，并重算拟合与比较。\n"
            "没有连接超算，没有启动处理器执行，没有重新读取216份远端原始输出。\n", encoding="utf-8")
        study.write_rows(out / "checks.csv", ("check", "status", "count", "detail"), checks)
        return summary
    except Exception as error:
        checks.append({"check": "completion", "status": "FAIL", "count": "", "detail": str(error)})
        study.write_rows(out / "checks.csv", ("check", "status", "count", "detail"), checks)
        raise


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--package", type=Path, default=DEFAULT_PACKAGE)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    try:
        summary = verify_package(args.package, args.out)
        print("THROUGHPUT_MEASURED_SUMMARY_PASS records=%d programs=%d repeats=%d fits=%d comparisons=%d raw_outputs_reopened=0" %
              (summary["records"], summary["programs"], summary["repeats"], summary["fits"], summary["comparisons"]))
        print("仅核对本地保存的结果与远端完成记录；未启动新测量。", args.out.resolve())
        return 0
    except (ValueError, OSError, KeyError, StopIteration) as error:
        print("THROUGHPUT_MEASURED_SUMMARY_FAIL", str(error))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
