#define VDOT_VV_ENABLE_ASM 1
#include "include/vdot_vv.h"

int32_t vdot_compile_probe(const int8_t *a, const int8_t *b) {
    int32_t result;
    VDOT_VV_ASM_ONE(a,b,result);
    return result;
}
