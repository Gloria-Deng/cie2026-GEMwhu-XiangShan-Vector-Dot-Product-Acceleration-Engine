# 矩阵乘法程序与测量

[measured_20261103](measured_20261103/README.md) 保存 24 个程序各执行 3 次的香山测量，共 72 次均通过 DiffTest。[比较表](measured_20261103/checked_local/comparison.csv)覆盖三种矩阵规模及两种计时范围，六组比较均由标准 RVV 外积式取得最低周期。

32×32×32 仅计算分别为标准 RVV 外积 21480 周期、vdot 四列 21624 周期；含 B 准备分别为 22512 和 23032 周期。当前结果不支持声称 vdot 矩阵实现整体快于最佳标准 RVV 实现。

`src/` 存放实现，`include/` 存放接口，`baremetal/` 存放香山裸机程序；Python 文件用于准备和检查不同实现。测量程序、每次执行结果和统计表均在上述测量目录。

从“相关证明材料”目录执行 `python -B scripts/check_measurements.py --out <新的材料目录外路径>`，可重算点积和矩阵测量结果。

[check_measured.py](check_measured.py) 从本目录测量资料中重算 72 次矩阵执行结果，参数 `--out` 指定一个尚未存在且位于材料目录外的输出目录；可用 `--package` 指定测量资料目录。
