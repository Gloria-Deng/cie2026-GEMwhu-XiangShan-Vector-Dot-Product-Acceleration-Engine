# 独立点积数量比较

包含循环开销的值与扣除空循环后的估计分别报告。扣除后的值不代表纯电路延迟。

| 执行方式 | 独立数量 | 实现 | 状态 | 含循环周期/点积 | 扣空循环后周期/点积 |
| --- | ---: | --- | --- | ---: | ---: |
| independent | 1 | rvv | PASS | 14.004032 | 12.975806 |
| independent | 1 | vdot | PASS | 1.528226 | 0.500000 |
| independent | 2 | rvv | PASS | 7.497984 | 6.985887 |
| independent | 2 | vdot | PASS | 1.179435 | 0.667339 |
| independent | 4 | rvv | PASS | 5.089718 | 4.833669 |
| independent | 4 | vdot | PASS | 1.256048 | 1.000000 |
| independent | 8 | rvv | PASS | 5.128024 | 5.000000 |
| independent | 8 | vdot | PASS | 1.044859 | 0.916835 |
| independent | 16 | rvv | PASS | 5.022429 | 4.958417 |
| independent | 16 | vdot | PASS | 1.064012 | 1.000000 |
| dependent | 1 | rvv | PASS | 20.991935 | 19.963710 |
| dependent | 1 | vdot | PASS | 7.008065 | 5.979839 |
