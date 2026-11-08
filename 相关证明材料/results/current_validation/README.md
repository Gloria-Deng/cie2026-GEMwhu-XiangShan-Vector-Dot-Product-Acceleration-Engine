# current_validation

从武大超算取回的源码一致性检查及 NEMU 功能执行结果，用于核对随附源码、点积程序、矩阵程序和波形测试程序。

位置：`相关证明材料/results/current_validation/`。

下表列出本目录中的直接子项；子目录中的文件详见对应说明。

| 名称与相对位置 | 用途 |
| --- | --- |
| [current_source_check/](current_source_check/) | 核对随附 vdot 接入修改、测试输入与超算已完成构建所使用的源码；含检查表、状态及应用修改后的源码文件。 |
| [dot_functional/](dot_functional/) | 点积测量程序在 NEMU 中的功能执行结果，覆盖依赖链及不同并行宽度、不同实现和计算次数；含逐程序输出与 runs.csv。 |
| [gemm_functional/](gemm_functional/) | 矩阵测量程序在 NEMU 中的功能执行结果；含不同矩阵规模和实现的逐程序输出、检查表及 RVV 功能校验输出。 |
| [recovery_source_check/](recovery_source_check/) | 重新应用随附接入修改后，与超算已完成构建源码进行一致性核对；含应用过程输出、检查表及相关源码文件。 |
| [wave_functional/](wave_functional/) | 录波测试程序在 NEMU 中的功能执行结果、预期点积结果、指令地址与内存布局；用于与完整处理器波形逐项对应。 |
| [README.md](README.md) | 本目录文件位置与用途说明 |

点积和矩阵的处理器周期测量分别位于 `../../experiments/throughput/measured_20261103/` 与 `../../applications/gemm/measured_20261103/`。本目录功能执行输出中的指令次数用于辅助核对执行过程。
