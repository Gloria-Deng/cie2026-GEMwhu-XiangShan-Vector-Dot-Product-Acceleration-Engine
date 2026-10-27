#include "vdot_gemm.h"

#ifndef VDOT_APP_M
#define VDOT_APP_M 3
#endif
#ifndef VDOT_APP_N
#define VDOT_APP_N 5
#endif
#ifndef VDOT_APP_K
#define VDOT_APP_K 13
#endif
enum { M = VDOT_APP_M, N = VDOT_APP_N, K = VDOT_APP_K, STRIDE = (K+7)&~7 };
static int8_t a[M*K ? M*K : 1], b[K*N ? K*N : 1], packed[N*STRIDE ? N*STRIDE : 1];
static int32_t c[M*N ? M*N : 1];

__attribute__((noinline,used)) void OK(void) { for (;;) __asm__ volatile(""); }
__attribute__((noinline,used)) void BAD(void) { for (;;) __asm__ volatile(""); }

void run(void)
{
    for (size_t i = 0; i < M*K; i++) a[i] = (int8_t)((i*17u+11u)%256u-128u);
    for (size_t i = 0; i < K*N; i++) b[i] = (int8_t)((i*13u+97u)%256u-128u);
    uint64_t mismatches = 0;
    if (vdot_gemm_pack_b(b,N,K,packed,sizeof packed)) BAD();
    for (int method = 0; method < 2; method++) {
        if (vdot_gemm_packed(a,packed,c,M,N,K,(enum vdot_gemm_method)method)) BAD();
        for (size_t i = 0; i < M; i++) {
            for (size_t j = 0; j < N; j++) {
                int64_t expected = 0;
                for (size_t q = 0; q < K; q++) expected += (int64_t)a[i*K+q]*(int64_t)b[q*N+j];
                if ((uint32_t)c[i*N+j] != (uint32_t)expected) mismatches++;
            }
        }
    }
    register uint64_t a0 __asm__("a0") = M;
    register uint64_t a1 __asm__("a1") = N;
    register uint64_t a2 __asm__("a2") = K;
    register uint64_t a3 __asm__("a3") = 2;
    register uint64_t a4 __asm__("a4") = M*N*2;
    register uint64_t a5 __asm__("a5") = 1;
    register uint64_t a6 __asm__("a6") = mismatches;
    register uint64_t a7 __asm__("a7") = mismatches == 0;
    __asm__ volatile("" : : "r"(a0),"r"(a1),"r"(a2),"r"(a3),"r"(a4),"r"(a5),"r"(a6),"r"(a7));
    if (mismatches) BAD();
    OK();
}
