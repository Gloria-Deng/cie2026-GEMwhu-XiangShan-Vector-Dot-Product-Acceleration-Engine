









#include <stdio.h>
#include <stddef.h>
#include <isa.h>

#define P(fld) printf("%-28s %6zu\n", #fld, offsetof(riscv64_CPU_state, fld))

int main(void) {
  printf("sizeof(riscv64_CPU_state) = %zu\n", sizeof(riscv64_CPU_state));
  printf("VLEN = %d\n", (int)VLEN);
  printf("sizeof(vr[0]) = %zu  arrlen = %zu\n",
         sizeof(((riscv64_CPU_state*)0)->vr[0]),
         sizeof(((riscv64_CPU_state*)0)->vr) / sizeof(((riscv64_CPU_state*)0)->vr[0]));
#ifdef CONFIG_RVV
  P(vr);
  P(vl);
  P(vtype);
  P(vstart);
  P(vxsat);
  P(vxrm);
#endif
  P(gpr);
  P(pc);
  P(mstatus);
  P(mode);
  P(satp);
  P(difftest_state_end);
  printf("sizeof(gpr[0])=%zu  ELEN64 per reg: VENUM64=%d VENUM8=%d\n",
         sizeof(((riscv64_CPU_state*)0)->gpr[0]), (int)VENUM64, (int)VENUM8);


  printf("LAYOUT_BEGIN\n");
  printf("OFF_GPR %zu\n", offsetof(riscv64_CPU_state, gpr));
  printf("OFF_PC %zu\n", offsetof(riscv64_CPU_state, pc));
  printf("OFF_MODE %zu\n", offsetof(riscv64_CPU_state, mode));
  printf("OFF_MSTATUS %zu\n", offsetof(riscv64_CPU_state, mstatus));
  printf("OFF_VR %zu\n", offsetof(riscv64_CPU_state, vr));
  printf("VR_STRIDE %zu\n", sizeof(((riscv64_CPU_state*)0)->vr[0]));
  printf("OFF_VSTART %zu\n", offsetof(riscv64_CPU_state, vstart));
  printf("OFF_VTYPE %zu\n", offsetof(riscv64_CPU_state, vtype));
  printf("OFF_VL %zu\n", offsetof(riscv64_CPU_state, vl));
  printf("OFF_END %zu\n", offsetof(riscv64_CPU_state, difftest_state_end));
  printf("STATE_SIZE %zu\n", sizeof(riscv64_CPU_state));
  printf("LAYOUT_END\n");
  return 0;
}
