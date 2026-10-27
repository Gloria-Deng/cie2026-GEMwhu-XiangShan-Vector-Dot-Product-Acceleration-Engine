#ifndef VDOT_VV_H
#define VDOT_VV_H























#include <stdint.h>


static inline int32_t vdot_vv_ref(const int8_t *a, const int8_t *b)
{
    int32_t acc = 0;
    for (int i = 0; i < 8; i++)
        acc += (int32_t)a[i] * (int32_t)b[i];
    return acc;
}





static inline int32_t vdot_vv_alt(const int8_t *a, const int8_t *b)
{
    int32_t p0 = (int32_t)((int16_t)a[0] * (int16_t)b[0]);
    int32_t p1 = (int32_t)((int16_t)a[1] * (int16_t)b[1]);
    int32_t p2 = (int32_t)((int16_t)a[2] * (int16_t)b[2]);
    int32_t p3 = (int32_t)((int16_t)a[3] * (int16_t)b[3]);
    int32_t p4 = (int32_t)((int16_t)a[4] * (int16_t)b[4]);
    int32_t p5 = (int32_t)((int16_t)a[5] * (int16_t)b[5]);
    int32_t p6 = (int32_t)((int16_t)a[6] * (int16_t)b[6]);
    int32_t p7 = (int32_t)((int16_t)a[7] * (int16_t)b[7]);
    int32_t lo = (p0 + p1) + (p2 + p3);
    int32_t hi = (p4 + p5) + (p6 + p7);
    return lo + hi;
}










#define VDOT_VV_WORD(vs2, vs1, vd) \
    (0xB0000000u                     | 0x02000000u            | \
     ((unsigned)(vs2) << 20) | ((unsigned)(vs1) << 15) | \
     0x2000u                  | ((unsigned)(vd) << 7) | 0x57u           )





#if defined(__riscv) && defined(VDOT_VV_ENABLE_ASM)















#define VDOT_VV_ASM_ONE(a_ptr, b_ptr, out_var)                          \
    __asm__ volatile (                                                  \
        "vsetivli t6, 8, e8, m1, ta, ma\n\t"                            \
        "vle8.v   v24, (%1)\n\t"                                        \
        "vle8.v   v25, (%2)\n\t"                                        \
        ".word    %3\n\t"                                               \
        "vsetivli t6, 1, e32, m1, ta, ma\n\t"                           \
        "vmv.x.s  %0, v26"                                              \
        : "=r"(out_var)                                                 \
        : "r"(a_ptr), "r"(b_ptr), "i"(VDOT_VV_WORD(24, 25, 26))         \
        : "t6", "v24", "v25", "v26", "memory")

#endif

#endif
