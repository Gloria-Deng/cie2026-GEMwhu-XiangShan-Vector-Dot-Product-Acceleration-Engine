# local_checks

本目录为 2026 年 11 月 7 日在当前材料上执行的 12 项本机检查，均通过。`checks.csv` 中的绝对路径为执行时生成的位置；同名输出及配套文件可在本目录打开。完整处理器结果为读取已完成执行，不代表本机新运行了完整处理器。

| 文件或目录 | 用途 |
| --- | --- |
| [basic_program_build/](basic_program_build/) | 检查中生成的四类测试源码、目标文件和程序。 |
| [basic_rtl/](basic_rtl/) | 基础点积电路及输入检查结果。 |
| [environment/](environment/) | 环境验证和向量加法波形检查的详细输出。 |
| [latency_replay/](latency_replay/) | 重读 348 次点积与 72 次矩阵执行后的计算结果。 |
| [vadd_invalid_inputs/](vadd_invalid_inputs/) | 向量加法波形错误输入检查结果。 |
| [vadd_original_wave/](vadd_original_wave/) | 向量加法实际波形及结果检查。 |
| [vadd_rebuild/](vadd_rebuild/) | 重新编译生成的向量加法程序和符号信息。 |
| [basic_program_build.txt](basic_program_build.txt) | 正数、负数、边界和综合输入程序的构建结果。 |
| [basic_rtl.txt](basic_rtl.txt) | 基础电路与参考结果比较输出。 |
| [checks.csv](checks.csv) | 本目录对应的各项检查及完成状态。 |
| [cluster_parser.txt](cluster_parser.txt) | 超算程序执行入口检查。 |
| [environment.txt](environment.txt) | 环境、功能结果、向量加法波形与身份输出检查。 |
| [full_suite_parser.txt](full_suite_parser.txt) | 完整处理器测试程序入口检查。 |
| [inputs.txt](inputs.txt) | 正数、负数、边界与随机输入检查。 |
| [latency_replay.txt](latency_replay.txt) | 当前点积与矩阵测量的重算状态。 |
| [recorded_results.txt](recorded_results.txt) | 已完成的功能结果重新读取检查。 |
| [reference_model.txt](reference_model.txt) | 点积软件参考计算检查。 |
| [vadd_invalid_inputs.txt](vadd_invalid_inputs.txt) | 波形检查对错误输入的识别结果。 |
| [vadd_original_wave.txt](vadd_original_wave.txt) | 向量加法波形检查输出。 |
| [vadd_rebuild.txt](vadd_rebuild.txt) | 向量加法程序重新构建结果。 |
| README.md | 本目录的文件位置和用途说明。 |
