#!/usr/bin/env python3
"""Recompute optimized RVV measurements from complete processor outputs."""
from __future__ import annotations

import argparse
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "experiments/throughput"))
import study


def verify(results, out):
    programs = study.read_rows(results / "programs.csv")
    if not any(r["implementation"] == "rvv_opt2" for r in programs):
        raise ValueError("需要包含原始对照、opt1、opt2和vdot的完整新测量")
    fits, comparison = study.analyze(results, out)
    if any(r["status"] != "PASS" for r in comparison):
        raise ValueError("测量缺失、重复次数不足或拟合不可靠；不绘图，不给出加速比")
    ratios = []
    for row in comparison:
        if row["implementation"] == "vdot":
            continue
        custom = next(r for r in comparison if r["mode"] == row["mode"] and
                      r["width"] == row["width"] and r["implementation"] == "vdot")
        ratios.append({"mode": row["mode"], "width": row["width"],
                       "implementation": row["implementation"], "status": "PASS",
                       "gross_speedup": row["gross_cycles_per_dot"] / custom["gross_cycles_per_dot"],
                       "adjusted_speedup": row["adjusted_cycles_per_dot"] / custom["adjusted_cycles_per_dot"]})
    study.write_rows(out / "optimized_speedup.csv", ("mode", "width", "implementation", "status",
                     "gross_speedup", "adjusted_speedup"), ratios)
    return comparison


def plot(rows, out):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    from matplotlib.font_manager import FontProperties
    for candidate in ("C:/Windows/Fonts/msyh.ttc", "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"):
        if Path(candidate).is_file():
            font = FontProperties(fname=candidate)
            matplotlib.font_manager.fontManager.addfont(candidate)
            plt.rcParams["font.family"] = font.get_name()
            break
    plt.rcParams.update({"axes.unicode_minus": False, "font.size": 11, "svg.fonttype": "none"})
    fig, axes = plt.subplots(1, 2, figsize=(11.6, 4.7), layout="constrained")
    colors = {"rvv": "#7E8B97", "rvv_opt1": "#368AA3", "rvv_opt2": "#B7791F", "vdot": "#21654B"}
    names = {"rvv": "原始 RVV", "rvv_opt1": "RVV opt1", "rvv_opt2": "RVV opt2", "vdot": "vdot"}
    for arm, color in colors.items():
        selected = sorted((r for r in rows if r["mode"] == "independent" and r["implementation"] == arm), key=lambda r: r["width"])
        axes[0].plot([r["width"] for r in selected], [r["gross_cycles_per_dot"] for r in selected],
                     marker="o", color=color, label=names[arm])
    axes[0].set(xlabel="独立点积数量", ylabel="周期/点积（含循环）", title="独立点积吞吐")
    axes[0].set_xticks(study.WIDTHS)
    axes[0].legend()
    selected = [next(r for r in rows if r["mode"] == "dependent" and r["implementation"] == arm)
                for arm in ("rvv", "rvv_opt1", "vdot")]
    axes[1].bar([names[r["implementation"]] for r in selected], [r["gross_cycles_per_dot"] for r in selected],
                color=[colors[r["implementation"]] for r in selected])
    axes[1].set(ylabel="周期/点积（含循环）", title="依赖计算；opt2 不适用")
    for axis in axes:
        axis.spines[["top", "right"]].set_visible(False)
        axis.set_axisbelow(True)
        axis.grid(axis="y", color="#E4E8EC", linewidth=.6)
    fig.suptitle("优化 RVV 与 vdot：完整处理器测量", x=.02, ha="left", fontsize=16, weight="bold")
    for suffix in ("png", "svg", "pdf"):
        fig.savefig(out / ("optimized_rvv_comparison." + suffix), dpi=180, facecolor="white")
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--results", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--plot", action="store_true")
    args = parser.parse_args()
    try:
        rows = verify(args.results.resolve(), args.out.resolve())
        if args.plot:
            plot(rows, args.out.resolve())
        print("OPT_MEASUREMENTS_PASS groups=%d" % len(rows))
        return 0
    except (ValueError, OSError, ImportError, KeyError, StopIteration) as error:
        print("OPT_MEASUREMENTS_FAIL", error)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
