# latency_replay

本目录记录对已完成的 348 次点积、72 次矩阵处理器输出的本机重算；相关表格分别放在 `optimized_dot` 和 `rvv_gemm`。

| 文件或目录 | 用途 |
| --- | --- |
| [optimized_dot/](optimized_dot/) | 点积程序的拟合、比较和倍率表。 |
| [rvv_gemm/](rvv_gemm/) | 矩阵程序各组周期统计及比较。 |
| [checks.csv](checks.csv) | 本目录对应的各项检查及完成状态。 |
| [optimized_dot.txt](optimized_dot.txt) | 点积测量重新计算的实际输出。 |
| [rvv_gemm.txt](rvv_gemm.txt) | 矩阵测量重新计算的实际输出。 |
| README.md | 本目录的文件位置和用途说明。 |
