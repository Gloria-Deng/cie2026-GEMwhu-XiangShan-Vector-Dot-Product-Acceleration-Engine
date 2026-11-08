#define RVV_GEMM_ASM 1
#ifndef VDOT_GEMM_H
#define VDOT_GEMM_H
#include <stddef.h>
#include <stdint.h>

enum vdot_gemm_method { VDOT_GEMM_MOVX = 0, VDOT_GEMM_UNROLL4 = 1 };

const char *vdot_gemm_backend(void);
size_t vdot_gemm_pack_bytes(size_t n, size_t k);
int vdot_gemm_pack_b(const int8_t *b, size_t n, size_t k, int8_t *packed, size_t capacity);
int vdot_gemm_reference(const int8_t *a, const int8_t *b, int32_t *c, size_t m, size_t n, size_t k);
int vdot_gemm_packed(const int8_t *a, const int8_t *packed, int32_t *c, size_t m, size_t n, size_t k, enum vdot_gemm_method method);
#endif

#include <limits.h>

#if defined(VDOT_GEMM_ASM) && !defined(__riscv)
#error VDOT_GEMM_ASM_requires_RISC_V
#endif

const char *vdot_gemm_backend(void)
{
#if defined(VDOT_GEMM_ASM)
    return "CUSTOM_VDOT";
#else
    return "C_REFERENCE";
#endif
}

size_t vdot_gemm_pack_bytes(size_t n, size_t k)
{
    if (k > SIZE_MAX - 7) return 0;
    size_t stride = (k + 7) & ~(size_t)7;
    if (stride && n > SIZE_MAX / stride) return 0;
    return n * stride;
}

static int dimensions(size_t m, size_t n, size_t k)
{
    return (!n || m <= SIZE_MAX / n / sizeof(int32_t)) &&
           (!k || (m <= SIZE_MAX / k && n <= SIZE_MAX / k)) &&
           (k <= SIZE_MAX - 7) && (!n || !k || vdot_gemm_pack_bytes(n, k));
}

int vdot_gemm_pack_b(const int8_t *b, size_t n, size_t k, int8_t *packed, size_t capacity)
{
    if (!n || !k) return 0;
    size_t bytes = vdot_gemm_pack_bytes(n, k);
    if (!bytes || !b || !packed) return -1;
    if (capacity < bytes) return -2;
    size_t stride = (k + 7) & ~(size_t)7;
    for (size_t j = 0; j < n; j++)
        for (size_t q = 0; q < stride; q++)
            packed[j * stride + q] = q < k ? b[q * n + j] : 0;
    return 0;
}

int vdot_gemm_reference(const int8_t *a, const int8_t *b, int32_t *c, size_t m, size_t n, size_t k)
{
    if (!dimensions(m, n, k) || (m && n && !c) || (m && n && k && (!a || !b))) return -1;
    if (!m || !n) return 0;
    for (size_t i = 0; i < m; i++) {
        for (size_t j = 0; j < n; j++) {
            uint32_t total = 0;
            for (size_t q = 0; q < k; q++) total += (uint32_t)((int32_t)a[i*k+q] * (int32_t)b[q*n+j]);
            c[i*n+j] = (int32_t)total;
        }
    }
    return 0;
}

static int32_t dot8(const int8_t *a, const int8_t *b)
{
#if defined(VDOT_GEMM_ASM)
    int32_t result;
    __asm__ volatile(
        "vsetivli t6,8,e8,m1,ta,ma\n\t"
        "vle8.v v24,(%1)\n\t"
        "vle8.v v25,(%2)\n\t"
        ".word 0xb38cad57\n\t"
        "vsetivli t6,1,e32,m1,ta,ma\n\t"
        "vmv.x.s %0,v26\n\t"
        : "=r"(result) : "r"(a), "r"(b) : "t6", "v24", "v25", "v26", "memory");
    return result;
#else
    int32_t result = 0;
    for (size_t q = 0; q < 8; q++) result += (int32_t)a[q] * (int32_t)b[q];
    return result;
#endif
}

static void columns(const int8_t *a, const int8_t *packed, int32_t *c, size_t n, size_t k, size_t start)
{
    size_t stride = (k + 7) & ~(size_t)7;
    for (size_t j = start; j < n; j++) {
        uint32_t total = 0;
        for (size_t q = 0; q < k; q += 8) {
            int8_t tail[8] = {0};
            const int8_t *av = a + q;
            if (k - q < 8) {
                for (size_t t = 0; t < k - q; t++) tail[t] = av[t];
                av = tail;
            }
            total += (uint32_t)dot8(av, packed + j*stride + q);
        }
        c[j] = (int32_t)total;
    }
}

#if defined(VDOT_GEMM_ASM)
static void groups4(const int8_t *a, const int8_t *packed, int32_t *c, size_t n, size_t k)
{
    size_t stride = (k + 7) & ~(size_t)7;
    size_t j = 0;
    for (; n-j >= 4; j += 4) {
        int8_t tail[8] = {0};
        size_t full = k & ~(size_t)7;
        for (size_t t = 0; t < k-full; t++) tail[t] = a[full+t];
        const int8_t *left = a, *end = a+full;
        const int8_t *b0 = packed+j*stride, *b1 = b0+stride, *b2 = b1+stride, *b3 = b2+stride;
        size_t remaining = (k+7)/8;
        int32_t s0, s1, s2, s3;
        __asm__ volatile(
            "vsetivli t6,4,e32,m1,ta,ma\n\t"
            "vmv.v.i v20,0\n\t" "vmv.v.i v21,0\n\t"
            "vmv.v.i v22,0\n\t" "vmv.v.i v23,0\n\t"
            "1:\n\t"
            "bltu %[left],%[end],2f\n\t"
            "mv t0,%[tail]\n\t" "j 3f\n\t"
            "2: mv t0,%[left]\n\t"
            "3:\n\t"
            "vsetivli t6,8,e8,m1,ta,ma\n\t"
            "vle8.v v24,(t0)\n\t"
            "vle8.v v25,(%[b0])\n\t" ".word 0xb38ca257\n\t"
            "vle8.v v25,(%[b1])\n\t" ".word 0xb38ca2d7\n\t"
            "vle8.v v25,(%[b2])\n\t" ".word 0xb38ca357\n\t"
            "vle8.v v25,(%[b3])\n\t" ".word 0xb38ca3d7\n\t"
            "vsetivli t6,4,e32,m1,ta,ma\n\t"
            "vadd.vv v20,v20,v4\n\t" "vadd.vv v21,v21,v5\n\t"
            "vadd.vv v22,v22,v6\n\t" "vadd.vv v23,v23,v7\n\t"
            "addi %[left],%[left],8\n\t"
            "addi %[b0],%[b0],8\n\t" "addi %[b1],%[b1],8\n\t"
            "addi %[b2],%[b2],8\n\t" "addi %[b3],%[b3],8\n\t"
            "addi %[remaining],%[remaining],-1\n\t"
            "bnez %[remaining],1b\n\t"
            "vsetivli t6,1,e32,m1,ta,ma\n\t"
            "vmv.x.s %[s0],v20\n\t" "vmv.x.s %[s1],v21\n\t"
            "vmv.x.s %[s2],v22\n\t" "vmv.x.s %[s3],v23\n\t"
            : [s0] "=&r"(s0), [s1] "=&r"(s1), [s2] "=&r"(s2), [s3] "=&r"(s3),
              [left] "+&r"(left), [b0] "+&r"(b0), [b1] "+&r"(b1), [b2] "+&r"(b2), [b3] "+&r"(b3), [remaining] "+&r"(remaining)
            : [end] "r"(end), [tail] "r"(tail)
            : "t0", "t6", "v24", "v25", "v4", "v5", "v6", "v7", "v20", "v21", "v22", "v23", "memory");
        c[j] = s0; c[j+1] = s1; c[j+2] = s2; c[j+3] = s3;
    }
    columns(a, packed, c, n, k, j);
}
#endif

int vdot_gemm_packed(const int8_t *a, const int8_t *packed, int32_t *c, size_t m, size_t n, size_t k, enum vdot_gemm_method method)
{
    if (!dimensions(m,n,k) || (method != VDOT_GEMM_MOVX && method != VDOT_GEMM_UNROLL4) ||
        (m && n && !c) || (m && n && k && (!a || !packed))) return -1;
    if (!m || !n) return 0;
    if (!k) {
        for (size_t i = 0; i < m*n; i++) c[i] = 0;
        return 0;
    }
    for (size_t i = 0; i < m; i++) {
#if defined(VDOT_GEMM_ASM)
        if (method == VDOT_GEMM_UNROLL4) groups4(a+i*k, packed, c+i*n, n, k);
        else columns(a+i*k, packed, c+i*n, n, k, 0);
#else
        columns(a+i*k, packed, c+i*n, n, k, 0);
#endif
    }
    return 0;
}

#ifndef RVV_GEMM_H
#define RVV_GEMM_H


enum rvv_gemm_method { RVV_GEMM_DOT = 0, RVV_GEMM_OUTER = 1 };
const char *rvv_gemm_backend(void);
/* DOT uses the existing column-padded layout; OUTER uses row-major B. */
int rvv_gemm_pack_b(const int8_t *b, size_t n, size_t k, int8_t *packed,
                    size_t capacity, enum rvv_gemm_method method);
int rvv_gemm_packed(const int8_t *a, const int8_t *packed, int32_t *c,
                   size_t m, size_t n, size_t k, enum rvv_gemm_method method);
/* Always writes all four words. RVV execution requires VLEN >= 128. */
void rvv_gemm_dot8_full(const int8_t *a, const int8_t *b, uint32_t result[4]);
#endif


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


static int8_t a[131080], b[131080], packed[131080];
static int32_t c[1026], expected[1024];
static uint32_t state=20261029u;
extern char LANDING_BASE[];
__attribute__((noinline,used)) void BAD(void) { for (;;) __asm__ volatile(""); }
static int8_t value(void)
{
    state^=state<<13; state^=state>>17; state^=state<<5;
    return (int8_t)state;
}

static void shape(size_t m, size_t n, size_t k, int pattern)
{
    for (size_t i=0;i<m*k;i++) a[i]=pattern==1?-128:pattern==2?127:value();
    for (size_t i=0;i<k*n;i++) b[i]=pattern?-128:value();
    if (vdot_gemm_reference(a,b,expected,m,n,k)) BAD();
    for (int method=0;method<2;method++) {
        enum rvv_gemm_method which=(enum rvv_gemm_method)method;
        if (rvv_gemm_pack_b(b,n,k,packed,sizeof packed,which)) BAD();
        c[0]=INT32_C(0x13579bdf); c[m*n+1]=INT32_C(0x2468ace0);
        for (size_t i=0;i<m*n;i++) c[i+1]=INT32_C(0x55555555);
        if (rvv_gemm_packed(a,packed,c+1,m,n,k,which)) BAD();
        if (c[0]!=INT32_C(0x13579bdf) || c[m*n+1]!=INT32_C(0x2468ace0)) BAD();
        for (size_t i=0;i<m*n;i++) if (c[i+1]!=expected[i]) BAD();
    }
}

void run(void)
{
    for (size_t m=1;m<=4;m++) for (size_t n=1;n<=9;n++) for (size_t k=0;k<=41;k++) shape(m,n,k,0);
    for (int p=1;p<=2;p++) { shape(3,5,13,p); shape(1,1,131073,p); }
    const size_t extra[6][3]={{3,5,13},{1,4,1},{1,4,8},{1,8,16},{1,3,7},{2,5,0}};
    for (int i=0;i<6;i++) shape(extra[i][0],extra[i][1],extra[i][2],0);
    /* Poison the destination and its seed before checking all 128 bits. */
    for (int p=0;p<3;p++) {
        int32_t sum=0;
        for (int i=0;i<8;i++) { a[i]=p==0?-128:p==1?127:value(); b[i]=p<2?-128:value(); sum+=(int32_t)a[i]*b[i]; }
        uint32_t full[4]={0xdeadbeef,0xdeadbeef,0xdeadbeef,0xdeadbeef};
        __asm__ volatile("vsetvli t6,zero,e32,m1,ta,ma\n\tvmv.v.i v26,-1\n\tvmv.v.i v30,-1" : : : "t6","v26","v30");
        rvv_gemm_dot8_full(a,b,full);
        if (full[0]!=(uint32_t)sum || full[1] || full[2] || full[3]) BAD();
    }
    int32_t result=1;
    for (int method=0;method<2;method++) {
        enum rvv_gemm_method which=(enum rvv_gemm_method)method;
        if (rvv_gemm_packed(0,0,&result,1,1,0,which) || result) BAD();
        if (rvv_gemm_packed(0,0,0,0,1,1,which)) BAD();
        if (rvv_gemm_packed(a,b,&result,SIZE_MAX,2,1,which)!=-1) BAD();
        if (rvv_gemm_packed(a,b,&result,1,1,SIZE_MAX,which)!=-1) BAD();
    }
    ((void (*)(void))LANDING_BASE)();
}
