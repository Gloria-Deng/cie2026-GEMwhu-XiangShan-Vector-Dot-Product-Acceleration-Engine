#define VDOT_GEMM_ASM 1
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

enum { M=3, N=5, K=13, STRIDE=(K+7)&~7 };
static const int8_t a[M*K] = {-117,-100,-83,-66,-49,-32,-15,2,19,36,53,70,87,104,121,-118,-101,-84,-67,-50,-33,-16,1,18,35,52,69,86,103,120,-119,-102,-85,-68,-51,-34,-17,0,17};
static const int8_t b[K*N] = {-31,-18,-5,8,21,34,47,60,73,86,99,112,125,-118,-105,-92,-79,-66,-53,-40,-27,-14,-1,12,25,38,51,64,77,90,103,116,-127,-114,-101,-88,-75,-62,-49,-36,-23,-10,3,16,29,42,55,68,81,94,107,120,-123,-110,-97,-84,-71,-58,-45,-32,-19,-6,7,20,33};
static const int32_t expected[M*N] = {-4319,-6854,-19117,-404,-2939,-5616,-7410,-1012,27402,25608,-5889,-6942,18117,-9304,-10357};
static int8_t packed[N*STRIDE];
static int32_t c[M*N];
extern char LANDING_BASE[];
__attribute__((noinline,used)) void BAD(void) { for (;;) __asm__ volatile(""); }
static inline uint64_t ticks(void) { uint64_t v; __asm__ volatile("fence rw,rw\n\trdcycle %0\n\tfence rw,rw" : "=r"(v) : : "memory"); return v; }
void run(void) {
    
    uint64_t start = ticks();
    if (vdot_gemm_pack_b(b,N,K,packed,sizeof packed)) BAD();
    int status = vdot_gemm_packed(a,packed,c,M,N,K,(enum vdot_gemm_method)1);
    uint64_t delta = ticks() - start;
    if (status || delta >= 65536ULL*8) BAD();
    for (size_t i=0; i<M*N; i++) if (c[i] != expected[i]) BAD();
    void (*finish)(void) = (void *)(LANDING_BASE + ((delta/8)*4));
    finish();
}
