# programs

可在处理器环境执行的测试程序。

位置：`相关证明材料/applications/gemm/measured_20261103/programs/`。

下表列出本目录中的直接子项；子目录中的文件详见对应说明。

| 名称与相对位置 | 用途 |
| --- | --- |
| [validation/](validation/) | 矩阵功能校验程序 |
| [compiled.csv](compiled.csv) | 程序编译完成情况及产物位置 |
| [programs.csv](programs.csv) | 测量程序配置与对应文件列表 |
| [README.md](README.md) | 本目录文件位置与用途说明 |
| [t4_16x16x16_rvv_dot_compute.asm](t4_16x16x16_rvv_dot_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_16x16x16_rvv_dot_compute.bin](t4_16x16x16_rvv_dot_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_16x16x16_rvv_dot_compute.c](t4_16x16x16_rvv_dot_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_16x16x16_rvv_dot_compute.elf](t4_16x16x16_rvv_dot_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_16x16x16_rvv_dot_pack_compute.asm](t4_16x16x16_rvv_dot_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_16x16x16_rvv_dot_pack_compute.bin](t4_16x16x16_rvv_dot_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_16x16x16_rvv_dot_pack_compute.c](t4_16x16x16_rvv_dot_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_16x16x16_rvv_dot_pack_compute.elf](t4_16x16x16_rvv_dot_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_16x16x16_rvv_outer_compute.asm](t4_16x16x16_rvv_outer_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_16x16x16_rvv_outer_compute.bin](t4_16x16x16_rvv_outer_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_16x16x16_rvv_outer_compute.c](t4_16x16x16_rvv_outer_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_16x16x16_rvv_outer_compute.elf](t4_16x16x16_rvv_outer_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_16x16x16_rvv_outer_pack_compute.asm](t4_16x16x16_rvv_outer_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_16x16x16_rvv_outer_pack_compute.bin](t4_16x16x16_rvv_outer_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_16x16x16_rvv_outer_pack_compute.c](t4_16x16x16_rvv_outer_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_16x16x16_rvv_outer_pack_compute.elf](t4_16x16x16_rvv_outer_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_16x16x16_vdot_movx_compute.asm](t4_16x16x16_vdot_movx_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_16x16x16_vdot_movx_compute.bin](t4_16x16x16_vdot_movx_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_16x16x16_vdot_movx_compute.c](t4_16x16x16_vdot_movx_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_16x16x16_vdot_movx_compute.elf](t4_16x16x16_vdot_movx_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_16x16x16_vdot_movx_pack_compute.asm](t4_16x16x16_vdot_movx_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_16x16x16_vdot_movx_pack_compute.bin](t4_16x16x16_vdot_movx_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_16x16x16_vdot_movx_pack_compute.c](t4_16x16x16_vdot_movx_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_16x16x16_vdot_movx_pack_compute.elf](t4_16x16x16_vdot_movx_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_16x16x16_vdot_unroll4_compute.asm](t4_16x16x16_vdot_unroll4_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_16x16x16_vdot_unroll4_compute.bin](t4_16x16x16_vdot_unroll4_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_16x16x16_vdot_unroll4_compute.c](t4_16x16x16_vdot_unroll4_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_16x16x16_vdot_unroll4_compute.elf](t4_16x16x16_vdot_unroll4_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_16x16x16_vdot_unroll4_pack_compute.asm](t4_16x16x16_vdot_unroll4_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_16x16x16_vdot_unroll4_pack_compute.bin](t4_16x16x16_vdot_unroll4_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_16x16x16_vdot_unroll4_pack_compute.c](t4_16x16x16_vdot_unroll4_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_16x16x16_vdot_unroll4_pack_compute.elf](t4_16x16x16_vdot_unroll4_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_32x32x32_rvv_dot_compute.asm](t4_32x32x32_rvv_dot_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_32x32x32_rvv_dot_compute.bin](t4_32x32x32_rvv_dot_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_32x32x32_rvv_dot_compute.c](t4_32x32x32_rvv_dot_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_32x32x32_rvv_dot_compute.elf](t4_32x32x32_rvv_dot_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_32x32x32_rvv_dot_pack_compute.asm](t4_32x32x32_rvv_dot_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_32x32x32_rvv_dot_pack_compute.bin](t4_32x32x32_rvv_dot_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_32x32x32_rvv_dot_pack_compute.c](t4_32x32x32_rvv_dot_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_32x32x32_rvv_dot_pack_compute.elf](t4_32x32x32_rvv_dot_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_32x32x32_rvv_outer_compute.asm](t4_32x32x32_rvv_outer_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_32x32x32_rvv_outer_compute.bin](t4_32x32x32_rvv_outer_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_32x32x32_rvv_outer_compute.c](t4_32x32x32_rvv_outer_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_32x32x32_rvv_outer_compute.elf](t4_32x32x32_rvv_outer_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_32x32x32_rvv_outer_pack_compute.asm](t4_32x32x32_rvv_outer_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_32x32x32_rvv_outer_pack_compute.bin](t4_32x32x32_rvv_outer_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_32x32x32_rvv_outer_pack_compute.c](t4_32x32x32_rvv_outer_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_32x32x32_rvv_outer_pack_compute.elf](t4_32x32x32_rvv_outer_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_32x32x32_vdot_movx_compute.asm](t4_32x32x32_vdot_movx_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_32x32x32_vdot_movx_compute.bin](t4_32x32x32_vdot_movx_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_32x32x32_vdot_movx_compute.c](t4_32x32x32_vdot_movx_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_32x32x32_vdot_movx_compute.elf](t4_32x32x32_vdot_movx_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_32x32x32_vdot_movx_pack_compute.asm](t4_32x32x32_vdot_movx_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_32x32x32_vdot_movx_pack_compute.bin](t4_32x32x32_vdot_movx_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_32x32x32_vdot_movx_pack_compute.c](t4_32x32x32_vdot_movx_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_32x32x32_vdot_movx_pack_compute.elf](t4_32x32x32_vdot_movx_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_32x32x32_vdot_unroll4_compute.asm](t4_32x32x32_vdot_unroll4_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_32x32x32_vdot_unroll4_compute.bin](t4_32x32x32_vdot_unroll4_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_32x32x32_vdot_unroll4_compute.c](t4_32x32x32_vdot_unroll4_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_32x32x32_vdot_unroll4_compute.elf](t4_32x32x32_vdot_unroll4_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_32x32x32_vdot_unroll4_pack_compute.asm](t4_32x32x32_vdot_unroll4_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_32x32x32_vdot_unroll4_pack_compute.bin](t4_32x32x32_vdot_unroll4_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_32x32x32_vdot_unroll4_pack_compute.c](t4_32x32x32_vdot_unroll4_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_32x32x32_vdot_unroll4_pack_compute.elf](t4_32x32x32_vdot_unroll4_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_3x5x13_rvv_dot_compute.asm](t4_3x5x13_rvv_dot_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_3x5x13_rvv_dot_compute.bin](t4_3x5x13_rvv_dot_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_3x5x13_rvv_dot_compute.c](t4_3x5x13_rvv_dot_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_3x5x13_rvv_dot_compute.elf](t4_3x5x13_rvv_dot_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_3x5x13_rvv_dot_pack_compute.asm](t4_3x5x13_rvv_dot_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_3x5x13_rvv_dot_pack_compute.bin](t4_3x5x13_rvv_dot_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_3x5x13_rvv_dot_pack_compute.c](t4_3x5x13_rvv_dot_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_3x5x13_rvv_dot_pack_compute.elf](t4_3x5x13_rvv_dot_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_3x5x13_rvv_outer_compute.asm](t4_3x5x13_rvv_outer_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_3x5x13_rvv_outer_compute.bin](t4_3x5x13_rvv_outer_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_3x5x13_rvv_outer_compute.c](t4_3x5x13_rvv_outer_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_3x5x13_rvv_outer_compute.elf](t4_3x5x13_rvv_outer_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_3x5x13_rvv_outer_pack_compute.asm](t4_3x5x13_rvv_outer_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_3x5x13_rvv_outer_pack_compute.bin](t4_3x5x13_rvv_outer_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_3x5x13_rvv_outer_pack_compute.c](t4_3x5x13_rvv_outer_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_3x5x13_rvv_outer_pack_compute.elf](t4_3x5x13_rvv_outer_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_3x5x13_vdot_movx_compute.asm](t4_3x5x13_vdot_movx_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_3x5x13_vdot_movx_compute.bin](t4_3x5x13_vdot_movx_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_3x5x13_vdot_movx_compute.c](t4_3x5x13_vdot_movx_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_3x5x13_vdot_movx_compute.elf](t4_3x5x13_vdot_movx_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_3x5x13_vdot_movx_pack_compute.asm](t4_3x5x13_vdot_movx_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_3x5x13_vdot_movx_pack_compute.bin](t4_3x5x13_vdot_movx_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_3x5x13_vdot_movx_pack_compute.c](t4_3x5x13_vdot_movx_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_3x5x13_vdot_movx_pack_compute.elf](t4_3x5x13_vdot_movx_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_3x5x13_vdot_unroll4_compute.asm](t4_3x5x13_vdot_unroll4_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_3x5x13_vdot_unroll4_compute.bin](t4_3x5x13_vdot_unroll4_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_3x5x13_vdot_unroll4_compute.c](t4_3x5x13_vdot_unroll4_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_3x5x13_vdot_unroll4_compute.elf](t4_3x5x13_vdot_unroll4_compute.elf) | 同名程序的 ELF 可执行文件 |
| [t4_3x5x13_vdot_unroll4_pack_compute.asm](t4_3x5x13_vdot_unroll4_pack_compute.asm) | 同名程序的反汇编文本，用于检查实际指令 |
| [t4_3x5x13_vdot_unroll4_pack_compute.bin](t4_3x5x13_vdot_unroll4_pack_compute.bin) | 同名程序的裸机二进制镜像 |
| [t4_3x5x13_vdot_unroll4_pack_compute.c](t4_3x5x13_vdot_unroll4_pack_compute.c) | C 程序实现，用于可在处理器环境执行的测试程序 |
| [t4_3x5x13_vdot_unroll4_pack_compute.elf](t4_3x5x13_vdot_unroll4_pack_compute.elf) | 同名程序的 ELF 可执行文件 |
