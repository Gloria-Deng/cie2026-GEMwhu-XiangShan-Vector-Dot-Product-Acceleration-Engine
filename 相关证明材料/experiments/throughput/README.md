# 点积性能测量与程序

当前点积测量位于 [measured_20261103](measured_20261103/README.md)：116 个程序各执行 3 次，348 次均通过香山 DiffTest。输入常驻寄存器的 16 项独立点积中，标准 RVV 为 4.001008 周期/点积，vdot 为 1.064012 周期/点积，周期比为 3.760303。依赖链对应 20.991935 与 7.008065 周期/点积，周期比为 2.995397。这些结果不能直接代表矩阵或大语言模型的整体性能。

[比较表](measured_20261103/checked_local/comparison.csv) 和 [倍率表](measured_20261103/checked_local/optimized_speedup.csv)由各次执行结果计算。该目录还包括测量程序、三次执行结果与生成程序；本目录的 Python 文件和提交脚本用于准备、执行与检查测量。

从“相关证明材料”目录执行 `python -B scripts/check_measurements.py --out <新的材料目录外路径>`，可重算点积和矩阵测量结果。

[check_measured.py](check_measured.py) 从本目录测量资料中重算 348 次点积执行结果，参数 `--out` 指定一个尚未存在且位于材料目录外的输出目录；可用 `--package` 指定测量资料目录。
