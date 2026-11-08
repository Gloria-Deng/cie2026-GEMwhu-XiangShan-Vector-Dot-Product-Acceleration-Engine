# 三层 hello 环境输出

## 当前结果：2026-11-04

[超算三层输出](measured_20261102/README.md)已取回并重查，Linux/NEMU/emu全部通过，emu明确开启DiffTest。运行 `python -B stage1/check_measured_hello.py` 可离线复查。


2026-11-02 录波检查修正：`vdot_wave.sbatch` 调用 `tools/check_vdot_wave.py`，先清除终端颜色控制字符，再检查唯一停机地址、DiffTest 状态、执行错误和非空 FST。可用 `python3 tools/check_vdot_wave.py --results /path/to/existing/recording` 单独检查已有输出，无需重新运行处理器。此检查不替代逐条指令的波形时刻分析。

2026-11-02 修正：`build_nemu_uart.py` 在独立 NEMU 副本中关闭 VGA、键盘和音频，保留 UARTLite；同时将该固定版本的 SDL2 链接规则改为仅在上述设备启用时生效。UART hello 不需要 SDL2 开发文件。脚本会在编译前检查串口地址及设备配置，并保存 `uart_config.txt`。此调整不修改用于香山 DiffTest 的参考库或已完成的香山处理器。

`hello.py` 提供 Linux、NEMU、香山 emu 三个独立入口，`run_all_hello.sh` 依次尝试三层；任一层失败，总入口返回非零。每次使用新的日期目录。

从“相关证明材料”目录执行：

```bash
bash stage1/run_hello_linux.sh
python3 stage1/hello.py build
python3 stage1/build_nemu_uart.py --source /path/to/patched/NEMU --out /tmp/hello-nemu-20261029
bash stage1/run_hello_nemu.sh --nemu /path/to/riscv64-nemu-interpreter
bash stage1/run_hello_emu.sh --emu /path/to/XiangShan/build/emu --ref /path/to/riscv64-nemu-interpreter-so
```

交叉编译工具默认 `riscv64-unknown-elf-`，可用 `--prefix` 指定。NEMU 需要启用 UARTLite，地址 `0x40600000`，发送偏移 4；不能用关闭设备的参考库代替独立 NEMU。裸机文本的地址由执行主机在编译时写入；裸机没有网络协议栈，不会自行读取 IP。三层总入口编译一次，NEMU 和 emu 使用同一镜像。

超算 hello 脚本必须先设 `MATERIALS`、`EMU`、`NEMU`、`NEMU_REF`，再由用户提交 `sbatch stage1/hello_emu.sbatch`。脚本本身不提交任务。

`vdot_wave.sbatch` 是 T5 的整核录波入口，需要 `MATERIALS`、`EMU`、`NEMU_REF`、`NEMU_ROOT`；先执行 NEMU 功能检查，再录制整核 FST。
