from __future__ import annotations

import argparse
import csv
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

import study
import check_measured


def independent_dot(a, b):
    left = [int.from_bytes(bytes([x]), "little", signed=True) for x in a[:8]]
    right = [int.from_bytes(bytes([x]), "little", signed=True) for x in b[:8]]
    return sum(x * y for x, y in zip(left, right)) % (1 << 32)


def verify_models():
    a, b = study.input_data()
    count = 0
    for width in study.WIDTHS:
        for n in (0, 1, 64, 1024):
            for arm in study.ARMS:
                actual = study.expected_registers("independent", width, arm, n)
                for reg, value in actual:
                    count += 1
                    want = bytes([0xA5 ^ reg] * 16) if arm == "control" or n == 0 else independent_dot(a, b).to_bytes(4, "little") + bytes(12)
                    if value != want:
                        raise ValueError("独立程序的完整寄存器期望值错误")
    for n in (0, 1, 2, 64, 1024):
        count += 1
        value = a
        for _ in range(n):
            value = independent_dot(value, b).to_bytes(4, "little") + bytes(12)
        if study.expected_registers("dependent", 1, "vdot", n) != [(30, value)]:
            raise ValueError("依赖程序的期望值错误")
    if study.dot(bytes([128] * 16), bytes([128] * 16)) != 131072:
        raise ValueError("最大值处理错误")
    if study.dot(bytes([128] * 16), bytes([127] * 16)) != (-130048 & 0xFFFFFFFF):
        raise ValueError("最小值处理错误")
    return count + 2


def verify_parser():
    row = {"LANDING": 0x80001000, "landing_bytes": 1024, "cycle_grid": 8}
    text = "The first instruction of core 0 has commited. Difftest enabled.\nCore 0: EXCEEDING CYCLE/INSTR LIMIT at pc = 0x80001020\n"
    if study.classify(text, 0, row).get("cycles_lower") != 64:
        raise ValueError("计时位置解析错误")
    bad_inputs = [
        (text, 1), ("", 0), (text + text, 0),
        (text.replace("1020", "0fff"), 0), (text.replace("1020", "1021"), 0),
        (text.replace("1020", "1400"), 0), (text.replace("Difftest enabled.", ""), 0),
        (text + "\nv1_high different at pc = 0x80000000", 0),
        (text + "\nAssertion value failed", 0), (text + "\nSegmentation fault", 0),
    ]
    for value, rc in bad_inputs:
        if study.classify(value, rc, row)["status"] != "FAIL":
            raise ValueError("异常执行被当作成功")
    fitted = study.line_fit([(0, 104), (64, 616), (256, 2152), (1024, 8296)], 8)
    if fitted["slope"] != 8 or fitted["r_squared"] != 1:
        raise ValueError("已知线性关系重算错误")
    for points in ([(1, 2)], [(0, 2), (0, 3), (1, 4)], [(0, 2), (1, float("nan")), (2, 5)]):
        try:
            study.line_fit(points, 8)
        except ValueError:
            continue
        raise ValueError("无效拟合数据未被拒绝")
    return 15


def verify_analysis(programs):
    empty_fits, empty_summary = study.summarize(programs, [])
    if any(row["status"] != "NOT_MEASURED" or row["gross_cycles_per_dot"] != "" for row in empty_summary):
        raise ValueError("未测数据被填成了数值")
    artificial = []
    for program in programs:
        n = int(program["iterations"])
        factor = {"control": 2, "vdot": 4, "rvv": 8}[program["implementation"]]
        for repeat in range(3):
            artificial.append({**program, "repeat": str(repeat), "status": "PASS", "cycles_lower": str(128 + factor * int(program["width"]) * n), "measurement_kind": "XIANGSHAN_CYCLES"})
    fits, summary = study.summarize(programs, artificial)
    if not all(row["status"] == "PASS" for row in summary):
        raise ValueError("完整的已知关系未通过分析")
    for rows in (artificial + [artificial[0]], [{**artificial[0], "measurement_kind": "FUNCTIONAL_ONLY"}]):
        try:
            study.summarize(programs, rows)
        except ValueError:
            continue
        raise ValueError("重复条目或参考执行被用于计时结论")
    no_zero = [row for row in programs if int(row["iterations"]) != 0]
    try:
        study.summarize(no_zero, [row for row in artificial if int(row["iterations"]) != 0])
    except ValueError:
        pass
    else:
        raise ValueError("遗漏零次程序后仍产生完整结论")
    _, missing_repeats = study.summarize(programs, artificial, expected_repeats=5)
    if any(row["status"] == "PASS" for row in missing_repeats):
        raise ValueError("遗漏期望重复测量后仍产生完整结论")
    broken = [dict(row) for row in artificial]
    broken[0]["status"] = "FAIL"
    _, rows = study.summarize(programs, broken)
    if not any(row["status"] == "CONTROL_INCOMPLETE" for row in rows):
        raise ValueError("控制程序失败时仍给出了可靠结论")
    return 7


def discover_reference():
    configured = os.environ.get("VDOT_NEMU_LIBRARY")
    candidates = [Path(configured)] if configured else []
    for suffix in ("", ".so", ".exe", ".dll"):
        candidate = study.ROOT / "sources/NEMU/build" / ("riscv64-nemu-interpreter-so" + suffix)
        if candidate.is_file():
            candidates.append(candidate)
    if not candidates and os.name == "nt":
        peer = study.ROOT.parents[2] / "RSIC-V香山/工作区"
        if peer.is_dir():
            candidates.extend(peer.glob("收口构建*/nemu-vdot/build/riscv64-nemu-interpreter-so.exe"))
    candidates = sorted({path.resolve() for path in candidates if path.is_file()})
    if len(candidates) > 1:
        raise ValueError("发现多份本机参考库，请用 VDOT_NEMU_LIBRARY 指定")
    return candidates[0] if candidates else None


def verify_register_rejection(out, runner, library, prefix):
    folder = study.fresh_directory(out)
    tools = study.find_tools(prefix)
    original = study.assembly("independent", 16, "vdot", 64)
    altered = original.replace("  .word 0x%08x\n" % study.vdot_word(0), "  addi zero,zero,0\n", 1)
    expected = original.split("EXPECTED:\n", 1)[1].splitlines()
    values = [int(x) for x in expected[0].removeprefix(".byte ").split(",")]
    values[15] = 1
    expected[0] = ".byte " + ",".join(map(str, values))
    upper = original.split("EXPECTED:\n", 1)[0] + "EXPECTED:\n" + "\n".join(expected) + "\n"
    env = os.environ.copy()
    if os.name == "nt":
        env["PATH"] = "E:/msys64/usr/bin;E:/msys64/ucrt64/bin;" + env.get("PATH", "")
    for name, text in (("missing_first_destination", altered), ("wrong_upper_byte", upper)):
        source = folder / (name + ".S")
        source.write_text(text, encoding="ascii")
        obj, elf, binary = (folder / (name + suffix) for suffix in (".o", ".elf", ".bin"))
        commands = [
            [tools["as"], "-march=rv64gcv", "-mabi=lp64d", "-o", obj, source],
            [tools["ld"], "-m", "elf64lriscv", "-Ttext=0x80000000", "-Tdata=0x80100000", "--no-relax", "-e", "_start", "-o", elf, obj],
            [tools["objcopy"], "-O", "binary", elf, binary],
        ]
        for command in commands:
            subprocess.run(list(map(str, command)), check=True, capture_output=True, timeout=60)
        nm = subprocess.check_output([tools["nm"], "-n", str(elf)], text=True, errors="replace", timeout=30)
        symbols = {parts[2]: int(parts[0], 16) for line in nm.splitlines()
                   if len(parts := line.split()) == 3 and parts[1].lower() in ("t", "d")}
        result = subprocess.run([str(Path(runner).resolve()), study.msys_path(library), study.msys_path(binary),
                                 hex(symbols["LANDING"]), hex(symbols["BAD"]), hex(symbols["LANDING"] + study.LANDING_BYTES)],
                                capture_output=True, text=True, errors="replace", env=env, timeout=120)
        output = result.stdout + result.stderr
        (folder / (name + ".txt")).write_text(output, encoding="utf-8")
        match = re.search(r"IMAGE FAIL pc=(0x[0-9a-f]+)", output)
        if result.returncode == 0 or not match or int(match[1], 16) != symbols["BAD"]:
            raise ValueError("错误寄存器结果未被程序自身拒绝：" + name)
    return 2


def check_saved_measurements(out):
    if not check_measured.DEFAULT_PACKAGE.is_dir():
        return "NOT_INCLUDED", 0
    saved = check_measured.verify_package(check_measured.DEFAULT_PACKAGE, Path(out) / "saved_measurements")
    return "PASS", saved["records"]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--prefix")
    parser.add_argument("--runner", type=Path)
    parser.add_argument("--library", type=Path)
    args = parser.parse_args()
    checks = []
    try:
        out = study.fresh_directory(args.out)
        count = verify_models()
        checks.append({"check": "independent_reference", "status": "PASS", "count": count, "detail": "含零次、符号极值、全部目标128位及依赖递推"})
        count = verify_parser()
        checks.append({"check": "invalid_output_handling", "status": "PASS", "count": count, "detail": "拒绝退出异常、错误终点、未启用比较、重复结束和非有限数"})
        programs = study.generate(out / "programs", prefix=args.prefix)
        checks.append({"check": "build_and_disassemble", "status": "PASS", "count": len(programs), "detail": "1/2/4/8/16个独立点积与依赖参照，三种实现，四档循环次数"})
        count = verify_analysis(programs)
        checks.append({"check": "measurement_analysis", "status": "PASS", "count": count, "detail": "未测保持空值，控制执行失败不产生扣除结论，拒绝参考计时"})
        shutil.copyfile(out / "programs/programs.csv", out / "programs.csv")
        shutil.copyfile(out / "programs/study_parameters.csv", out / "study_parameters.csv")
        study.analyze(out, out / "unmeasured")
        if bool(args.runner) != bool(args.library):
            raise ValueError("--runner 与 --library 必须同时提供")
        runner, library = args.runner, args.library
        if runner is None:
            library = discover_reference()
            if library is not None:
                command = [sys.executable, "-B", str(study.HERE / "build_reference.py"), "--nemu-source",
                           str(library.parent.parent), "--out", str(out / "reference_runner")]
                compiled = subprocess.run(command, capture_output=True, text=True, errors="replace", timeout=180)
                (out / "reference_build.txt").write_text(compiled.stdout + compiled.stderr, encoding="utf-8")
                if compiled.returncode:
                    raise ValueError("本机参考执行器编译失败")
                runner = out / "reference_runner" / ("reference_runner.exe" if os.name == "nt" else "reference_runner")
        if runner:
            rows = study.functional(out / "programs", runner, library, out / "reference_execution")
            checks.append({"check": "reference_execution", "status": "PASS", "count": len(rows), "detail": "只确认功能，未产生真实处理器周期"})
            count = verify_register_rejection(out / "register_error_checks", runner, library, args.prefix)
            checks.append({"check": "register_error_rejection", "status": "PASS", "count": count, "detail": "遗漏首个目标、仅最高字节错误均被程序自身拒绝"})
        else:
            checks.append({"check": "reference_execution", "status": "NOT_RUN", "count": "", "detail": "未提供本机参考执行程序与共享库"})
        saved_status, saved_count = check_saved_measurements(out)
        checks.append({"check": "saved_processor_measurements", "status": saved_status, "count": saved_count,
                       "detail": "仅核对随附已完成计时；本次未启动新处理器测量"})
        study.write_rows(out / "checks.csv", ("check", "status", "count", "detail"), checks)
        print("THROUGHPUT_LOCAL_PASS programs=%d new_processor_measurements=NOT_RUN saved_measurements=%s saved_records=%d output=%s" %
              (len(programs), saved_status, saved_count, out))
        return 0
    except Exception as error:
        if "out" in locals():
            checks.append({"check": "completion", "status": "FAIL", "count": "", "detail": str(error)})
            study.write_rows(out / "checks.csv", ("check", "status", "count", "detail"), checks)
        print("THROUGHPUT_LOCAL_FAIL", str(error))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
