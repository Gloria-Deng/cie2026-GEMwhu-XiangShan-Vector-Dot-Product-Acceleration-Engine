from __future__ import annotations

import argparse
import csv
from datetime import datetime, timezone
import hashlib
import math
import os
from pathlib import Path
import re
import shutil
import statistics
import subprocess
import time
from concurrent.futures import ThreadPoolExecutor, as_completed


HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
WIDTHS = (1, 2, 4, 8, 16)
ARMS = ("control", "rvv", "vdot")
QUANTUM = 8
LANDING_BYTES = 0x40000
START = 0x80000000
DATA_START = 0x80100000
PROGRAM_COLUMNS = (
    "name", "mode", "width", "implementation", "iterations", "image",
    "image_sha256", "source_sha256", "OK", "BAD", "UNEXPECTED_TRAP",
    "LANDING", "landing_bytes", "cycle_grid", "checked_registers",
    "expected_registers", "operations_per_iteration", "instructions_per_iteration",
)
RUN_COLUMNS = (
    "name", "mode", "width", "implementation", "iterations", "repeat", "status",
    "cycles_lower", "cycle_grid", "terminal_pc", "exit_code", "seconds",
    "output", "output_sha256", "reason", "measurement_kind", "submission_order", "started_utc",
)


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write_rows(path, columns, rows):
    with Path(path).open("w", encoding="utf-8-sig", newline="") as stream:
        writer = csv.DictWriter(stream, fieldnames=columns, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(rows)


def read_rows(path):
    with Path(path).open(encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def fresh_directory(path):
    path = Path(path).resolve()
    if path.exists():
        raise ValueError("输出目录已存在，请使用新目录：" + str(path))
    path.mkdir(parents=True)
    return path


def signed_byte(value):
    return value if value < 128 else value - 256


def dot(a, b):
    return sum(signed_byte(x) * signed_byte(y) for x, y in zip(a[:8], b[:8])) & 0xFFFFFFFF


def input_data():
    a = bytes((1, 254, 3, 252, 5, 250, 127, 128)) + bytes([0x51] * 8)
    b = bytes((255, 2, 253, 4, 251, 6, 129, 127)) + bytes([0xB7] * 8)
    return a, b


def vdot_word(vd, vs1=30, vs2=31):
    return (0b101100 << 26) | (1 << 25) | (vs2 << 20) | (vs1 << 15) | (2 << 12) | (vd << 7) | 0x57


def expected_registers(mode, width, implementation, n):
    a, b = input_data()
    if mode == "dependent":
        result = a
        if implementation != "control":
            for _ in range(n):
                result = dot(result, b).to_bytes(4, "little") + bytes(12)
        return [(30, result)]
    result = dot(a, b).to_bytes(4, "little") + bytes(12)
    return [(reg, bytes([0xA5 ^ reg] * 16) if n == 0 or implementation == "control" else result)
            for reg in range(width)]


def assembly(mode, width, implementation, n):
    if mode not in ("independent", "dependent") or implementation not in ARMS:
        raise ValueError("不支持的程序种类")
    if width not in WIDTHS or (mode == "dependent" and width != 1) or n < 0:
        raise ValueError("独立数量或循环次数无效")
    a, b = input_data()
    destinations = list(range(width)) if mode == "independent" else [30]
    lines = [
        ".option norvc", ".option norelax", ".section .text", ".globl _start", "_start:",
        "  li t0,0x600", "  csrw mstatus,t0", "  li t0,8", "  csrw 0x744,t0",
        "  la t0,UNEXPECTED_TRAP", "  csrw mtvec,t0", "  la s0,INPUT_A", "  la s1,INPUT_B",
        "  la s2,INITIAL", "  la s3,OUTPUT", "  la s7,EXPECTED",
        "  vsetivli zero,16,e8,m1,ta,ma", "  vle8.v v30,(s0)", "  vle8.v v31,(s1)",
    ]
    if mode == "independent":
        for reg in destinations:
            lines.extend(["  vle8.v v%d,(s2)" % reg, "  addi s2,s2,16"])
    lines.extend([
        "  vsetivli zero,8,e8,m1,ta,ma", "  li s4,%d" % n,
        "  fence rw,rw", "  csrr s5,cycle", "  beqz s4,MEASURE_DONE", "MEASURE_LOOP:",
    ])
    for reg in destinations:
        if implementation == "vdot":
            lines.append("  .word 0x%08x" % vdot_word(reg))
        elif implementation == "rvv":
            lines.extend([
                "  vwmul.vv v16,v31,v30", "  vsetivli zero,8,e16,m1,tu,mu",
                "  vmv.v.i v%d,0" % reg, "  vwredsum.vs v%d,v16,v%d" % (reg, reg),
                "  vsetivli zero,8,e8,m1,ta,ma",
            ])
    lines.extend(["  addi s4,s4,-1", "  bnez s4,MEASURE_LOOP", "MEASURE_DONE:"])
    for reg in destinations:
        lines.extend(["  vs1r.v v%d,(s3)" % reg, "  addi s3,s3,16"])
    lines.extend(["  fence rw,rw", "  la s3,OUTPUT"])
    for _ in destinations:
        lines.extend([
            "  ld t0,0(s3)", "  ld t1,0(s7)", "  bne t0,t1,BAD",
            "  ld t0,8(s3)", "  ld t1,8(s7)", "  bne t0,t1,BAD",
            "  addi s3,s3,16", "  addi s7,s7,16",
        ])
    lines.extend([
        "  csrr s6,cycle", "  sub s6,s6,s5", "  li t0,%d" % (LANDING_BYTES // 4 * QUANTUM),
        "  bgeu s6,t0,BAD", "  srli s6,s6,3", "  slli s6,s6,2", "  la t0,LANDING",
        "  add t0,t0,s6", "  jr t0", ".balign 4", "BAD: j BAD", "UNEXPECTED_TRAP: j BAD",
        "OK: j OK", ".balign 4", "LANDING:", ".rept %d" % (LANDING_BYTES // 4),
        "  j .", ".endr", ".section .data", ".balign 16", "INPUT_A:",
        ".byte " + ",".join(map(str, a)), "INPUT_B:", ".byte " + ",".join(map(str, b)), "INITIAL:",
    ])
    for reg in range(width):
        lines.append(".byte " + ",".join([str(0xA5 ^ reg)] * 16))
    lines.extend(["OUTPUT: .zero %d" % (16 * len(destinations)), "EXPECTED:"])
    for _, data in expected_registers(mode, width, implementation, n):
        lines.append(".byte " + ",".join(map(str, data)))
    return "\n".join(lines) + "\n"


def find_tools(prefix=None):
    prefixes = [prefix] if prefix else [os.environ.get("RISCV_PREFIX", ""), "riscv64-unknown-elf-"]
    if os.name == "nt" and not prefix:
        prefixes.extend(["E:/msys64/ucrt64/bin/riscv64-unknown-elf-", "C:/msys64/ucrt64/bin/riscv64-unknown-elf-"])
    for candidate in prefixes:
        if not candidate:
            continue
        found = {}
        for name in ("as", "ld", "objcopy", "objdump", "nm"):
            value = str(candidate) + name
            item = shutil.which(value)
            if not item:
                p = Path(value + (".exe" if os.name == "nt" else ""))
                item = str(p.resolve()) if p.is_file() else None
            found[name] = item
        if all(found.values()):
            return found
    raise ValueError("缺少 RISC-V 编译工具，请用 --prefix 指定名称前缀或完整位置")


def build_one(out, tools, mode, width, implementation, n):
    name = "%s_w%d_%s_n%d" % (mode, width, implementation, n)
    source = out / (name + ".S")
    source.write_text(assembly(mode, width, implementation, n), encoding="ascii")
    obj, elf, binary = (out / (name + suffix) for suffix in (".o", ".elf", ".bin"))
    commands = [
        [tools["as"], "-march=rv64gcv", "-mabi=lp64d", "-o", obj, source],
        [tools["ld"], "-m", "elf64lriscv", "-Ttext=0x80000000", "-Tdata=0x80100000",
         "--no-relax", "-e", "_start", "-o", elf, obj],
        [tools["objcopy"], "-O", "binary", elf, binary],
    ]
    for command in commands:
        result = subprocess.run(list(map(str, command)), capture_output=True, text=True, errors="replace", timeout=60)
        if result.returncode:
            raise ValueError(name + " 编译失败：" + result.stderr.strip())
    nm = subprocess.check_output([tools["nm"], "-n", str(elf)], text=True, errors="replace", timeout=30)
    symbols = {parts[2]: int(parts[0], 16) for line in nm.splitlines()
               if len(parts := line.split()) == 3 and parts[1].lower() in ("t", "d")}
    dis = subprocess.check_output([tools["objdump"], "-d", str(elf)], text=True, errors="replace", timeout=30)
    (out / (name + ".dis")).write_text(dis, encoding="utf-8")
    begin = dis.index("<MEASURE_LOOP>:")
    finish = dis.index("<MEASURE_DONE>:")
    body = dis[begin:finish]
    if implementation == "vdot":
        for reg, _ in expected_registers(mode, width, implementation, n):
            if not re.search(r"\b%08x\b" % vdot_word(reg), body):
                raise ValueError(name + " 编译结果缺少自定义点积")
    if implementation == "rvv" and len(re.findall(r"\bvwmul\.vv\b", body)) != width:
        raise ValueError(name + " 编译结果中的标准向量乘法数量不符")
    checked = expected_registers(mode, width, implementation, n)
    return {
        "name": name, "mode": mode, "width": width, "implementation": implementation, "iterations": n,
        "image": binary.name, "image_sha256": sha(binary), "source_sha256": sha(source),
        **{key: hex(symbols[key]) for key in ("OK", "BAD", "UNEXPECTED_TRAP", "LANDING")},
        "landing_bytes": LANDING_BYTES, "cycle_grid": QUANTUM,
        "checked_registers": ";".join(str(reg) for reg, _ in checked),
        "expected_registers": ";".join(data.hex() for _, data in checked),
        "operations_per_iteration": 0 if implementation == "control" else width,
        "instructions_per_iteration": 2 + width * {"control": 0, "vdot": 1, "rvv": 5}[implementation],
    }


def generate(out, iterations=(0, 64, 256, 1024), prefix=None):
    ns = sorted(set(iterations))
    if len(ns) < 3 or ns[0] != 0 or any(n < 0 for n in ns):
        raise ValueError("至少需要三个不同循环次数，并包含零次")
    tools = find_tools(prefix)
    out = fresh_directory(out)
    rows = []
    for mode, width in [("independent", w) for w in WIDTHS] + [("dependent", 1)]:
        for arm in ARMS:
            for n in ns:
                rows.append(build_one(out, tools, mode, width, arm, n))
    write_rows(out / "programs.csv", PROGRAM_COLUMNS, rows)
    write_rows(out / "study_parameters.csv", ("setting", "value"), [
        {"setting": "iterations", "value": ";".join(map(str, ns))},
        {"setting": "widths", "value": ";".join(map(str, WIDTHS))},
        {"setting": "program_count", "value": len(rows)},
        {"setting": "programs_content_sha256", "value": sha(out / "programs.csv")},
    ])
    write_rows(out / "tools.csv", ("tool", "location"), [{"tool": k, "location": v} for k, v in tools.items()])
    print("PROGRAM_BUILD_PASS programs=%d output=%s" % (len(rows), out))
    return rows


def load_programs(folder):
    folder = Path(folder).resolve()
    rows = read_rows(folder / "programs.csv")
    parameters = {row["setting"]: row["value"] for row in read_rows(folder / "study_parameters.csv")}
    if sha(folder / "programs.csv") != parameters.get("programs_content_sha256"):
        raise ValueError("程序清单与生成参数不一致")
    expected_iterations = [int(value) for value in parameters["iterations"].split(";")]
    validate_program_grid(rows, expected_iterations)
    if not rows or len({row["name"] for row in rows}) != len(rows):
        raise ValueError("程序清单为空或名称重复")
    for row in rows:
        for key in ("width", "iterations", "landing_bytes", "cycle_grid", "operations_per_iteration", "instructions_per_iteration"):
            row[key] = int(row[key])
        for key in ("OK", "BAD", "UNEXPECTED_TRAP", "LANDING"):
            row[key] = int(row[key], 0)
        image = folder / row["image"]
        if not image.is_file() or sha(image) != row["image_sha256"]:
            raise ValueError("程序文件变化：" + str(image))
    return rows


def validate_program_grid(programs, expected_iterations=None):
    expected = set(expected_iterations) if expected_iterations is not None else None
    for mode, width in [("independent", w) for w in WIDTHS] + [("dependent", 1)]:
        for arm in ARMS:
            selected = [row for row in programs if row["mode"] == mode and int(row["width"]) == width and row["implementation"] == arm]
            ns = [int(row["iterations"]) for row in selected]
            if len(ns) < 3 or 0 not in ns or len(set(ns)) != len(ns):
                raise ValueError("程序清单必须包含零次及至少三个不同循环次数，且不重复")
            if expected is None:
                expected = set(ns)
            if set(ns) != expected:
                raise ValueError("各组循环次数与生成参数不一致")
    return sorted(expected)


def classify(output, code, row, require_difftest=True):
    text = re.sub(r"\x1b\[[0-?]*[ -/]*[@-~]", "", output)
    failures = r"\bABORT\b|\bFAIL(?:ED)?\b|Assertion .*failed|different at pc|AddressSanitizer|Segmentation fault|double trap"
    if code != 0 or re.search(failures, text, re.I):
        return {"status": "FAIL", "reason": "程序退出异常或处理器比较失败"}
    if require_difftest and not re.search(r"Difftest enabled", text, re.I):
        return {"status": "FAIL", "reason": "缺少已启用处理器比较的确认"}
    endings = re.findall(r"Core 0: EXCEEDING CYCLE/INSTR LIMIT at pc = (0x[0-9a-fA-F]+)", text)
    if len(endings) != 1:
        return {"status": "FAIL", "reason": "缺少唯一终止位置"}
    pc = int(endings[0], 16)
    landing = int(row["LANDING"], 0) if isinstance(row["LANDING"], str) else int(row["LANDING"])
    offset = pc - landing
    if not (0 <= offset < int(row["landing_bytes"]) and offset % 4 == 0):
        return {"status": "FAIL", "terminal_pc": hex(pc), "reason": "程序未完成全部寄存器比较"}
    return {"status": "PASS", "terminal_pc": hex(pc), "cycles_lower": offset // 4 * int(row["cycle_grid"]), "reason": "全部128位结果比较后到达计时终点"}


def msys_path(path):
    value = Path(path).resolve().as_posix()
    return re.sub(r"^([A-Za-z]):/", lambda m: "/" + m[1].lower() + "/", value) if os.name == "nt" else value


def functional(programs, runner, library, out, seconds_limit=120):
    source = Path(programs).resolve()
    rows = load_programs(source)
    out = fresh_directory(out)
    write_rows(out / "reference_files.csv", ("role", "path", "sha256"),
               [{"role": role, "path": str(Path(path).resolve()), "sha256": sha(path)}
                for role, path in (("runner", runner), ("NEMU", library))])
    env = os.environ.copy()
    if os.name == "nt":
        env["PATH"] = "E:/msys64/usr/bin;E:/msys64/ucrt64/bin;" + env.get("PATH", "")
    results = []
    for row in rows:
        command = [str(Path(runner).resolve()), msys_path(library), msys_path(source / row["image"]),
                   hex(row["LANDING"]), hex(row["BAD"]), hex(row["LANDING"] + row["landing_bytes"])]
        start = time.monotonic()
        try:
            run = subprocess.run(command, capture_output=True, text=True, errors="replace", env=env, timeout=seconds_limit)
            text = run.stdout + run.stderr
            matches = re.findall(r"IMAGE PASS pc=(0x[0-9a-f]+) instructions=(\d+)", text)
            terminal = int(matches[0][0], 16) if len(matches) == 1 else -1
            offset = terminal - row["LANDING"]
            ok = (run.returncode == 0 and len(matches) == 1 and
                  0 <= offset < row["landing_bytes"] and offset % 4 == 0 and
                  not re.search(r"\bFAIL\b|\bTIMEOUT\b|\bABORT\b", text))
            code = run.returncode
        except subprocess.TimeoutExpired as error:
            text = str(error)
            ok, code = False, -1
        path = out / (row["name"] + ".txt")
        path.write_text(text, encoding="utf-8")
        results.append({**row, "repeat": 0, "status": "PASS" if ok else "FAIL", "cycles_lower": "",
                        "cycle_grid": "", "exit_code": code, "seconds": round(time.monotonic() - start, 4),
                        "output": path.name, "output_sha256": sha(path), "measurement_kind": "FUNCTIONAL_ONLY",
                        "reason": "NEMU功能执行；不产生处理器周期"})
        print(row["name"], results[-1]["status"], flush=True)
    write_rows(out / "runs.csv", RUN_COLUMNS, results)
    if not all(row["status"] == "PASS" for row in results):
        raise ValueError("新增程序的参考执行未全部通过")
    print("REFERENCE_EXECUTION_PASS programs=%d" % len(results))
    return results


def execute(programs, emu, library, out, repeat, workers, cycle_limit, seconds_limit):
    if repeat < 3 or not 1 <= workers <= 16 or cycle_limit <= 0 or seconds_limit <= 0:
        raise ValueError("重复至少三次，并发数量1至16，执行限制必须为正数")
    programs = Path(programs).resolve()
    rows = load_programs(programs)
    for path in (emu, library):
        if not Path(path).is_file():
            raise ValueError("缺少执行文件：" + str(path))
    out = fresh_directory(out)
    shutil.copyfile(programs / "programs.csv", out / "programs.csv")
    shutil.copyfile(programs / "study_parameters.csv", out / "study_parameters.csv")
    write_rows(out / "executables.csv", ("role", "path", "sha256"),
               [{"role": role, "path": str(Path(path).resolve()), "sha256": sha(path)} for role, path in (("emu", emu), ("NEMU", library))])
    jobs = [(row, r) for r in range(repeat) for row in (rows if r % 2 == 0 else list(reversed(rows)))]
    submissions = [{"submission_order": order, "name": row["name"], "repeat": rep,
                    "direction": "forward" if rep % 2 == 0 else "reverse", "workers": workers}
                   for order, (row, rep) in enumerate(jobs)]
    write_rows(out / "submission_order.csv", ("submission_order", "name", "repeat", "direction", "workers"), submissions)

    def run_one(job):
        order, (row, rep) = job
        path = out / (row["name"] + "_r%d.txt" % rep)
        command = [str(Path(emu).resolve()), "-i", str(programs / row["image"]), "--diff=" + str(Path(library).resolve()),
                   "--ram-size=256MB", "--no-squash", "-s", "1", "-C", str(cycle_limit)]
        began = time.monotonic()
        started = datetime.now(timezone.utc).isoformat(timespec="milliseconds")
        code = -1
        try:
            with path.open("w", encoding="utf-8") as stream:
                process = subprocess.run(command, stdout=stream, stderr=subprocess.STDOUT, timeout=seconds_limit)
            code = process.returncode
            verdict = classify(path.read_text(encoding="utf-8", errors="replace"), code, row)
        except (subprocess.TimeoutExpired, OSError) as error:
            with path.open("a", encoding="utf-8") as stream:
                stream.write("\n" + str(error))
            verdict = {"status": "FAIL", "reason": "超过执行时间或无法启动"}
        result = {**row, **verdict, "repeat": rep, "exit_code": code,
                  "seconds": round(time.monotonic() - began, 4), "output": path.name,
                  "output_sha256": sha(path), "measurement_kind": "XIANGSHAN_CYCLES",
                  "submission_order": order, "started_utc": started}
        print(row["name"], rep, result["status"], flush=True)
        return result

    results = []
    with ThreadPoolExecutor(max_workers=workers) as pool:
        pending = [pool.submit(run_one, job) for job in enumerate(jobs)]
        for future in as_completed(pending):
            results.append(future.result())
            results.sort(key=lambda row: row["submission_order"])
            temporary = out / "runs.partial.csv"
            write_rows(temporary, RUN_COLUMNS, results)
            temporary.replace(out / "runs.csv")
    write_rows(out / "runs.csv", RUN_COLUMNS, results)
    write_rows(out / "actual_order.csv", ("submission_order", "name", "repeat", "started_utc", "seconds", "status"),
               sorted(results, key=lambda row: row["started_utc"]))
    write_rows(out / "commands.csv", ("name", "repeat", "cycle_limit", "seconds_limit", "workers"),
               [{"name": row["name"], "repeat": repeat, "cycle_limit": cycle_limit,
                 "seconds_limit": seconds_limit, "workers": workers} for row in rows])
    analyze(out, out / "analysis")
    if not all(row["status"] == "PASS" for row in results):
        raise ValueError("部分程序失败；已保留每次输出，不会自动重试")
    return results


def line_fit(points, quantum):
    if len(points) < 3 or len({x for x, _ in points}) != len(points):
        raise ValueError("拟合需要至少三个不同循环次数")
    if any(not math.isfinite(float(x)) or not math.isfinite(float(y)) for x, y in points):
        raise ValueError("拟合数据包含非有限数")
    xm = statistics.mean(x for x, _ in points)
    ym = statistics.mean(y for _, y in points)
    ssx = sum((x - xm) ** 2 for x, _ in points)
    slope = sum((x - xm) * (y - ym) for x, y in points) / ssx
    intercept = ym - slope * xm
    residual = sum((y - intercept - slope * x) ** 2 for x, y in points)
    total = sum((y - ym) ** 2 for _, y in points)
    return {"slope": slope, "intercept": intercept, "r_squared": 1 - residual / total if total else 0,
            "slope_error_bound": (quantum - 1) * sum(abs(x - xm) for x, _ in points) / (2 * ssx),
            "max_residual": max(abs(y - intercept - slope * x) for x, y in points)}


def summarize(programs, runs, expected_repeats=3, expected_iterations=None):
    validate_program_grid(programs, expected_iterations)
    if expected_repeats < 3:
        raise ValueError("期望重复数量至少为三次")
    if any(row.get("measurement_kind") != "XIANGSHAN_CYCLES" for row in runs):
        raise ValueError("参考执行数据不能用于处理器计时分析")
    names = {row["name"] for row in programs}
    if any(row["name"] not in names for row in runs):
        raise ValueError("测量包含程序清单之外的名称")
    if len({(row["name"], row["repeat"]) for row in runs}) != len(runs):
        raise ValueError("存在重复测量条目")
    rows, fits = [], {}
    for mode, width in [("independent", w) for w in WIDTHS] + [("dependent", 1)]:
        for arm in ARMS:
            selected = [row for row in programs if row["mode"] == mode and int(row["width"]) == width and row["implementation"] == arm]
            if not selected:
                raise ValueError("程序种类不完整")
            points, repetitions = [], []
            complete = True
            grids = {int(row["cycle_grid"]) for row in selected}
            if len(grids) != 1:
                raise ValueError("同组计时精度不一致")
            grid = next(iter(grids))
            for program in selected:
                measured = [row for row in runs if row["name"] == program["name"]]
                if ({int(row["repeat"]) for row in measured} != set(range(expected_repeats)) or
                        len(measured) != expected_repeats or
                        any(row["status"] != "PASS" or row["cycles_lower"] in ("", None) for row in measured)):
                    complete = False
                    continue
                ys = [int(row["cycles_lower"]) + (grid - 1) / 2 for row in measured]
                points.append((int(program["iterations"]), statistics.median(ys)))
                repetitions.append(len(ys))
            result = {"mode": mode, "width": width, "implementation": arm,
                      "status": "NOT_MEASURED" if not any(row["name"] in {p["name"] for p in selected} for row in runs) else "INCOMPLETE",
                      "cycle_grid": grid, "point_count": len(points), "repeat_min": min(repetitions) if repetitions else ""}
            if complete:
                fitted = line_fit(sorted(points), grid)
                if fitted["slope"] <= fitted["slope_error_bound"] or fitted["r_squared"] < 0.99:
                    result["status"] = "UNRELIABLE"
                else:
                    result["status"] = "PASS"
                result.update(fitted)
            rows.append(result)
            fits[(mode, width, arm)] = result
    summaries = []
    for mode, width in [("independent", w) for w in WIDTHS] + [("dependent", 1)]:
        control = fits[(mode, width, "control")]
        for arm in ("rvv", "vdot"):
            group = fits[(mode, width, arm)]
            result = {"mode": mode, "width": width, "implementation": arm, "status": group["status"],
                      "gross_cycles_per_dot": "", "adjusted_cycles_per_dot": "", "adjusted_error_bound": ""}
            if group["status"] == "PASS":
                result["gross_cycles_per_dot"] = group["slope"] / width
            if group["status"] == "PASS" and control["status"] == "PASS":
                adjusted = (group["slope"] - control["slope"]) / width
                bound = (group["slope_error_bound"] + control["slope_error_bound"]) / width
                result.update(adjusted_cycles_per_dot=adjusted, adjusted_error_bound=bound)
                if adjusted <= bound:
                    result["status"] = "UNRELIABLE"
            elif group["status"] == "PASS":
                result["status"] = "CONTROL_INCOMPLETE"
            summaries.append(result)
    return rows, summaries


def analyze(folder, out):
    folder = Path(folder).resolve()
    programs = read_rows(folder / "programs.csv")
    parameters = {row["setting"]: row["value"] for row in read_rows(folder / "study_parameters.csv")}
    if sha(folder / "programs.csv") != parameters.get("programs_content_sha256"):
        raise ValueError("程序清单与生成参数不一致")
    expected_ns = [int(value) for value in parameters["iterations"].split(";")]
    runs = read_rows(folder / "runs.csv") if (folder / "runs.csv").is_file() else []
    expected_repeats = 3
    if (folder / "commands.csv").is_file():
        planned = read_rows(folder / "commands.csv")
        repeats = {int(row["repeat"]) for row in planned}
        if len(repeats) != 1 or {row["name"] for row in planned} != {row["name"] for row in programs}:
            raise ValueError("执行计划与程序清单不一致")
        expected_repeats = next(iter(repeats))
    for row in runs:
        path = folder / row["output"]
        if not path.is_file() or sha(path) != row["output_sha256"]:
            raise ValueError("执行输出已变化：" + str(path))
        if row["measurement_kind"] == "XIANGSHAN_CYCLES" and row["status"] == "PASS":
            program = next((p for p in programs if p["name"] == row["name"]), None)
            if program is None:
                raise ValueError("找不到对应程序")
            parsed = classify(path.read_text(encoding="utf-8", errors="replace"), int(row["exit_code"]), program)
            if parsed["status"] != "PASS" or str(parsed["cycles_lower"]) != row["cycles_lower"]:
                raise ValueError("结果表与原始输出不一致")
    fits, summaries = summarize(programs, runs, expected_repeats, expected_ns)
    out = fresh_directory(out)
    write_rows(out / "fits.csv", ("mode", "width", "implementation", "status", "cycle_grid", "point_count", "repeat_min", "slope", "intercept", "r_squared", "slope_error_bound", "max_residual"), fits)
    write_rows(out / "comparison.csv", ("mode", "width", "implementation", "status", "gross_cycles_per_dot", "adjusted_cycles_per_dot", "adjusted_error_bound"), summaries)
    ratios = []
    for mode, width in [("independent", w) for w in WIDTHS] + [("dependent", 1)]:
        left = next(row for row in summaries if row["mode"] == mode and row["width"] == width and row["implementation"] == "rvv")
        right = next(row for row in summaries if row["mode"] == mode and row["width"] == width and row["implementation"] == "vdot")
        ratio = {"mode": mode, "width": width, "status": "NOT_AVAILABLE", "gross_speedup": "", "adjusted_speedup": ""}
        if left["status"] == right["status"] == "PASS":
            ratio.update(status="PASS", gross_speedup=left["gross_cycles_per_dot"] / right["gross_cycles_per_dot"],
                         adjusted_speedup=left["adjusted_cycles_per_dot"] / right["adjusted_cycles_per_dot"])
        ratios.append(ratio)
    write_rows(out / "speedup.csv", ("mode", "width", "status", "gross_speedup", "adjusted_speedup"), ratios)
    lines = ["# 独立点积数量比较", "", "包含循环开销的值与扣除空循环后的估计分别报告。扣除后的值不代表纯电路延迟。", "",
             "| 执行方式 | 独立数量 | 实现 | 状态 | 含循环周期/点积 | 扣空循环后周期/点积 |", "| --- | ---: | --- | --- | ---: | ---: |"]
    for row in summaries:
        gross = "未测" if row["gross_cycles_per_dot"] == "" else "%.6f" % row["gross_cycles_per_dot"]
        adjusted = "未测" if row["adjusted_cycles_per_dot"] == "" else "%.6f" % row["adjusted_cycles_per_dot"]
        lines.append("| %s | %s | %s | %s | %s | %s |" % (row["mode"], row["width"], row["implementation"], row["status"], gross, adjusted))
    (out / "report.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print("ANALYSIS_COMPLETE", out)
    return fits, summaries


def estimate(programs, repeat, workers, cycle_limit, seconds_limit, cycles_per_second=None):
    if repeat < 3 or not 1 <= workers <= 16 or cycle_limit <= 0 or seconds_limit <= 0:
        raise ValueError("执行参数无效")
    rows = load_programs(programs)
    attempts = len(rows) * repeat
    print("程序数量：%d；每个重复%d次；合计%d次；同时执行%d个。" % (len(rows), repeat, attempts, workers))
    print("单次允许最多%d个模拟周期、%g秒；全部进程用时上限%.3f小时。" % (cycle_limit, seconds_limit, attempts * seconds_limit / 3600))
    print("按指定并发数量，等待时间上限约%.3f小时。" % (math.ceil(attempts / workers) * seconds_limit / 3600))
    if cycles_per_second is None:
        print("缺少本机完整处理器执行速度；实际用时尚不能估计。")
    elif cycles_per_second > 0:
        print("按提供的%g模拟周期/秒，若每次均达到周期上限，约需%.3f小时。" % (cycles_per_second, attempts * cycle_limit / cycles_per_second / workers / 3600))
    else:
        raise ValueError("执行速度必须为正数")
    return attempts


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="command", required=True)
    gen = sub.add_parser("generate")
    gen.add_argument("--out", type=Path, required=True)
    gen.add_argument("--prefix")
    gen.add_argument("--iterations", type=int, nargs="+", default=[0, 64, 256, 1024])
    fun = sub.add_parser("functional")
    fun.add_argument("--programs", type=Path, required=True)
    fun.add_argument("--runner", type=Path, required=True)
    fun.add_argument("--library", type=Path, required=True)
    fun.add_argument("--out", type=Path, required=True)
    fun.add_argument("--seconds-limit", type=float, default=120)
    for command in ("execute", "estimate"):
        parser = sub.add_parser(command)
        parser.add_argument("--programs", type=Path, required=True)
        parser.add_argument("--repeat", type=int, default=3)
        parser.add_argument("--workers", type=int, default=1)
        parser.add_argument("--cycle-limit", type=int, required=True)
        parser.add_argument("--seconds-limit", type=float, required=True)
        if command == "execute":
            parser.add_argument("--emu", type=Path, required=True)
            parser.add_argument("--library", type=Path, required=True)
            parser.add_argument("--out", type=Path, required=True)
        else:
            parser.add_argument("--cycles-per-second", type=float)
    analysis = sub.add_parser("analyze")
    analysis.add_argument("--results", type=Path, required=True)
    analysis.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    try:
        if args.command == "generate":
            generate(args.out, args.iterations, args.prefix)
        elif args.command == "functional":
            functional(args.programs, args.runner, args.library, args.out, args.seconds_limit)
        elif args.command == "execute":
            execute(args.programs, args.emu, args.library, args.out, args.repeat, args.workers, args.cycle_limit, args.seconds_limit)
        elif args.command == "estimate":
            estimate(args.programs, args.repeat, args.workers, args.cycle_limit, args.seconds_limit, args.cycles_per_second)
        elif args.command == "analyze":
            analyze(args.results, args.out)
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print("ERROR", str(error))
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
