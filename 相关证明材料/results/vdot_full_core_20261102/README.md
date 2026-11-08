# 整核 vdot 波形与逐条分析

武大超算任务 4127407 已成功完成，运行时间 6 分 55 秒，退出状态 0。处理器开启 DiffTest，达到设定的 30000 周期后停在程序预期地址 `0x80000330`；[平台任务状态](平台任务状态.txt)记录本次结果。

[vdot.fst](vdot.fst) 为本次生成的完整处理器波形，大小 179581698 字节。[逐条时刻表](checked_wave/vdot_executions.csv)由该波形重新分析，19 条目标指令全部通过检查。52 次分派尝试中有 33 次被冲刷取消。19 条运算均为 2 周期，相关序列接收间隔 7 周期、独立序列接收间隔 1 周期；实际输入点积与 128 位结果及写回一致。`checked_wave/vdot.gtkw` 用于查看波形。

`expected.csv`、`nemu.txt`、`emu.txt` 和 `vdot_wave.*` 是本次配套输入与执行结果，`mapping.csv` 为信号对应关系。可在“相关证明材料”目录执行 `python -B tools/check_vdot_wave.py --results results/vdot_full_core_20261102` 检查输出。
