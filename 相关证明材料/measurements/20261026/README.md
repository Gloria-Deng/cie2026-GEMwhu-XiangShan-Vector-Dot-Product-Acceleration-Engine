# 2026年10月26日处理器测量完成记录

任务3772882已完成，退出状态0:0。通用矩阵接口36次、独立点积数量比较216次，共252次均通过；84个程序各有三次成功执行。

| 项目 | 记录 |
| --- | --- |
| 开始 | 2026-10-25 21:04:41，北京时间 |
| 结束 | 2026-10-26 06:56:29，北京时间 |
| 节点与分配 | n0373，16核，90,000 MB内存申请 |
| 用时 | 9小时51分48秒 |
| 按分配资源计算 | 157.81核时，35,508秒×16÷3,600 |
| 进程处理器时间 | 144.96小时；与分配资源分列，不重复加计batch和extern |
| 执行方式 | 最多16个进程并发，每个处理器模拟程序单线程 |

具体结果与复算：

- [通用矩阵接口36次](../../applications/gemm/measured_20261026/README.md)
- [独立点积216次](../../experiments/throughput/measured_20261026/README.md)
- [结果图与范围说明](../../performance/README.md)

从工程根目录执行 `python -B scripts/check_measurements.py --out ../measured-check-new`，只重算随附结果，不启动处理器。

本目录的`status.txt`、`allocation.txt`、`task_status.csv`、`finished_utc.txt`保存实际任务记录。`inputs.csv`保存执行输入的内容清单。`completion_checks.csv`是已取回的远端完成核对记录，共511项通过；其中504项分别核对252份输出的内容和周期，另外7项核对来源及完整性。

完整原始输出已于2026年10月26日从超算取回。本地共有267个文件、1,154,357,269字节，包含36次矩阵和216次独立点积的全部252份执行正文，以及原目录的结果表和分析文件。

| 本地位置 | 内容 |
| --- | --- |
| [raw/api_measurements](raw/api_measurements/) | 矩阵接口的完整执行正文、逐次表和分析文件。 |
| [raw/throughput_measurements](raw/throughput_measurements/) | 独立点积的完整执行正文、逐次表和分析文件。 |
| [remote_outputs.tar.gz](remote_outputs.tar.gz) | 从超算直接传回的完整压缩文件，34,480,876字节。 |
| [取回清单](../../../材料核对/超算文件取回清单.csv) | 267个文件的原位置、当前位置、大小与内容核对结果。 |
| [执行输出复查](../../../材料核对/原始输出复查.csv) | 252份执行正文与程序结束位置、周期的逐项复查。 |

252份正文的内容均与原测量表一致。原保存位置为超算 `/project/chensiyuan/vdot/new_measurements_20261025_2100/` 下的 `api_measurements/` 和 `throughput_measurements/`。本次取回已有文件，没有启动新的处理器计算。
