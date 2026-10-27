# 点积功能与实际机器指令检查

当前功能检查已通过：48组定向输入在独立C、Python及两种RTL实现中结果一致；41种指定错误全部检出，28种双输入同步交换全部保持等价，共完成3,408次逐输入电路比较。939组基础输入继续由 `scripts/check_basic.py` 检查。

本次检查的全部230个输出文件已放入[final_check](final_check/)，可直接查看[总结果](final_check/summary.txt)、输入、各项电路输出、错误识别、等价交换、软件版本和实际反汇编。153个顶层文件为输入及结果，其余为配套编译产物。

从“相关证明材料”目录执行：

```powershell
python -X utf8 -B verification/check.py
```

不指定 `--out` 时，结果保存在系统临时目录。指定的位置必须不存在或为空，并且位于“相关证明材料”以外。需要 Python 3.10及更新版本、Icarus Verilog、vvp、宿主GCC和RISC-V GNU objdump。工具不在系统搜索位置时，可分别用 `--gcc`、`--iverilog`、`--vvp`、`--objdump` 指定完整位置。Windows程序会查找C、D、E盘的常见MSYS2与Icarus安装目录。

执行内容：

1. 使用独立编写的Python计算和C计算核对48组输入。每组输入均为两个16字节向量，仅低八个有符号字节参与点积。
2. 对随附手写RTL和Chisel生成RTL分别执行这48组输入，逐组比较完整128位输出，包括结果高96位清零。
3. 对手写RTL引入41种指定错误：八种遗漏有效位置、28种仅交换一个输入的两个位置、无符号乘法、18位累加、错误使用高八位置、高位脏值、负结果未正确扩展。每种修改至少必须被一个输入发现。
4. 对两个输入同时交换相同位置，穷举28种组合。纯点积对此保持不变，检查程序必须接受这些等价变换。
5. 执行13项机器指令读取检查，再读取随附的 `examples/minimal_vdot.elf`。检查程序通过机器编码识别自定义点积，不要求汇编工具认识其助记符，不依赖固定程序地址。

成功时末尾包含：

```text
POSITION_CHECK_PASS cases=48 implementations=2
REFERENCE_PAIR_PASS cases=48
ERROR_DETECTION_PASS variants=41
EQUIVALENCE_PASS variants=28
INSTRUCTION_READER_PASS cases=13 supplied_elf=1
RTL_COMPARISONS total=3408
```

输出目录包含：

| 文件 | 用途 |
| --- | --- |
| `summary.txt`、`summary.csv` | 各项结果与本次执行范围。 |
| `cases.csv`、`cases.txt` | 全部48组输入、分类、名称和完整输出。 |
| `error_detection.csv` | 每种错误修改被哪些输入发现，以及首个不同结果的位置。 |
| `equivalent_changes.csv` | 双输入同步交换的结果。 |
| `tools.csv`、`source_contents.csv` | 使用的软件版本与参与计算的源文件内容值。 |
| `minimal_vdot.dis` | 随附程序的实际反汇编。 |
| 其余 `.txt` 与 `build/` | 编译、执行原始输出与生成文件。 |

`coverage.csv` 对照原有检查和新增检查。源目的寄存器重合、非法元素宽度、非法寄存器分组、掩码、重启及`vill`依赖处理器状态；这些项目引用 `recorded/` 目录中的完整处理器结果汇总，已含三个重合程序和六个非法状态程序，不计入本目录的新增模块执行。重新运行这些程序按共用操作手册中的完整处理器步骤执行。

## 检查应用程序确实使用点积指令

```powershell
python -X utf8 -B verification/check_instructions.py examples/minimal_vdot.elf
```

默认要求至少包含一条当前编码的点积指令和向量配置指令。上述随附示例使用整寄存器存储写出结果，读取结果为点积1条、向量配置2条和整寄存器存储1条。需要把向量结果取出到整数寄存器的应用加 `--require-extract`，进一步检查 `vmv.x.s`。若预期点积指令的静态数量固定，使用 `--expected-vdot <数量>` 精确检查。向量配置或点积指令缺失、错误编码、数量不符、指定的结果取出方式缺失都会返回失败。

同一工具可由其他程序导入：

```python
from verification.check_instructions import inspect_elf

result = inspect_elf("examples/minimal_vdot.elf", minimum_vdot=1)
```

`result['counts']` 返回点积、向量配置、结果取出和整寄存器存储的静态数量；`result['vdot_destinations']` 返回点积目标寄存器编号。它用于检查编译后的实现选择，不提供动态指令次数或处理器周期。
