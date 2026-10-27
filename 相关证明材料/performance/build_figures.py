import argparse
import csv
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.font_manager import FontProperties
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch


ROOT = Path(__file__).resolve().parents[1]


def setup_font():
    candidates = [Path("C:/Windows/Fonts/msyh.ttc"), Path("/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc")]
    for path in candidates:
        if path.exists():
            font = FontProperties(fname=str(path))
            matplotlib.font_manager.fontManager.addfont(str(path))
            plt.rcParams["font.family"] = font.get_name()
            break
    plt.rcParams.update({"axes.unicode_minus": False, "font.size": 11, "svg.fonttype": "none"})


def load_rows(path):
    with path.open(encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))
    selected = {}
    for size in (16, 32):
        values = []
        for impl in (1, 3, 6):
            matches = [r for r in rows if int(r["M"]) == size and int(r["impl"]) == impl and int(r["packed"]) == 1]
            if len(matches) != 1:
                raise ValueError(f"Expected one row for size={size} implementation={impl}")
            row = matches[0]
            values.append((int(row["cycles_median"]), int(row["runs"])))
        selected[size] = values
    return selected


def comparison(rows, out):
    fig, axes = plt.subplots(1, 2, figsize=(11.6, 4.7), layout="constrained")
    colors = ["#7E8B97", "#368AA3", "#21654B"]
    names = ["标准 RVV＋连续布局", "vdot＋直接取出结果", "vdot＋四列展开与向量累加"]
    for axis, size in zip(axes, (16, 32)):
        vals = [v[0] for v in rows[size]]
        axis.barh(range(3), vals, color=colors, height=.52)
        axis.errorbar(vals, range(3), xerr=[[0] * 3, [1023] * 3], fmt="none", ecolor="#1F2933", capsize=4, lw=1.1)
        axis.set_yticks(range(3), names)
        axis.invert_yaxis()
        axis.set_title(f"{size} × {size} × {size}，每项 {rows[size][0][1]} 次成功测量", loc="left", fontsize=12, weight="bold")
        axis.set_xlim(0, max(vals) * 1.28)
        for i, value in enumerate(vals):
            axis.text(value + 1100, i, f"{value:,}", va="center", fontsize=10)
        axis.set_xlabel("记录周期；黑线表示向上最多 1,023 周期的计时区间")
        axis.spines[["top", "right", "left"]].set_visible(False)
        axis.tick_params(axis="y", length=0)
        axis.set_axisbelow(True)
        axis.grid(axis="x", color="#E4E8EC", linewidth=.6)
    fig.suptitle("真实矩阵乘法：同一连续布局下的实现比较", x=.02, ha="left", fontsize=16, weight="bold")
    fig.supxlabel("计时包含 B 数据整理、装载、计算、累加与写回；不包含启动与结果校验。来源：2026-10-21 随附测量。", fontsize=9)
    for suffix in ("png", "svg", "pdf"):
        fig.savefig(out / f"gemm_comparison.{suffix}", dpi=180, facecolor="white")
    plt.close(fig)


def box(axis, x, y, w, h, title, body, color):
    axis.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.012,rounding_size=0.015", facecolor=color, edgecolor="#C1CDD4", lw=.8))
    axis.text(x + w / 2, y + h * .70, title, ha="center", va="center", fontsize=11, weight="bold")
    axis.text(x + w / 2, y + h * .34, body, ha="center", va="center", fontsize=10, linespacing=1.6)


def workflow(out):
    fig, axis = plt.subplots(figsize=(11.6, 5.4))
    axis.set_xlim(0, 1)
    axis.set_ylim(0, 1)
    axis.axis("off")
    axis.text(.02, .96, "应用如何调用点积指令，以及时间花在哪里", fontsize=17, weight="bold", va="top")
    axis.text(.02, .86, "计算前：检查尺寸与输出空间，明确选择 C_REFERENCE 或 CUSTOM_VDOT。", fontsize=11)
    items = [("连续输入", "A 为行连续\nB 转置为连续列"), ("共享装载", "四列共用 A\n分别装入 B"), ("指令计算", "每八字节一次 vdot\n结果留在向量寄存器"), ("累加与写回", "按 e32 累加\n每个输出末尾取出")]
    for i, (title, body) in enumerate(items):
        x = .025 + i * .247
        box(axis, x, .54, .205, .245, title, body, "#EFF5F7" if i < 2 else "#E9F3ED")
        if i < 3:
            axis.add_patch(FancyArrowPatch((x + .212, .662), (x + .238, .662), arrowstyle="-|>", mutation_scale=14, color="#526570"))
    axis.plot([.025, .97], [.48, .48], color="#21654B", lw=2)
    axis.text(.50, .445, "矩阵计时区间：数据整理＋装载＋点积＋累加＋输出", ha="center", fontsize=11, color="#21654B")
    box(axis, .03, .11, .43, .245, "取回结果的两种实现", "旧路径：向量存内存 → 标量读回\n改进路径：vmv.x.s 直接取出低 32 位", "#F5F6F8")
    box(axis, .52, .11, .43, .245, "独立点积数量比较", "每次循环放入 1、2、4、8、16 个点积\n先确认完整结果，再比较处理器周期", "#F5F6F8")
    fig.subplots_adjust(left=.02, right=.98, top=.98, bottom=.02)
    for suffix in ("png", "svg", "pdf"):
        fig.savefig(out / f"application_flow.{suffix}", dpi=180, facecolor="white")
    plt.close(fig)


def load_api(path):
    with path.open(encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))
    if len(rows) != 12:
        raise ValueError("Expected 12 measured API groups")
    values = {}
    for row in rows:
        if row["status"] != "PASS" or int(row["successful"]) != 3 or int(row["expected"]) != 3 or int(row["cycle_grid"]) != 8:
            raise ValueError("API measurements are incomplete")
        key = (int(row["M"]), int(row["N"]), int(row["K"]), int(row["method"]), row["scope"])
        if key in values:
            raise ValueError("Duplicate API group")
        values[key] = int(row["median"])
    return values


def api_comparison(values, out):
    fig, axes = plt.subplots(1, 3, figsize=(11.6, 4.9), layout="constrained")
    shapes = [(3, 5, 13), (16, 16, 16), (32, 32, 32)]
    colors = ["#368AA3", "#21654B"]
    for axis, shape in zip(axes, shapes):
        for method in (0, 1):
            nums = [values[(*shape, method, scope)] for scope in ("compute", "pack_compute")]
            xs = [i + (method - .5) * .34 for i in (0, 1)]
            axis.bar(xs, nums, width=.31, color=colors[method], label=["直接取回", "四列与向量累加"][method])
            for x, n in zip(xs, nums):
                axis.annotate(f"{n:,}", (x, n), xytext=(0, 5), textcoords="offset points", ha="center", fontsize=9)
        ceiling = max(values[(*shape, method, scope)] for method in (0, 1) for scope in ("compute", "pack_compute"))
        axis.set_ylim(0, ceiling * 1.22)
        axis.set_xticks((0, 1), ["仅计算", "含 B 整理"])
        axis.set_ylabel("处理器周期")
        axis.set_title(" × ".join(map(str, shape)), loc="left", weight="bold")
        axis.set_axisbelow(True)
        axis.grid(axis="y", color="#E4E8EC", linewidth=.6)
        axis.spines[["top", "right"]].set_visible(False)
    handles, labels = axes[0].get_legend_handles_labels()
    fig.get_layout_engine().set(rect=(0, .12, 1, .88))
    fig.legend(handles, labels, loc="lower center", bbox_to_anchor=(.5, .04), ncol=2, frameon=False)
    fig.suptitle("通用矩阵接口：两种实现与两种计时范围", x=.02, ha="left", fontsize=16, weight="bold")
    fig.supxlabel("任务 3772882；每组 3 次；8 周期分辨率；三幅图使用各自的纵轴范围。", fontsize=9, y=.005)
    for suffix in ("png", "svg", "pdf"):
        fig.savefig(out / f"api_comparison.{suffix}", dpi=180, facecolor="white")
    plt.close(fig)


def load_throughput(comparison_path, speedup_path):
    with comparison_path.open(encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))
    with speedup_path.open(encoding="utf-8-sig", newline="") as handle:
        speeds = list(csv.DictReader(handle))
    result = {}
    for width in (1, 2, 4, 8, 16):
        vals = []
        for implementation in ("rvv", "vdot"):
            matches = [r for r in rows if r["mode"] == "independent" and int(r["width"]) == width and r["implementation"] == implementation]
            if len(matches) != 1 or matches[0]["status"] != "PASS":
                raise ValueError("Incomplete throughput comparison")
            vals.append(float(matches[0]["gross_cycles_per_dot"]))
        match = [r for r in speeds if r["mode"] == "independent" and int(r["width"]) == width]
        if len(match) != 1 or match[0]["status"] != "PASS":
            raise ValueError("Incomplete throughput ratio")
        ratio = float(match[0]["gross_speedup"])
        if abs(vals[0] / vals[1] - ratio) > 1e-10:
            raise ValueError("Throughput ratio disagrees with cycles")
        result[width] = (*vals, ratio)
    return result


def throughput_curve(values, out):
    widths = [1, 2, 4, 8, 16]
    xs = list(range(5))
    fig, axes = plt.subplots(1, 2, figsize=(11.6, 4.9), layout="constrained")
    for index, name, color in [(0, "标准 RVV", "#7E8B97"), (1, "自定义 vdot", "#21654B")]:
        vals = [values[w][index] for w in widths]
        axes[0].plot(xs, vals, marker="o", color=color, linewidth=2, label=name)
        for x, v in zip(xs, vals):
            axes[0].annotate(f"{v:.3f}", (x, v), xytext=(0, 7), textcoords="offset points", ha="center", fontsize=9)
    axes[0].set_ylim(0, 16)
    axes[0].set_ylabel("含循环开销的周期 / 点积")
    axes[0].legend(frameon=False)
    axes[0].set_title("每次点积的实际重复成本", loc="left", weight="bold")
    ratios = [values[w][2] for w in widths]
    axes[1].bar(xs, ratios, width=.52, color="#368AA3")
    axes[1].set_ylim(0, 11)
    axes[1].set_ylabel("标准 RVV 周期 / 自定义点积周期")
    axes[1].set_title("同一独立数量下的周期比", loc="left", weight="bold")
    for x, ratio in zip(xs, ratios):
        axes[1].text(x, ratio + .15, f"{ratio:.3f}×", ha="center", fontsize=10)
    for axis in axes:
        axis.set_xticks(xs, widths)
        axis.set_xlabel("每次循环中的独立点积数量")
        axis.set_axisbelow(True)
        axis.grid(axis="y", color="#E4E8EC", linewidth=.6)
        axis.spines[["top", "right"]].set_visible(False)
    fig.suptitle("独立点积数量比较：216 次完整处理器计时", x=.02, ha="left", fontsize=16, weight="bold")
    fig.supxlabel("任务 3772882；每程序 3 次；输入预先存入寄存器；图中使用包含循环控制的拟合斜率。", fontsize=9)
    for suffix in ("png", "svg", "pdf"):
        fig.savefig(out / f"throughput_curve.{suffix}", dpi=180, facecolor="white")
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--data", type=Path, default=ROOT / "applications/gemm/measured_20261021/gemm_cycles_speedup.csv")
    parser.add_argument("--api-data", type=Path, default=ROOT / "applications/gemm/measured_20261026/summary.csv")
    parser.add_argument("--throughput-data", type=Path, default=ROOT / "experiments/throughput/measured_20261026/analysis/comparison.csv")
    parser.add_argument("--speedup-data", type=Path, default=ROOT / "experiments/throughput/measured_20261026/analysis/speedup.csv")
    parser.add_argument("--include-reference-figures", action="store_true")
    parser.add_argument("--out", type=Path, default=Path(__file__).resolve().parent / "figures")
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    setup_font()
    api_comparison(load_api(args.api_data), args.out)
    throughput_curve(load_throughput(args.throughput_data, args.speedup_data), args.out)
    if args.include_reference_figures:
        comparison(load_rows(args.data), args.out)
        workflow(args.out)
    print(f"FIGURES_PASS images={4 if args.include_reference_figures else 2} formats=3")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
