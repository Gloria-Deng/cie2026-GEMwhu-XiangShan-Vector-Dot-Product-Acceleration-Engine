















require_vector(true);
require(P.VU.vsew == e8);

require(insn.v_vm() == 1);
require(P.VU.vstart == 0);





int64_t vd_acc = 0;
for (int idx = 0; idx < 8; ++idx) {
    int64_t a = P.VU.elt<int8_t>(rs1_num, idx);
    int64_t b = P.VU.elt<int8_t>(rs2_num, idx);
    vd_acc += a * b;
}



for (int i = 0; i < P.VU.vlenb; ++i)
    P.VU.elt<uint8_t>(vd_num, i) = 0;
if (P.VU.vl > 0) {
    P.VU.elt<int32_t>(vd_num, 0) = (int32_t)vd_acc;
}
P.VU.vstart = 0;
