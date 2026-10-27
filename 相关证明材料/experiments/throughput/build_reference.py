from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import shutil
import subprocess

import study


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--nemu-source", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--cc")
    args = parser.parse_args()
    try:
        cc = args.cc or shutil.which("gcc")
        if not cc and os.name == "nt" and Path("E:/msys64/usr/bin/gcc.exe").is_file():
            cc = "E:/msys64/usr/bin/gcc.exe"
        if not cc:
            raise ValueError("找不到本机 C 编译器，请用 --cc 指定")
        source = args.nemu_source.resolve()
        out = study.fresh_directory(args.out)
        use_msys = os.name == "nt" and "/usr/bin/" in str(cc).replace("\\", "/")
        env = os.environ.copy()
        env["PATH"] = str(Path(cc).resolve().parent) + os.pathsep + env.get("PATH", "")

        def argument(value):
            text = value.as_posix() if isinstance(value, Path) else str(value)
            return re.sub(r"^(-I)?([A-Za-z]):/", lambda match: (match[1] or "") + "/" + match[2].lower() + "/", text) if use_msys else text

        def run(name, command):
            command = [str(command[0])] + [argument(value) for value in command[1:]]
            result = subprocess.run(command, capture_output=True, text=True, errors="replace", env=env, timeout=120)
            (out / (name + ".txt")).write_text(result.stdout + result.stderr, encoding="utf-8")
            if result.returncode:
                raise ValueError(name + "失败：" + result.stdout + result.stderr)
            return result.stdout

        suffix = ".exe" if os.name == "nt" else ""
        probe = out / ("layout" + suffix)
        includes = ["include", "lib-include", "src/isa/riscv64/include", "src/engine/interpreter",
                    "resource/softfloat/repo/source/include", "resource/softfloat/repo/source/RISCV"]
        command = [cc, "-O0", "-o", probe, study.ROOT / "nemu/cosim/probe_offsets.c"]
        command.extend("-I" + (source / part).as_posix() for part in includes)
        command.extend(["-D__ISA__=riscv64", "-D__ISA_riscv64__=1", "-D_SHARE=1", "-include", source / "include/generated/autoconf.h"])
        run("compile_layout", command)
        text = run("read_layout", [probe])
        match = re.search(r"LAYOUT_BEGIN\s*\n(.*?)LAYOUT_END", text, re.S)
        if not match:
            raise ValueError("参考模型没有给出可用的内存布局")
        values = dict(line.split() for line in match[1].strip().splitlines())
        required = {"OFF_GPR", "OFF_PC", "OFF_MODE", "OFF_MSTATUS", "OFF_END"}
        if not required <= values.keys():
            raise ValueError("参考模型缺少需要的位置说明")
        header = "#ifndef COSIM_LAYOUT_H\n#define COSIM_LAYOUT_H\n"
        header += "".join("#define %s %d\n" % (name, int(value)) for name, value in values.items()) + "#endif\n"
        (out / "cosim_layout.h").write_text(header, encoding="ascii")
        executable = out / ("reference_runner" + suffix)
        command = [cc, "-O2", "-Wall", "-I" + out.as_posix(), "-o", executable, study.HERE / "reference_runner.c"]
        if os.name != "nt":
            command.append("-ldl")
        run("compile_runner", command)
        print("REFERENCE_RUNNER_BUILD_PASS", executable)
        return 0
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print("REFERENCE_RUNNER_BUILD_FAIL", error)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
