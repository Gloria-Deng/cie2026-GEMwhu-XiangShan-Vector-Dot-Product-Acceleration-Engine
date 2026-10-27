#include "vdot_gemm.h"
#include <stdio.h>

int main(void)
{
    enum { M = 3, N = 5, K = 13, STRIDE = 16 };
    int8_t a[M*K], b[K*N], packed[N*STRIDE];
    int32_t reference[M*N], output[M*N];
    for (size_t i = 0; i < M*K; i++) a[i] = (int8_t)((i*17u+11u)%256u-128u);
    for (size_t i = 0; i < K*N; i++) b[i] = (int8_t)((i*13u+97u)%256u-128u);
    if (vdot_gemm_reference(a,b,reference,M,N,K) || vdot_gemm_pack_b(b,N,K,packed,sizeof packed)) return 1;
    for (int method = 0; method < 2; method++) {
        if (vdot_gemm_packed(a,packed,output,M,N,K,(enum vdot_gemm_method)method)) return 1;
        for (size_t i = 0; i < M*N; i++) if (output[i] != reference[i]) return 1;
    }
    printf("backend=%s M=%d N=%d K=%d packed_stride=%d\n",vdot_gemm_backend(),M,N,K,STRIDE);
    for (size_t i = 0; i < M; i++) {
        for (size_t j = 0; j < N; j++) printf("%s%d",j?" ":"",(int)output[i*N+j]);
        printf("\n");
    }
    printf("GEMM_DEMO_PASS methods=2\n");
    return 0;
}
