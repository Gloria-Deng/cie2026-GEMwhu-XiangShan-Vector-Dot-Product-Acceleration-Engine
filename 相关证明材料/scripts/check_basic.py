#!/usr/bin/env python3

from pathlib import Path
import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile
ROOT = Path(__file__).resolve().parents[1]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / "sim"))
import golden_vdot as golden
sys.path.insert(0, str(ROOT / "tools"))
from runtime_common import new_output

def execute(command):
    result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if result.returncode:
        raise SystemExit(result.stdout + result.stderr)
    return result.stdout + result.stderr

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, help='new external output directory; default: system temporary directory')
    args = parser.parse_args()
    if not shutil.which("iverilog") or not shutil.which("vvp"):
        raise SystemExit("Install Icarus Verilog and add iverilog and vvp to PATH.")
    out = new_output(args.out) if args.out else Path(tempfile.mkdtemp(prefix='vdot_basic_'))
    print('output:', out, flush=True)
    total = 0
    counts = {}
    for group in ("pos", "neg", "bound", "rand"):
        lines = (ROOT / ("tests/cases_" + group + ".txt")).read_text().splitlines()
        rows = [line.split() for line in lines if line.strip()]
        for row in rows:
            if len(row) != 4:
                raise SystemExit("Invalid test row")
            _, a, b, expected = row
            actual = golden.vdot_vd_bits(bytes.fromhex(a)[::-1], bytes.fromhex(b)[::-1])
            if actual != int(expected, 16):
                raise SystemExit("Reference result differs in " + group + " case " + row[0])
        counts[group] = len(rows)
        total += len(rows)
    print("REFERENCE PASS cases=" + str(total), flush=True)
    build = out / 'build'
    build.mkdir()
    outputs = []
    for label, source, extra in (
        ("RTL", "rtl/xs_vdot_unit.sv", []),
        ("CHISEL", "gen/chisel/VDotUnit_t0_n8_o32_a19.sv", ["-DDUT_CHISEL"]),
    ):
        for group in ("pos", "neg", "bound", "rand"):
            executable = str(build / (label.lower() + "_" + group + ".vvp"))
            execute(["iverilog", "-g2012", "-o", executable,
                     '-DCASE_FILE="tests/cases_' + group + '.txt"', *extra,
                     source, "tb/tb_vdot.sv"])
            output = execute(["vvp", executable])
            match = re.search(r"SUMMARY .*total=(\d+) pass=(\d+) fail=(\d+)", output)
            if not match or tuple(map(int, match.groups())) != (counts[group], counts[group], 0):
                raise SystemExit(output[-2000:])
            outputs.append(label + " " + group + " PASS cases=" + str(counts[group]))
            print(outputs[-1], flush=True)
    print("BASIC_TEST_PASS cases=" + str(total) + " implementations=2", flush=True)
    (out / "basic_test.txt").write_text("REFERENCE PASS cases=" + str(total) + "\n" + "\n".join(outputs) + "\nBASIC_TEST_PASS\n", encoding="utf-8")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
