#!/usr/bin/env python3
"""Create the current figures from locally checked processor measurements."""
import csv
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.font_manager import FontProperties

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'performance/figures'
COLORS = ['#7E8B97', '#368AA3', '#B7791F', '#21654B']


def read(path):
    with path.open(encoding='utf-8-sig', newline='') as stream:
        return list(csv.DictReader(stream))


def save(fig, name):
    for suffix in ('png', 'svg', 'pdf'):
        fig.savefig(OUT / (name + '.' + suffix), dpi=180, facecolor='white')
    plt.close(fig)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for path in ('C:/Windows/Fonts/msyh.ttc', '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc'):
        if Path(path).is_file():
            matplotlib.font_manager.fontManager.addfont(path)
            plt.rcParams['font.family'] = FontProperties(fname=path).get_name()
            break
    plt.rcParams.update({'axes.unicode_minus': False, 'font.size': 11, 'svg.fonttype': 'none'})
    dot = read(ROOT / 'experiments/throughput/measured_20261103/checked_local/comparison.csv')
    if len(dot) != 23 or any(r['status'] != 'PASS' for r in dot):
        raise ValueError('current dot analysis is incomplete')
    fig, axis = plt.subplots(figsize=(10.5, 5.0), layout='constrained')
    for method, name, color in zip(('rvv', 'rvv_opt1', 'rvv_opt2', 'vdot'),
                                  ('原 RVV 组合', 'RVV 常驻零值', 'RVV 分批归约', 'vdot'), COLORS):
        rows = sorted((r for r in dot if r['mode'] == 'independent' and r['implementation'] == method),
                      key=lambda r: int(r['width']))
        axis.plot(range(5), [float(r['gross_cycles_per_dot']) for r in rows], marker='o', lw=2,
                  color=color, label=name)
    axis.set_xticks(range(5), [1, 2, 4, 8, 16])
    axis.set(xlabel='每次循环的独立点积数', ylabel='含循环开销的周期 / 点积', ylim=(0, 16))
    axis.legend(frameon=False)
    axis.grid(axis='y', color='#E4E8EC')
    axis.spines[['top', 'right']].set_visible(False)
    fig.suptitle('优化 RVV 对照：348 次香山 DiffTest 执行', x=.03, ha='left', weight='bold')
    fig.supxlabel('程序各三次；N=0/64/256/1024 拟合；输入常驻寄存器；16项时分批RVV / vdot = 3.760×。', fontsize=9)
    save(fig, 'current_dot_comparison')

    gemm = read(ROOT / 'applications/gemm/measured_20261103/checked_local/summary.csv')
    if len(gemm) != 24 or any(int(r['samples']) != 3 for r in gemm):
        raise ValueError('current GEMM analysis is incomplete')
    fig, axes = plt.subplots(2, 3, figsize=(13, 7.2), layout='constrained')
    labels = ['RVV点积', 'RVV外积', 'vdot直接', 'vdot四列']
    for i, scope in enumerate(('compute', 'pack_compute')):
        for j, size in enumerate(((3, 5, 13), (16, 16, 16), (32, 32, 32))):
            selected = sorted((r for r in gemm if tuple(int(r[k]) for k in ('M', 'N', 'K')) == size
                               and r['scope'] == scope), key=lambda r: int(r['method']))
            values = [float(r['median']) for r in selected]
            axis = axes[i, j]
            axis.bar(range(4), values, color=[COLORS[0], COLORS[1], COLORS[2], COLORS[3]])
            axis.set_xticks(range(4), labels, fontsize=9)
            axis.set_ylim(0, max(values) * 1.25)
            axis.set_title('×'.join(map(str, size)) + ('：仅计算' if i == 0 else '：含B准备'), loc='left')
            axis.set_ylabel('周期中位数')
            for x, value in enumerate(values):
                axis.text(x, value + max(values) * .025, f'{value:,.0f}', ha='center', fontsize=9)
            axis.spines[['top', 'right']].set_visible(False)
            axis.set_axisbelow(True)
            axis.grid(axis='y', color='#E4E8EC')
    fig.suptitle('标准 RVV 与 vdot 的矩阵应用比较：72 次执行', x=.03, ha='left', weight='bold')
    fig.supxlabel('每组重复三次；8周期分辨率；六组均由RVV外积式取得最低周期。不同方法的数据准备按各自布局计入。', fontsize=10)
    save(fig, 'current_gemm_comparison')

    wave = read(ROOT / 'results/vdot_full_core_20261102/checked_wave/vdot_executions.csv')
    if len(wave) != 19 or any(r['match'] != 'True' for r in wave):
        raise ValueError('full-core waveform analysis is incomplete')
    fig, axes = plt.subplots(1, 2, figsize=(11.6, 4.6))
    fig.subplots_adjust(left=.085, right=.965, top=.78, bottom=.24, wspace=.36)
    stages = [('issue_cycle', 'result_cycle', '乘法与归约', '#21654B'),
              ('result_cycle', 'writeback_cycle', '写回通路', '#368AA3'),
              ('writeback_cycle', 'commit_cycle', '等待提交', '#B7791F')]
    for axis, sequence, title in zip(axes, ('CHAIN', 'INDEPENDENT'), ('相关链：发射间隔7周期', '独立序列：发射间隔1周期')):
        selected = [r for r in wave if r['name'].startswith('VDOT_' + sequence)]
        origin = int(selected[0]['issue_cycle'])
        for i, row in enumerate(selected):
            for a, b, label, color in stages:
                axis.barh(i, int(row[b]) - int(row[a]), left=int(row[a]) - origin,
                          color=color, height=.5, label=label if i == 0 else None)
            axis.text(int(row['commit_cycle']) - origin + .15, i, str(row['commit_cycle']), va='center', fontsize=9)
        axis.set_yticks(range(4), [r['name'].replace('VDOT_', '') for r in selected])
        axis.invert_yaxis()
        axis.set_title(title, loc='left', weight='bold')
        axis.set_xlabel(f'相对处理器周期（起点C={origin}）；文字为提交周期')
        axis.spines[['top', 'right']].set_visible(False)
        axis.grid(axis='x', color='#E4E8EC')
        axis.set_axisbelow(True)
    handles, labels = axes[0].get_legend_handles_labels()
    fig.legend(handles, labels, frameon=False, fontsize=10, loc='upper left', bbox_to_anchor=(.075, .925), ncol=3)
    fig.suptitle('完整处理器波形：19条目标均为2周期运算延迟', x=.03, y=.985, ha='left', weight='bold')
    fig.supxlabel('只统计最终提交的执行；另有33次被冲刷取消的分派尝试。写回控制有效与寄存器内容更新分开解释。', fontsize=9)
    save(fig, 'current_vdot_pipeline')
    fig, axis = plt.subplots(figsize=(11.6, 2.5))
    axis.set(xlim=(0, 6), ylim=(0, 1)); axis.axis('off')
    stages = [
        ('重命名与派发', 'PC / ROB\n物理源与目的'),
        ('VFEX0 接收', 'in.valid\n且 in.ready'),
        ('VDotU 两级运算', '八路乘法与归约\n内部延迟 2 周期'),
        ('128 位结果', 'out.valid\n且 out.ready'),
        ('四分片写控制', '各 32 位\nwen / addr / data'),
        ('更新与提交', '物理寄存器更新\nROB 最终提交'),
    ]
    for i, (title, detail) in enumerate(stages):
        box = plt.Rectangle((i + .045, .22), .86, .57, facecolor='#E1ECE5', edgecolor='#B8CBBD', lw=1.0)
        axis.add_patch(box)
        axis.text(i + .475, .65, title, fontsize=11, ha='center', va='center', weight='bold', color='#183D35')
        axis.text(i + .475, .40, detail, fontsize=9, ha='center', va='center', linespacing=1.6, color='#183D35')
        if i < 5:
            axis.annotate('', xy=(i + 1.035, .50), xytext=(i + .91, .50), arrowprops=dict(arrowstyle='->', color='#B7791F', lw=1.7))
    fig.suptitle('整核 vdot 实际执行路径', x=.035, y=.98, ha='left', weight='bold')
    fig.text(.035, .05, '同一条指令以 PC、ROB 完整指针、物理寄存器与实际重定向记录关联；写控制有效和寄存器内容更新分开解释。', fontsize=9)
    fig.subplots_adjust(left=.02, right=.99, top=.83, bottom=.17)
    save(fig, 'current_vdot_path')
    print('CURRENT_FIGURES_PASS images=4 formats=3')


if __name__ == '__main__':
    main()
