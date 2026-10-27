# INT8 通用矩阵乘法接口

当前接口在任务 3772882 中完成 36 次香山处理器测量。12 个程序各重复三次，全部通过；三个尺寸为 3×5×13、16×16×16、32×32×32，读数单位为 8 周期。以下命令均从“相关证明材料”目录执行。

## 当前文件

| 入口 | 用途 |
| --- | --- |
| [调用接口](include/vdot_gemm.h)、[实现代码](src/vdot_gemm.c) | 直接取回、四列共享加载与向量累加；处理 K 和输出列的尾部。 |
| [处理器计时工具](api_benchmark.py) | 生成和编译 12 个通用接口程序，执行功能检查、计时及统计。 |
| [测量复算工具](check_measured.py) | 在本地复算已有 36 次记录和 12 组统计，并核对实际程序与当前实现。 |
| [本次测量说明](measured_20261026/README.md) | 当前周期、方法比较、计时范围和任务位置。 |
| [逐次结果](measured_20261026/measurements.csv)、[分组统计](measured_20261026/summary.csv) | 每个程序的三次成功读数，以及最小值、中位数、最大值。 |
| [方法比较](measured_20261026/method_comparison.csv) | 直接取回与四列方法的周期比和周期变化。 |
| [实际程序清单](measured_20261026/programs/compiled.csv) | 三个尺寸、两种方法、两种计时范围及对应程序。 |

## 当前结果

| M×N×K | 仅计算：直接取回 | 仅计算：四列方法 | 含 B 整理：直接取回 | 含 B 整理：四列方法 |
| --- | ---: | ---: | ---: | ---: |
| 3×5×13 | 760 | 984 | 1,208 | 1,416 |
| 16×16×16 | 3,832 | 3,704 | 4,480 | 4,296 |
| 32×32×32 | 30,448 | 21,624 | 31,984 | 23,032 |

全部 12 组的三次读数一致。表中 C 表示实际整数周期位于 C 至 C+7。32³ 的四列方法相对直接取回，仅计算周期减少约 28.98%，含 B 整理时减少约 27.99%；16³ 分别减少约 3.34%、4.11%；3×5×13 分别增加约 29.47%、17.22%。方法选择应结合矩阵尺寸。

`compute` 在计时前整理 B，`pack_compute` 将整理 B 计入。两种范围都包括接口检查、矩阵计算、C 写出及计时边界的内存顺序控制；输入准备、逐元素结果检查、程序启动及结束等待在计时区间外。两种范围由独立程序测量，分别比较直接取回和四列方法。

## 本地复算

需要 Python 3.10 或更新版本。指定一个尚不存在的输出目录：

```powershell
python -B applications/gemm/check_measured.py --out ../../gemm_measured_check_01
```

成功时退出码为 0，并打印 `MEASURED_GEMM_PASS programs=12 executions=36 groups=12 original_outputs_read_locally=0`。输出目录包含 `summary.csv`、`method_comparison.csv`、`source_correspondence.csv`、`checks.csv` 和 `report.md`。

该命令读取本地已有材料完成复算。完整原始执行文本现已取回，保存在[本地矩阵执行输出](../../measurements/20261026/raw/api_measurements/)；对应结果表和当时的完成检查也一并提供。

## 调用与数据布局

接口计算 `C[M][N] = A[M][K] × B[K][N]`。A、B、C 按行连续保存；B 的各列先整理为连续存储，每列长度补齐到 8 的倍数，补入字节为零。

```c
size_t bytes = vdot_gemm_pack_bytes(N, K);
int status = vdot_gemm_pack_b(B, N, K, packed_B, bytes);
if (status == 0)
    status = vdot_gemm_packed(A, packed_B, C, M, N, K, VDOT_GEMM_UNROLL4);
```

调用者提供至少 `M*K` 个字节的 A、`K*N` 个字节的 B、`bytes` 个字节的 packed_B，以及 `M*N` 个 int32 输出。输入、整理后的 B 与输出空间互不重叠。尺寸乘法溢出、无效指针和未知方法返回 `-1`；B 空间不足返回 `-2`。K 为零时输出全零，M 或 N 为零时不访问矩阵。

K 不是 8 的倍数时，A 的最后一段复制到八字节局部空间并补零；N 不是 4 的倍数时，剩余列逐列计算。跨块累加按 32 位回绕处理。

`VDOT_GEMM_MOVX` 每段用 `vmv.x.s` 取出结果；`VDOT_GEMM_UNROLL4` 每四列共享 A 的加载，在向量寄存器中分别累加，每列取出一次结果。普通编译采用 C 参考计算，`vdot_gemm_backend()` 返回 `C_REFERENCE`；RISC-V 编译时定义 `VDOT_GEMM_ASM`，实际执行自定义指令并返回 `CUSTOM_VDOT`。

## 生成与功能执行

以下命令用于已配置 RISC-V GCC、香山模拟程序及对应 NEMU 参考库的 Linux 环境。`NEMU_HOME` 指向对应 NEMU 源码目录，`NOOP_HOME` 指向香山源码目录。先按共用操作手册完成环境设置，并选择新的输出目录。

```bash
python3 -B experiments/throughput/build_reference.py \
  --nemu-source "$NEMU_HOME" --out ../../gemm_reference_01

python3 -B applications/gemm/api_benchmark.py generate \
  --out ../../gemm_api_programs_01

python3 -B applications/gemm/api_benchmark.py functional \
  --programs ../../gemm_api_programs_01 \
  --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --runner ../../gemm_reference_01/reference_runner \
  --out ../../gemm_api_functional_01
```

`generate` 完成 12 个程序的输入生成、交叉编译和指令检查；RISC-V 工具不在搜索路径时，用其 `--prefix` 参数指定工具前缀。`functional` 成功时打印 `API_FUNCTIONAL_PASS count=12`，结果保存于所选输出目录的 `checks.csv`。

## 处理器计时与统计

在已分配 16 核的 Linux 环境中，使用前述已检查程序：

```bash
python3 -B applications/gemm/api_benchmark.py execute \
  --programs ../../gemm_api_programs_01 \
  --emu "$NOOP_HOME/build/emu" \
  --library "$NEMU_HOME/build/riscv64-nemu-interpreter-so" \
  --out ../../gemm_api_results_01 \
  --repeat 3 --workers 16 --seconds-limit 7200
```

执行完成时退出码为 0；`measurements.csv` 包含 36 次成功记录，`analysis/summary.csv` 包含 12 组各三次成功的统计。每个进程分别启动模拟程序；三次重复按正序、倒序、正序安排提交，最多 16 个进程并发。每个程序在完整检查输出矩阵后，到达编码测量周期的结束位置。

只对已有结果重新生成统计：

```bash
python3 -B applications/gemm/api_benchmark.py analyze \
  --results ../../gemm_api_results_01 \
  --out ../../gemm_api_analysis_01 --repeat 3
```

当前已完成任务的数据、源码对应及原始输出保存位置见[本次测量说明](measured_20261026/README.md)。
