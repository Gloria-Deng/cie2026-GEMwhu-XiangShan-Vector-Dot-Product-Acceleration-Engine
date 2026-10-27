# 2026年10月23日本地工具真实重新部署

本次通过 Windows 可见终端执行 Ubuntu 24.04 WSL2 下的真实工具重新部署。基础软件重新安装，Mill、firtool、RISC-V 工具和 Verilator 安装到新的 Linux 目录；随后十二项配套检查全部通过。

Windows、WSL 和已有 Ubuntu 发行版本次未重新安装。完整香山处理器构建及执行由超算完成，对应原有 results/cluster/20261019 与 recorded_operations 中的构建记录。本次重新部署负责工具和本地检查，已有超算结果在新环境中再次核对。

## 阅读位置

- continuous_terminal.txt：未经改写的完整 Linux 终端输出，含命令、失败、恢复和结束状态。
- terminal_timing.txt：终端输出时间间隔，可配合 util-linux 的 scriptreplay 读取。
- terminal_readable.txt：从同一原始输出去除终端显示控制符后的阅读副本。
- windows_terminal.txt：本次 Windows 启动、个人标识输出和结束记录。
- operation_times.csv：实际操作的主要时刻，时区为北京时间。
- commands：本次执行的启动及分步操作文件，保存当时使用的原文。
- local_checks/checks.csv：十二项检查结论；对应文本和生成结果位于同目录。
- final_terminal.png：结束时的真实终端截图。
- video_description.txt：后段实录视频的起止时间及范围。

## 失败及处理

Windows PowerShell 5.1 首次读取不带标记的 UTF-8 启动文件时，中文目录被错误解释。启动文件改为带标记的 UTF-8 后，Windows 两份身份程序均正常执行。

Linux 直接下载 GitHub 文件时连接失败。随后由 Windows 的现有网络连接从相同官方发布地址取得固定版本安装文件，再送入 Linux 安装；Verilator 使用官方 v5.052 源码发布包编译。失败输出与后续成功均保留在同一连续终端记录中。

16:34:39 至 18:52:40 之间终端等待下载连接恢复，没有发生部署操作。该等待间隔仍保留在终端时间文件中，不能把整个会话跨度都计算为安装耗时。

## 本次结果

COMPLETE passed=12 failed=0 unavailable=0

基础电路功能、939组输入、完整处理器已有结果、原始 FST 读取、错误输入处理、延迟重算、向量加法重新汇编和三个分类程序编译均完成。本次没有重新执行超算完整处理器仿真。

项目演示视频目录中的 H264 视频为后段工具构建及验证实录，按实际速度播放；完整安装过程请以连续终端输出为准。前段试录未完整保存，未作为官网视频附件交付。
