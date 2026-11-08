# wave_functional

本目录功能的配套文件。

位置：`相关证明材料/results/current_validation/wave_functional/`。

下表列出本目录中的直接子项；子目录中的文件详见对应说明。

| 名称与相对位置 | 用途 |
| --- | --- |
| [cosim_layout.h](cosim_layout.h) | C 接口或参数定义，用于本目录对应功能 |
| [expected.csv](expected.csv) | 程序预期的计算结果 |
| [layout.txt](layout.txt) | 裸机程序运行所需内存位置 |
| [nemu.txt](nemu.txt) | NEMU 的实际执行输出 |
| [read_layout](read_layout) | 读取裸机共享内存位置的辅助程序 |
| [README.md](README.md) | 本目录文件位置与用途说明 |
| [run_image](run_image) | 在 NEMU 环境加载裸机镜像的辅助程序 |
| [run_image.c](run_image.c) | C 程序实现，用于本目录对应功能 |
| [symbols.txt](symbols.txt) | 程序符号与地址对应表 |
| [vdot_wave.bin](vdot_wave.bin) | 同名程序的裸机二进制镜像 |
| [vdot_wave.dis](vdot_wave.dis) | 同名程序的反汇编文本，用于检查实际指令 |
| [vdot_wave.elf](vdot_wave.elf) | 同名程序的 ELF 可执行文件 |
| [vdot_wave.o](vdot_wave.o) | 同名程序的编译目标文件 |
