# 超算三层hello输出

修订：2026-11-04。任务3950525在计算节点n0349成功，用时16分27秒。Linux、独立UARTLite NEMU、香山emu三层均输出 `hello xiangshan, I am GEMwhu, IP address 10.6.6.21`。

IP由实际执行主机查得并在编译时写入裸机镜像。NEMU与emu均停在OK地址0x80000048，emu明确开启DiffTest。status.txt为三层PASS；image保存实际镜像、嵌入地址和符号。

取回后使用 `python -B stage1/check_measured_hello.py` 重读三个正文并核对IP、NEMU/emu终点、DiffTest及状态通过。
