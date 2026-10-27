# 216次独立点积与依赖链计时

任务 3772882 于北京时间 2026 年 10 月 26 日完成。独立点积数量为 1、2、4、8、16，另有依赖链参照；每组包含自定义点积、标准 RVV 和空循环，循环次数为 0、64、256、1024。共 72 个程序，每个重复三次，216 次全部成功。

## 当前结果

以下周期/点积来自周期随循环次数变化的拟合斜率，包含循环开销。比值为同条件标准 RVV 除以自定义点积。

| 独立点积数 | 标准 RVV 周期/点积 | 自定义点积周期/点积 | 周期比 |
| ---: | ---: | ---: | ---: |
| 1 | 14.004032 | 1.528226 | 9.163588 |
| 2 | 7.497984 | 1.179435 | 6.357265 |
| 4 | 5.089718 | 1.256048 | 4.052167 |
| 8 | 5.128024 | 1.044859 | 4.907863 |
| 16 | 5.022429 | 1.064012 | 4.720275 |

依赖链参照为标准 RVV **20.991935**、自定义点积 **7.008065** 周期/点积，周期比 **2.995397**。独立数量为 8 时，本批自定义点积的含循环周期最低；16 个时略有回升。该现象本身不能说明回升来自哪一个处理器内部部件。

三次重复中，72 个程序各自解出的周期区间下界均相同，最小值、中位数和最大值一致。每个周期区间宽 8 周期，因此相同下界只说明三次落在同一区间，不能证明真实周期完全相同。18 组拟合、12 组周期比较和 6 组倍率均满足事先采用的条件。

扣除空循环后的估计另见 [comparison.csv](analysis/comparison.csv)。扣除后，独立数量为 1 的自定义点积估计为 0.5 周期/点积，受到循环控制与计算可能重叠的影响；正文以包含循环开销的结果为主，不把扣除后的数值称为纯电路延迟。

## 本地核对

从“相关证明材料”目录执行：

```powershell
$ResultCheck = Join-Path $env:TEMP ("vdot-throughput-results-" + [guid]::NewGuid().ToString("N"))
python -B experiments/throughput/check_measured.py --out $ResultCheck
```

该命令读取随附逐次表和程序清单，确认 216 条记录对应 72 个程序各三次，循环次数与目标寄存器说明完整，终止位置可以解出表内周期，并从逐次表重算拟合及比值。然后把重算值与本目录 `analysis/` 中的原件逐项比较。成功输出为 `THROUGHPUT_MEASURED_SUMMARY_PASS`，同时明确 `raw_outputs_reopened=0`。

## 文件与来源

| 文件 | 内容 |
| --- | --- |
| [runs.csv](runs.csv) | 216 次处理器执行的逐次记录；周期是 8 周期区间的下界 |
| [programs.csv](programs.csv) | 72 个程序、完整目标寄存器期望值、成功或失败位置、计时编码范围 |
| [study_parameters.csv](study_parameters.csv) | 生成时的独立数量、循环次数和程序清单内容值 |
| [measurement_info.csv](measurement_info.csv) | 本批任务、重复数、并行数量、执行上限及原始输出位置 |
| [analysis/fits.csv](analysis/fits.csv) | 18 组拟合的斜率、截距、拟合程度及误差说明 |
| [analysis/comparison.csv](analysis/comparison.csv) | 包含循环与扣除空循环后的两类周期/点积 |
| [analysis/speedup.csv](analysis/speedup.csv) | 6 组周期比，两种计时口径分别列出 |
| [execution_inputs.csv](execution_inputs.csv) | 任务执行时保存的输入文件内容值；包含本批共同使用的两项实验 |
| [remote_checks/completion_checks.csv](remote_checks/completion_checks.csv) | 已在超算完成的原始输出核对记录；其中独立点积每次具有输出检查和结果检查两项 |
| [remote_checks/status.txt](remote_checks/status.txt) | 任务完成、退出状态和结束输出 |
| [remote_checks/allocation_at_start.txt](remote_checks/allocation_at_start.txt) | 启动时的资源安排说明；当前结束状态以 `status.txt` 为准 |
| [files.csv](files.csv) | 随附原件与本地取回位置、内容值的对应表 |

逐次表和分析表来自超算目录：

```text
/project/chensiyuan/vdot/new_measurements_20261025_2100/throughput_measurements/
```

216 份原始处理器执行输出保存在该目录，任务完成后已由远端核对程序逐项检查。随附的完成记录确认全部输出与逐次表一致。本地结果核对命令读取随附表格与完成记录，并重新计算拟合及周期比。

## 适用范围

本批使用固定八个有符号 INT8 的点积约定，`SEW=e8`、`LMUL=m1`、`VL=8`，输入预先装入寄存器。计时包含循环、计算、完成后的结果存储和完整结果比较；准备输入在计时之前，固定完成成本由斜率分析处理。

这些结果说明寄存器内重复点积在所测独立数量下的性能。每次重新装载输入的应用成本、其他元素宽度、其他向量配置、超过16个独立点积及实际芯片性能不在本批测量范围内。
