#include "rvv_gemm.h"

#if defined(RVV_GEMM_ASM) && !defined(__riscv)
#error RVV_GEMM_ASM_requires_RISC_V
#endif

const char *rvv_gemm_backend(void)
{
#if defined(RVV_GEMM_ASM)
    return "RVV_BASELINE";
#else
    return "C_REFERENCE";
#endif
}

static int valid_method(enum rvv_gemm_method method)
{
    return method == RVV_GEMM_DOT || method == RVV_GEMM_OUTER;
}

static int valid_dimensions(size_t m, size_t n, size_t k)
{
    return (!n || m <= SIZE_MAX / n / sizeof(int32_t)) &&
           (!k || (m <= SIZE_MAX / k && n <= SIZE_MAX / k)) &&
           k <= SIZE_MAX - 7 && (!n || !k || vdot_gemm_pack_bytes(n,k));
}

int rvv_gemm_pack_b(const int8_t *b, size_t n, size_t k, int8_t *packed,
                    size_t capacity, enum rvv_gemm_method method)
{
    if (!valid_method(method) || !valid_dimensions(0,n,k)) return -1;
    if (!n || !k) return 0;
    if (method == RVV_GEMM_DOT) return vdot_gemm_pack_b(b,n,k,packed,capacity);
    if (!b || !packed) return -1;
    if (capacity < n*k) return -2;
    for (size_t q = 0; q < n*k; q++) packed[q] = b[q];
    return 0;
}

/* Every int8 product fits int16, but eight products require int32.
 * tu preserves the zeros in every destination word above element zero. */
static int32_t rvv_dot8(const int8_t *a, const int8_t *b)
{
#if defined(RVV_GEMM_ASM)
    int32_t result;
    __asm__ volatile(
        "vsetvli t6,zero,e32,m1,tu,ma\n\t"
        "vmv.v.i v26,0\n\t" "vmv.v.i v30,0\n\t"
        "vsetivli t6,8,e8,m1,tu,ma\n\t"
        "vle8.v v24,(%1)\n\t" "vle8.v v25,(%2)\n\t"
        "vwmul.vv v28,v24,v25\n\t"
        "vsetivli t6,8,e16,m2,tu,ma\n\t"
        "vwredsum.vs v26,v28,v30\n\t"
        "vsetivli t6,1,e32,m1,tu,ma\n\t"
        "vmv.x.s %0,v26\n\t"
        : "=r"(result) : "r"(a), "r"(b)
        : "t6", "v24", "v25", "v26", "v28", "v29", "v30", "memory");
    return result;
#else
    int32_t result = 0;
    for (size_t q = 0; q < 8; q++) result += (int32_t)a[q] * (int32_t)b[q];
    return result;
#endif
}

void rvv_gemm_dot8_full(const int8_t *a, const int8_t *b, uint32_t result[4])
{
#if defined(RVV_GEMM_ASM)
    __asm__ volatile(
        "vsetvli t6,zero,e32,m1,tu,ma\n\t"
        "vmv.v.i v26,0\n\t" "vmv.v.i v30,0\n\t"
        "vsetivli t6,8,e8,m1,tu,ma\n\t"
        "vle8.v v24,(%0)\n\t" "vle8.v v25,(%1)\n\t"
        "vwmul.vv v28,v24,v25\n\t"
        "vsetivli t6,8,e16,m2,tu,ma\n\t"
        "vwredsum.vs v26,v28,v30\n\t"
        "vsetivli t6,4,e32,m1,tu,ma\n\t"
        "vse32.v v26,(%2)\n\t"
        : : "r"(a), "r"(b), "r"(result)
        : "t6", "v24", "v25", "v26", "v28", "v29", "v30", "memory");
#else
    result[0] = (uint32_t)rvv_dot8(a,b);
    result[1] = result[2] = result[3] = 0;
#endif
}

static void dot_row(const int8_t *a, const int8_t *b, int32_t *c, size_t n, size_t k)
{
    size_t stride = (k+7)&~(size_t)7;
    for (size_t j = 0; j < n; j++) {
        uint32_t total = 0;
        for (size_t q = 0; q < k; q += 8) {
            int8_t tail[8] = {0};
            const int8_t *left = a+q;
            if (k-q < 8) {
                for (size_t t = 0; t < k-q; t++) tail[t] = left[t];
                left = tail;
            }
            total += (uint32_t)rvv_dot8(left,b+j*stride+q);
        }
        c[j] = (int32_t)total;
    }
}

/* The e8/m1, e16/m2 and e32/m4 settings have equal lane counts.
 * B is sign-extended before e16 -> e32 widening multiply-accumulate;
 * no partial sum is ever kept at 16 bits. RVV addition wraps modulo 2^32. */
static void outer_row(const int8_t *a, const int8_t *b, int32_t *c, size_t n, size_t k)
{
    size_t j = 0;
    while (j < n) {
#if defined(RVV_GEMM_ASM)
        size_t vl, remain = n-j;
        const int8_t *left = a, *right = b+j;
        size_t count = k;
        __asm__ volatile(
            "vsetvli %[vl],%[remain],e8,m1,ta,ma\n\t"
            "vsetvli t6,%[vl],e32,m4,ta,ma\n\t"
            "vmv.v.i v8,0\n\t"
            "1:\n\t"
            "lb t0,0(%[left])\n\t"
            "vsetvli t6,%[vl],e8,m1,ta,ma\n\t"
            "vle8.v v16,(%[right])\n\t"
            "vsetvli t6,%[vl],e16,m2,ta,ma\n\t"
            "vsext.vf2 v24,v16\n\t"
            "vwmacc.vx v8,t0,v24\n\t"
            "addi %[left],%[left],1\n\t"
            "add %[right],%[right],%[n]\n\t"
            "addi %[count],%[count],-1\n\t"
            "bnez %[count],1b\n\t"
            "vsetvli t6,%[vl],e32,m4,ta,ma\n\t"
            "vse32.v v8,(%[out])\n\t"
            : [vl] "=&r"(vl), [left] "+&r"(left), [right] "+&r"(right), [count] "+&r"(count)
            : [remain] "r"(remain), [n] "r"(n), [out] "r"(c+j)
            : "t0", "t6", "v8", "v9", "v10", "v11", "v16", "v24", "v25", "memory");
        j += vl;
#else
        uint32_t total = 0;
        for (size_t q = 0; q < k; q++) total += (uint32_t)((int32_t)a[q]*(int32_t)b[q*n+j]);
        c[j++] = (int32_t)total;
#endif
    }
}

int rvv_gemm_packed(const int8_t *a, const int8_t *packed, int32_t *c,
                   size_t m, size_t n, size_t k, enum rvv_gemm_method method)
{
    if (!valid_method(method) || !valid_dimensions(m,n,k) ||
        (m && n && !c) || (m && n && k && (!a || !packed))) return -1;
    if (!m || !n) return 0;
    if (!k) {
        for (size_t i = 0; i < m*n; i++) c[i] = 0;
        return 0;
    }
    for (size_t i = 0; i < m; i++) {
        if (method == RVV_GEMM_DOT) dot_row(a+i*k,packed,c+i*n,n,k);
        else outer_row(a+i*k,packed,c+i*n,n,k);
    }
    return 0;
}
