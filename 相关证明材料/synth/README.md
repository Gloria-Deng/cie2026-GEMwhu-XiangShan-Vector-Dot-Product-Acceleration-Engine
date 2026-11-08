# 面积与时序评估

2026-10-30 已实际完成六个对象的 Nangate45 综合与 OpenSTA 分析，见 [汇总表](results_20261030_nangate45/summary.csv)。

从“相关证明材料”目录执行以下命令。Ubuntu 24.04 的软件源未提供 `opensta`，因此使用固定版本源码安装。

```bash
sudo apt-get update
sudo apt-get install -y yosys curl unzip build-essential cmake bison flex swig tcl-dev zlib1g-dev libeigen3-dev libfmt-dev
bash synth/install_tools.sh
export TOOLS_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cie-vdot-synth"
export PATH="$TOOLS_DIR/opensta/build:$TOOLS_DIR/sv2v-Linux:$PATH"
bash synth/run_synth.sh --out synth/results_new --liberty "$TOOLS_DIR/NangateOpenCellLibrary_typical.lib" --sv2v "$TOOLS_DIR/sv2v-Linux/sv2v" --clock-ns 10 --timeout 1800
```

输出位置必须是新目录或空目录。成功输出为 `SYNTH_PASS targets=6`。单对象使用 `--target tree0`。若未给工艺库，只计算通用单元数与逻辑层数；不能把逻辑层数当作纳秒。安装程序使用 sv2v 0.0.13、CUDD 3.0.0、OpenSTA 3.1.0 固定源码版本，以及固定版本的 Nangate45 typical 库；库的原有声明由下载文件保留。安装依赖网络；已准备工具后，综合与时序计算均在本地进行。

各对象目录保留输入转换结果、综合命令、工具输出、单元面积统计、电路连接和时序报告。综合在映射前调用 `ltp -noff` 计算组合层数；寄存器位数来自 `proc/flatten/opt` 后的位宽之和，属于映射前表示，不等于最后标准单元触发器数。映射前导入标准单元定义，再检查连接关系，避免把已映射触发器误判为无驱动。

时序统一设置时钟 10 ns，外部输入和输出延迟为零，时钟理想，无布线寄生参数、无额外输出负载、无输入驱动单元与输入变化时间约束，未进行插入缓冲器或单元尺寸优化。`max_reported_arrival_ns` 是报告路径中的最大到达时间，包含寄存器输出延迟，不包含终点建立时间；不能直接取倒数作为处理器最高频率。`multiply_arrival_ns` 和 `reduce_arrival_ns` 分别终止于乘积寄存器与求和寄存器。OpenSTA 输入版本会移除源位置等附加属性，处理 Yosys 0.33 对中文路径的转义问题；连接关系不变。

已完成面积计算的目录可以补充时序，无需重新综合：

```bash
python3 synth/analyze_timing.py --results synth/results_new --liberty "$TOOLS_DIR/NangateOpenCellLibrary_typical.lib"
```

本次参考了 [Ibex 综合流程](https://github.com/lowRISC/ibex/tree/master/syn)、[Yosys 综合文档](https://yosyshq.readthedocs.io/projects/yosys/en/latest/using_yosys/synthesis/)、[OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA)、[OpenROAD Nangate45](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/tree/master/flow/platforms/nangate45)。本目录只新增评估程序，不改变 vdot.vv 电路行为或编码。
