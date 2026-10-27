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

enum { M=16, N=16, K=16, STRIDE=(K+7)&~7 };
static const int8_t a[M*K] = {-117,-100,-83,-66,-49,-32,-15,2,19,36,53,70,87,104,121,-118,-101,-84,-67,-50,-33,-16,1,18,35,52,69,86,103,120,-119,-102,-85,-68,-51,-34,-17,0,17,34,51,68,85,102,119,-120,-103,-86,-69,-52,-35,-18,-1,16,33,50,67,84,101,118,-121,-104,-87,-70,-53,-36,-19,-2,15,32,49,66,83,100,117,-122,-105,-88,-71,-54,-37,-20,-3,14,31,48,65,82,99,116,-123,-106,-89,-72,-55,-38,-21,-4,13,30,47,64,81,98,115,-124,-107,-90,-73,-56,-39,-22,-5,12,29,46,63,80,97,114,-125,-108,-91,-74,-57,-40,-23,-6,11,28,45,62,79,96,113,-126,-109,-92,-75,-58,-41,-24,-7,10,27,44,61,78,95,112,-127,-110,-93,-76,-59,-42,-25,-8,9,26,43,60,77,94,111,-128,-111,-94,-77,-60,-43,-26,-9,8,25,42,59,76,93,110,127,-112,-95,-78,-61,-44,-27,-10,7,24,41,58,75,92,109,126,-113,-96,-79,-62,-45,-28,-11,6,23,40,57,74,91,108,125,-114,-97,-80,-63,-46,-29,-12,5,22,39,56,73,90,107,124,-115,-98,-81,-64,-47,-30,-13,4,21,38,55,72,89,106,123,-116,-99,-82,-65,-48,-31,-14,3,20,37,54,71,88,105,122};
static const int8_t b[K*N] = {-31,-18,-5,8,21,34,47,60,73,86,99,112,125,-118,-105,-92,-79,-66,-53,-40,-27,-14,-1,12,25,38,51,64,77,90,103,116,-127,-114,-101,-88,-75,-62,-49,-36,-23,-10,3,16,29,42,55,68,81,94,107,120,-123,-110,-97,-84,-71,-58,-45,-32,-19,-6,7,20,33,46,59,72,85,98,111,124,-119,-106,-93,-80,-67,-54,-41,-28,-15,-2,11,24,37,50,63,76,89,102,115,-128,-115,-102,-89,-76,-63,-50,-37,-24,-11,2,15,28,41,54,67,80,93,106,119,-124,-111,-98,-85,-72,-59,-46,-33,-20,-7,6,19,32,45,58,71,84,97,110,123,-120,-107,-94,-81,-68,-55,-42,-29,-16,-3,10,23,36,49,62,75,88,101,114,127,-116,-103,-90,-77,-64,-51,-38,-25,-12,1,14,27,40,53,66,79,92,105,118,-125,-112,-99,-86,-73,-60,-47,-34,-21,-8,5,18,31,44,57,70,83,96,109,122,-121,-108,-95,-82,-69,-56,-43,-30,-17,-4,9,22,35,48,61,74,87,100,113,126,-117,-104,-91,-78,-65,-52,-39,-26,-13,0,13,26,39,52,65,78,91,104,117,-126,-113,-100,-87,-74,-61,-48,-35,-22,-9,4,17,30,43,56,69,82,95,108,121,-122,-109,-96,-83,-70,-57,-44};
static const int32_t expected[M*N] = {26024,24880,-2888,-8896,6856,-25264,-26408,-36768,-25368,3696,-11016,-3968,-5112,23696,4632,7328,7592,6448,-25416,-35520,-23864,5456,4312,-10144,-2840,22128,3320,6272,5128,29840,6680,5280,-23128,-24272,5304,-8896,-1336,23888,22744,4192,7400,28272,5368,4224,3080,23696,-3560,-9056,-600,-1744,23736,5440,8904,30032,28888,6240,5352,22128,-4872,-10112,-11256,5264,-26088,-35680,9640,8496,29880,7488,6856,23888,22744,-4000,-8984,3696,-27400,-36736,-37880,-25456,4632,-9056,7592,6448,23736,-2752,-7480,5456,4312,-26528,-35608,-27024,3320,-10112,-11256,-2928,23064,5280,-6744,-7888,5304,-25280,-34104,-25264,-26408,4192,-8984,-4496,21752,4224,3080,7312,29208,7328,-33368,-34512,-25416,5440,-7480,-2736,-3880,22624,5352,5744,27896,6272,5128,5264,23064,-2912,-6744,-7888,-2888,23872,6856,7504,6360,28768,7400,3696,21752,-3968,-5112,-9072,4632,-25440,7592,6448,7352,30016,8904,5456,4312,22624,-2840,-10640,3320,-26496,-27640,-35696,-26088,5280,9640,8496,5304,23872,-1336,-8880,-10024,4192,-25368,-37264,-27400,4224,3080,-9072,-3560,23712,7848,10032,6072,23872,-2104,-10416,-8232,5216,-25112,-37776,-28680,2176,4360,-8560,-3816,22688,-2392,-208,-8264,5440,-24632,-37040,-34856,-25504,5608,-11152,-6152,20608,22792,5776,6424,28832,-24920,-22736,-34888,-25280,6088,-10416,-8232,-2976,24040,3184,4088,26752,28936,7824,4376,22688,5800,7984,-8264,-2752,24520,3920,6104,7264,30184,5232,2040,20608,22792,-2416,-9960,4256,24232,26416,6072,7488,30664,5968,8152,5216,24040,-5008,-12296,2176,4360,-24944,-36584,-26464};
static int8_t packed[N*STRIDE];
static int32_t c[M*N];
extern char LANDING_BASE[];
__attribute__((noinline,used)) void BAD(void) { for (;;) __asm__ volatile(""); }
static inline uint64_t ticks(void) { uint64_t v; __asm__ volatile("fence rw,rw\n\trdcycle %0\n\tfence rw,rw" : "=r"(v) : : "memory"); return v; }
void run(void) {
    
    uint64_t start = ticks();
    if (vdot_gemm_pack_b(b,N,K,packed,sizeof packed)) BAD();
    int status = vdot_gemm_packed(a,packed,c,M,N,K,(enum vdot_gemm_method)0);
    uint64_t delta = ticks() - start;
    if (status || delta >= 65536ULL*8) BAD();
    for (size_t i=0; i<M*N; i++) if (c[i] != expected[i]) BAD();
    void (*finish)(void) = (void *)(LANDING_BASE + ((delta/8)*4));
    finish();
}
