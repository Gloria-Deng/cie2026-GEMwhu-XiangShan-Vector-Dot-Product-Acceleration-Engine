#!/usr/bin/env python3
"""Check assembly preservation, instruction semantics, and invalid-data rejection."""
from __future__ import annotations

from pathlib import Path
import random

import study


def emulate(mode, width, arm, iterations, a, b, agnostic_ones):
    """Independent RVV subset interpreter; never produces timing measurements."""
    text = study.assembly(mode, width, arm, iterations)
    regs = [bytearray([0xCD] * 16) for _ in range(32)]
    regs[30], regs[31] = bytearray(a), bytearray(b)
    for reg in range(width if mode == "independent" else 0):
        regs[reg] = bytearray([0xA5 ^ reg] * 16)
    sew, vl, tu = 8, 16, False

    def instruction(line):
        nonlocal sew, vl, tu
        op, _, operands = line.strip().partition(" ")
        values = operands.split(",")
        if op == "vsetivli":
            vl, sew, tu = int(values[1]), int(values[2][1:]), values[4] == "tu"
        elif op == "vmv.v.i":
            reg = int(values[0][1:])
            regs[reg][:vl * sew // 8] = bytes(vl * sew // 8)
        elif op == "vwmul.vv":
            dst, rhs, lhs = [int(v[1:]) for v in values]
            left, right = bytes(regs[lhs]), bytes(regs[rhs])
            products = [int.from_bytes(left[i:i + 1], "little", signed=True) *
                        int.from_bytes(right[i:i + 1], "little", signed=True) for i in range(vl)]
            payload = b"".join((p & 0xFFFF).to_bytes(2, "little") for p in products)
            regs[dst][:] = payload[:16]
            if not tu and agnostic_ones:
                regs[dst + 1][:] = bytes([255] * 16)
        elif op == "vwredsum.vs":
            dst, src, seed = [int(v[1:]) for v in values]
            product = bytes(regs[src])
            total = int.from_bytes(regs[seed][:4], "little", signed=True)
            total += sum(int.from_bytes(product[2 * i:2 * i + 2], "little", signed=True) for i in range(vl))
            regs[dst][:4] = (total & 0xFFFFFFFF).to_bytes(4, "little")
            if not tu and agnostic_ones:
                regs[dst][4:] = bytes([255] * 12)
        elif op == "vmv1r.v":
            dst, src = [int(v[1:]) for v in values]
            regs[dst][:] = regs[src]

    pre, body = text.split("MEASURE_LOOP:\n", 1)
    body = body.split("  addi s4,s4,-1", 1)[0]
    # Execute just the optimized preparation, after the data loads.
    start = pre.rindex("  vsetivli zero,16,e8,m1,tu,mu")
    for line in pre[start:].splitlines():
        instruction(line)
    for _ in range(iterations):
        for line in body.splitlines():
            instruction(line)
    return [(r, bytes(regs[r])) for r in (range(width) if mode == "independent" else [30])]


def checks():
    preserved = 0
    saved = study.HERE / "verified/generated_source"
    for mode, width, arm in study.program_groups():
        for n in (0, 64, 256, 1024):
            path = saved / ("%s_w%d_%s_n%d.S" % (mode, width, arm, n))
            if not path.is_file() or path.read_text(encoding="ascii") != study.assembly(mode, width, arm, n):
                raise ValueError("原始程序生成内容变化：" + str(path))
            preserved += 1
    rng = random.Random(20261029)
    cases = [(bytes([128] * 8 + [81] * 8), bytes([128] * 8 + [183] * 8)),
             (bytes([128] * 8 + [81] * 8), bytes([127] * 8 + [183] * 8)), study.input_data()]
    cases += [(bytes(rng.randrange(256) for _ in range(16)), bytes(rng.randrange(256) for _ in range(16))) for _ in range(30)]
    checked = 0
    for mode, width, arm in study.program_groups(True):
        if arm not in study.OPT_ARMS:
            continue
        for n in (0, 1, 2, 7):
            for a, b in cases:
                for agnostic in (False, True):
                    actual = emulate(mode, width, arm, n, a, b, agnostic)
                    expected = a
                    for _ in range(n if mode == "dependent" else min(n, 1)):
                        value = sum(int.from_bytes(expected[i:i + 1], "little", signed=True) *
                                    int.from_bytes(b[i:i + 1], "little", signed=True) for i in range(8))
                        expected = (value & 0xFFFFFFFF).to_bytes(4, "little") + bytes(12)
                    for reg, result in actual:
                        want = bytes([0xA5 ^ reg] * 16) if mode == "independent" and n == 0 else expected
                        if result != want:
                            raise ValueError("完整128位结果不符：%s w%d %s n%d" % (mode, width, arm, n))
                    checked += 1
    try:
        study.assembly("dependent", 1, "rvv_opt2", 1)
    except ValueError:
        pass
    else:
        raise ValueError("依赖计算错误地接受了批量实现")
    fake = []
    for mode, width, arm in study.program_groups(True):
        for n in (0, 64, 256, 1024):
            fake.append({"name": "%s_%d_%s_%d" % (mode, width, arm, n), "mode": mode,
                         "width": width, "implementation": arm, "iterations": n, "cycle_grid": 8})
    _, unmeasured = study.summarize(fake, [])
    if any(r["status"] != "NOT_MEASURED" or r["gross_cycles_per_dot"] != "" for r in unmeasured):
        raise ValueError("未测量数据出现周期数字")
    try:
        study.summarize(fake, [{**fake[0], "repeat": 0, "measurement_kind": "FUNCTIONAL_ONLY"}])
    except ValueError:
        pass
    else:
        raise ValueError("功能执行被用于周期统计")
    # Known mathematical relationships exist only in memory for this test.
    # They are never written as measurement records or passed to plotting.
    calculated = []
    rates = {"control": 2, "vdot": 4, "rvv": 10, "rvv_opt1": 8, "rvv_opt2": 6}
    for row in fake:
        for repeat in range(3):
            calculated.append({**row, "repeat": repeat, "status": "PASS",
                               "cycles_lower": 128 + rates[row["implementation"]] * row["width"] * row["iterations"],
                               "measurement_kind": "XIANGSHAN_CYCLES"})
    _, fitted = study.summarize(fake, calculated)
    if len(fitted) != 23 or any(r["status"] != "PASS" or r["gross_cycles_per_dot"] != rates[r["implementation"]] for r in fitted):
        raise ValueError("优化对照的已知数学关系复算错误")
    try:
        study.summarize(fake, calculated + calculated[:1])
    except ValueError:
        pass
    else:
        raise ValueError("重复测量未被拒绝")
    print("OPT_LOCAL_CHECK_PASS original_programs=%d semantic_cases=%d groups=%d" %
          (preserved, checked, len(unmeasured)))


if __name__ == "__main__":
    try:
        checks()
    except (ValueError, OSError) as error:
        print("OPT_LOCAL_CHECK_FAIL", error)
        raise SystemExit(1)
