# rtl

vdot 及相关向量单元电路实现。

位置：`相关证明材料/rtl/`。

下表列出本目录中的直接子项；子目录中的文件详见对应说明。

| 名称与相对位置 | 用途 |
| --- | --- |
| [chisel/](chisel/) | 由 Chisel 设计生成的电路 |
| [xiangshan-patch/](xiangshan-patch/) | vdot 接入香山的设计与安装修改 |
| [xs_soc_generated/](xs_soc_generated/) | 香山集成 vdot 后生成的相关电路 |
| [xs_soc_generated_vadd/](xs_soc_generated_vadd/) | 香山向量加法单元生成电路 |
| [xs_soc_generated_vimac/](xs_soc_generated_vimac/) | 香山向量乘加单元生成电路 |
| [xs_wrapper_generated/](xs_wrapper_generated/) | 香山 vdot 包装单元生成电路 |
| [README.md](README.md) | 本目录文件位置与用途说明 |
| [vadd_vv_path.sv](vadd_vv_path.sv) | 电路实现：vadd_vv_path |
| [xs_vdot_unit.sv](xs_vdot_unit.sv) | 电路实现：xs_vdot_unit |
