# baremetal

裸机启动、链接布局及运行支持。

位置：`相关证明材料/applications/gemm/baremetal/`。

下表列出本目录中的直接子项；子目录中的文件详见对应说明。

| 名称与相对位置 | 用途 |
| --- | --- |
| [cosim_layout.h](cosim_layout.h) | C 接口或参数定义，用于裸机启动、链接布局及运行支持 |
| [kernel.c.in](kernel.c.in) | 程序生成模板，用于裸机启动、链接布局及运行支持 |
| [landing.S](landing.S) | 汇编程序，用于裸机启动、链接布局及运行支持 |
| [link_landing.ld](link_landing.ld) | 裸机程序的链接地址布局 |
| [README.md](README.md) | 本目录文件位置与用途说明 |
| [reference_runner.c](reference_runner.c) | C 程序实现，用于裸机启动、链接布局及运行支持 |
| [rvv_measure.sbatch](rvv_measure.sbatch) | 超算作业脚本，用于裸机启动、链接布局及运行支持 |
| [rvv_validation.c](rvv_validation.c) | C 程序实现，用于裸机启动、链接布局及运行支持 |
| [start.S](start.S) | 汇编程序，用于裸机启动、链接布局及运行支持 |
