# 当前优化点积测量

修订：2026-11-04。任务3952177于11月3日完成，116个程序各三次，共348次香山DiffTest全部通过，用时13小时43分47秒。原始输出和programs目录已从超算完整取回，下载后的内容与远端逐文件一致。

本地复算见[23个比较组](checked_local/comparison.csv)及[倍率](checked_local/optimized_speedup.csv)。16项独立点积：原RVV 5.022429、opt1 4.251260、opt2 4.001008、vdot 1.064012周期/点积；主要倍率为较快RVV / vdot = 3.760303。依赖链应选较快的原RVV 20.991935对vdot 7.008065，倍率2.995397；opt1反而为27.991935。

程序各三次，N=0/64/256/1024，以斜率计算，计时分辨率8周期，完整比较128位。所有348份原始正文位于本目录，runs.csv记录逐次结果，programs保存对应镜像和源码。analysis/reviewed来自超算，checked_local为取回后重新读取原始正文的计算。

从相关证明材料运行 `python -B scripts/check_measurements.py --out ../current-measured-new` 可同时检查420条当前测量。重新绘图运行 `python -B performance/build_figures.py`。
