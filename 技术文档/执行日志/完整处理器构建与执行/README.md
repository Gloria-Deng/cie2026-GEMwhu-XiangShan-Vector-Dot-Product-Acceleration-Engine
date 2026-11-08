# 完整处理器构建与执行

本目录保存香山处理器和 NEMU 的实际构建、源码核对与程序准备过程；`compile_xiangshan.txt` 和 `emu_resume.log` 共同记录处理器生成、编译及链接过程。源码检查 34 项通过。

[整核录波](整核录波/README.md)保存超算成功作业的输出与逐指令结果；向量加法原始波形和分析见[相关材料](../../../相关证明材料/results/vadd_wave_stage1/README.md)。

| 文件或目录 | 用途 |
| --- | --- |
| [整核录波/](%E6%95%B4%E6%A0%B8%E5%BD%95%E6%B3%A2/) | 整核录波作业的状态、输出及逐条指令分析。 |
| [build_configuration.json](build_configuration.json) | 完整处理器构建使用的配置、工具及并行设置。 |
| [build_manifest.json](build_manifest.json) | 实际构建所用源码、处理器程序、参考库和工具信息。 |
| [compile_nemu.txt](compile_nemu.txt) | NEMU 参考库编译输出。 |
| [compile_xiangshan.txt](compile_xiangshan.txt) | 香山硬件生成及处理器构建输出。 |
| [configure_nemu.txt](configure_nemu.txt) | NEMU 配置过程输出。 |
| [emu_resume.log](emu_resume.log) | 处理器编译及链接完成过程输出。 |
| [install_nemu.txt](install_nemu.txt) | NEMU 指令扩展应用过程输出。 |
| [install_xiangshan.txt](install_xiangshan.txt) | 香山 vdot 接入应用过程输出。 |
| [original_vadd_wave.log](original_vadd_wave.log) | 向量加法波形对应的处理器执行输出。 |
| [准备与功能检查.txt](%E5%87%86%E5%A4%87%E4%B8%8E%E5%8A%9F%E8%83%BD%E6%A3%80%E6%9F%A5.txt) | 源码检查、测试程序构建、NEMU 功能检查和环境验证的实际输出。 |
| [源码检查状态.txt](%E6%BA%90%E7%A0%81%E6%A3%80%E6%9F%A5%E7%8A%B6%E6%80%81.txt) | 当前处理器构建的源码检查状态。 |
| [源码检查结果.csv](%E6%BA%90%E7%A0%81%E6%A3%80%E6%9F%A5%E7%BB%93%E6%9E%9C.csv) | 当前处理器构建的 34 项源码与构建检查结果。 |
| README.md | 本目录的文件位置和用途说明。 |
