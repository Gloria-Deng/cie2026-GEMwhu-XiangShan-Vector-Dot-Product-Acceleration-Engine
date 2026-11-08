# 相关证明材料

香山 vdot 项目的源码、测试输入、实际运行输出与波形材料。

位置：`相关证明材料/`。

下表列出本目录中的直接子项；子目录中的文件详见对应说明。

| 名称与相对位置 | 用途 |
| --- | --- |
| [applications/](applications/) | 矩阵应用与对应性能测量 |
| [cluster/](cluster/) | 超算构建与执行脚本 |
| [examples/](examples/) | vdot 最小调用示例 |
| [experiments/](experiments/) | 点积性能实验 |
| [gen/](gen/) | 生成的硬件和程序文件 |
| [licenses/](licenses/) | 第三方许可证和版权说明 |
| [llvm/](llvm/) | LLVM 自定义指令接入文件 |
| [nemu/](nemu/) | NEMU 指令扩展与协同运行支持 |
| [performance/](performance/) | 性能图表及其生成程序 |
| [programs/](programs/) | 可在处理器环境执行的测试程序 |
| [reference/](reference/) | 指令编码和上游设计参考 |
| [results/](results/) | 实际运行输出与波形分析结果 |
| [rtl/](rtl/) | vdot 及相关向量单元电路实现 |
| [scripts/](scripts/) | 环境构建、程序执行和结果检查工具 |
| [sim/](sim/) | 独立电路仿真及参考计算工具 |
| [software/](software/) | vdot 软件接口与功能检查 |
| [source_additions/](source_additions/) | 构建所需的补充上游组件 |
| [sources/](sources/) | 随附上游源码，按其原有说明使用 |
| [spike/](spike/) | Spike 指令扩展支持 |
| [stage1/](stage1/) | 环境问候输出与裸机程序 |
| [synth/](synth/) | 电路综合与静态时序分析工具 |
| [tb/](tb/) | 电路测试平台与参考输入 |
| [tests/](tests/) | 正数、负数、边界值和随机测试输入 |
| [tools/](tools/) | 波形读取、程序准备与提交材料检查工具 |
| [verification/](verification/) | vdot 功能和数据通路检查 |
| [waveforms/](waveforms/) | 向量加法实际波形及查看配置 |
| [.gitattributes](.gitattributes) | 大文件与文本文件的 Git 属性配置 |
| [build_vadd.py](build_vadd.py) | 构建香山向量加法验证程序 |
| [check_environment.py](check_environment.py) | 检查本机开发工具与环境 |
| [check_programs.py](check_programs.py) | 检查测试程序、独立电路及所需工具 |
| [README.md](README.md) | 本目录文件位置与用途说明 |
| [reproduce_vadd.py](reproduce_vadd.py) | 重现向量加法程序执行与波形 |
| [requirements-local-check.txt](requirements-local-check.txt) | 本地检查所需的 Python 依赖列表 |
| [requirements.txt](requirements.txt) | Python 依赖列表 |
| [rerun_simulation.sh](rerun_simulation.sh) | 重新执行独立电路仿真 |
| [run_latency.py](run_latency.py) | 管理完整处理器的构建和延迟实验 |
| [source_comment_changes.csv](source_comment_changes.csv) | 上游源码中注释调整的位置与用途 |
| [source_function_changes.csv](source_function_changes.csv) | 上游源码中功能修改的位置与用途 |
| [source_locations.csv](source_locations.csv) | 上游源码组件的位置对应表 |
| [source_revisions.csv](source_revisions.csv) | 随附上游组件的版本与获取位置 |
