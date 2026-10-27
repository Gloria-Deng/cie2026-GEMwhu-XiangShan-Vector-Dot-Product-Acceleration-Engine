# 独立点积数量比较

本目录提供 1、2、4、8、16 个独立点积的完整程序、同条件标准 RVV 程序、空循环和依赖链参照。默认循环次数为 0、64、256、1024，共 72 个程序。每个目标寄存器都比较完整 128 位；零次循环比较初始值。

2026 年 10 月 26 日，超算任务 3772882 已完成全部 216 次香山处理器计时，72 个程序各重复三次，全部成功。完整结果与文件说明见 [measured_20261026](measured_20261026/README.md)，实际曲线见[独立点积数量图](../../performance/figures/throughput_curve.png)。

## 已有计时结果

下表使用包含循环开销的周期/点积，周期比为同条件标准 RVV 除以自定义点积。输入预先保存在寄存器中重复计算。

| 独立点积数 | 标准 RVV 周期/点积 | 自定义点积周期/点积 | 周期比 |
| ---: | ---: | ---: | ---: |
| 1 | 14.004032 | 1.528226 | 9.163588 |
| 2 | 7.497984 | 1.179435 | 6.357265 |
| 4 | 5.089718 | 1.256048 | 4.052167 |
| 8 | 5.128024 | 1.044859 | 4.907863 |
| 16 | 5.022429 | 1.064012 | 4.720275 |

依赖链参照为标准 RVV 20.991935、自定义点积 7.008065 周期/点积，周期比为 2.995397。本批独立数量为 8 时的自定义点积含循环读数最低；增加到 16 后有小幅回升，具体原因还需额外的处理器内部统计才能判断。

核对随附结果时不需要编译工具，也不会启动处理器执行：

```powershell
$ResultCheck = Join-Path $env:TEMP ("vdot-throughput-results-" + [guid]::NewGuid().ToString("N"))
python -B experiments/throughput/check_measured.py --out $ResultCheck
```

成功输出为 `THROUGHPUT_MEASURED_SUMMARY_PASS records=216 programs=72 repeats=3 fits=18 comparisons=12 raw_outputs_reopened=0`。该命令在本地检查逐次表、程序清单、终止位置与已保存的完成记录，并从逐次表重算拟合和比较。216份完整原始执行输出现已取回，见[本地独立点积输出](../../measurements/20261026/raw/throughput_measurements/)；此复算命令仍仅读取结果表，不重复读取原始正文。本次正文复查结果见[逐项结果](../../../材料核对/原始输出复查.csv)。

## 本地检查

从“相关证明材料”目录执行，输出位置必须尚不存在：

```powershell
$ProgramCheck = Join-Path $env:TEMP ("vdot-throughput-programs-" + [guid]::NewGuid().ToString("N"))
python -B experiments/throughput/check.py --out $ProgramCheck
```

成功输出以 `THROUGHPUT_LOCAL_PASS programs=72` 开头，并报告 `saved_measurements=PASS saved_records=216`。程序检查独立的期望计算、全部 72 个程序的交叉编译、编译后的指令、错误终止处理、数据分析和已完成的216次计时。若本机有参考库，还会重新编译与其源码对应的执行器，执行 72 个程序，并确认“遗漏第一个目标”和“只有最高字节错误”都会被拒绝。

Windows 会寻找已有的 MSYS2 编译工具；也可以用 `--prefix` 指定，例如 `--prefix E:/msys64/ucrt64/bin/riscv64-unknown-elf-`。Linux 使用系统中的同名工具。

参考库优先读取环境变量 `VDOT_NEMU_LIBRARY`，其次查找 `sources/NEMU/build/`。当前本机也支持寻找同级研发目录中已有的参考库。源码必须与库对应，并且已经生成 `include/generated/autoconf.h`。本机执行器使用该文件生成内存布局，初始化前将模拟内存设为 128 MiB，并核对导出状态长度。检查表分别列出编译、参考执行和已有计时重算的结果。

已有执行器时，可明确指定：

```text
python experiments/throughput/check.py --out 新检查目录 --runner 参考执行器 --library NEMU共享库
```

需要自己生成执行器时：

```text
python experiments/throughput/build_reference.py --nemu-source 当前NEMU源码目录 --out 新执行器目录
```

## 重新进行完整处理器测量

先生成程序，然后计算允许的用时：

```text
python experiments/throughput/study.py generate --out 新程序目录
python experiments/throughput/study.py estimate --programs 新程序目录 --repeat 3 --workers 16 --cycle-limit 250000 --seconds-limit 7200
```

默认共 216 次执行。本次两项计时合用的任务实际用时为 9 小时 51 分 48 秒，其中独立点积执行阶段约 8 小时 38 分钟。重新测量时，可向资源估算命令提供实际机器的执行速度：`--cycles-per-second 数值`。

本次独立点积执行的进程中位速度约为每秒 112.35 个模拟周期，250,000 周期需要约 37 分钟。并行数量支持 1 至 16，但须先确认模拟程序线程数及分配到的处理器数量；本次使用的模拟程序为单线程。每完成一次执行即更新 `runs.csv`，中途停止时也保留已完成的数据。

已经具有匹配的香山 `emu` 与 NEMU 库，并完成资源安排后，在实际运行机器上执行：

```text
python experiments/throughput/study.py execute --programs 新程序目录 --emu 香山emu完整路径 --library NEMU共享库完整路径 --out 新测量目录 --repeat 3 --workers 16 --cycle-limit 250000 --seconds-limit 7200
```

程序为每项测试独立启动处理器，重复批次交替正序和倒序执行。`submission_order.csv` 保存提交顺序，`actual_order.csv` 保存实际开始时间；多个程序同时执行时，以后者判断开始先后。失败会保留原始输出，并返回失败，不会改变参数或自动重试。单个程序使用“计算结果全部正确之后才能进入”的计时终点编码周期，每个编码单位为 8 周期。

以下重新分析命令用于保有原始输出的完整测量目录。本地紧凑结果包使用前述 `check_measured.py`，不需要取回全部原始输出。

```text
python experiments/throughput/study.py analyze --results 已完成测量目录 --out 新分析目录
```

## 计算约定

输入一次加载到 `v30` 和 `v31`，每次点积只使用低八个有符号字节。高八个字节特意设为非零，计算结果仍必须是低 32 位点积、其余 96 位为零。独立程序使用 `v0` 至 `v15` 中所需的目标，每个目标先装入不同的非零初值。标准 RVV 使用 `v16/v17` 作乘积暂存，不与输入和目标重叠。

标准 RVV 每个点积执行宽乘、切换至 16 位、将整个目标清零、宽归约、恢复 8 位配置，共五条指令。所有方法使用相同输入、相同独立数量和相同循环控制。依赖程序把 `v30` 同时作为源和目标，让上次结果直接供下次计算使用，不额外插入复制。

计时包含循环、计算、完成后的结果存储和完整结果比较；输入准备在计时之前。完成处理的固定成本随独立数量变化，但在同组循环次数变化时保持相同，分析使用周期随循环次数变化的斜率。此处没有每次点积重新加载输入，结果描述的是寄存器内重复计算。

输出同时保留：

| 输出 | 含义 |
| --- | --- |
| `fits.csv` | 各方法的斜率、截距、拟合程度、最大偏差与计时精度影响 |
| `comparison.csv` | 包含循环开销的周期/点积，以及扣除对应空循环后的估计 |
| `speedup.csv` | 同条件标准 RVV 与自定义点积的比值，两种计时口径分别报告 |
| `report.md` | 方便阅读的比较表 |

扣除空循环后的数值只用于估算控制开销；乱序执行可能使计算与循环控制重叠，因此该数值不代表纯电路延迟。各组具有相同的全部循环次数，包含零次，并已完成计划中的三次重复。本批18组拟合均达到至少0.99的拟合程度，斜率大于计时精度影响，12组周期比较与6组倍率全部通过既定条件。

## 文件

| 文件 | 用途 |
| --- | --- |
| `study.py` | 程序生成、功能执行、完整处理器执行、资源估算与结果重算 |
| `check.py` | 本机可执行检查与错误处理检查 |
| `check_measured.py` | 随附已完成计时的本地汇总核对，不启动执行 |
| `build_reference.py` | 按实际 NEMU 配置编译参考执行器 |
| `reference_runner.c` | 执行程序并检查成功或失败终点 |
| `measured_20261026/` | 当前216次香山计时、分析表、程序清单、状态及远端完成记录 |

方法参考：[公开项目的独立数量比较](https://github.com/vienna-0FFH/cie2026-shishui-vdot/blob/main/vdot/docs/throughput-width-sweep.md)。本目录的程序独立编写，指令计算约定沿用当前提交工程。
