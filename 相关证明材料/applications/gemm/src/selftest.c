#include "vdot_gemm.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static uint32_t state = 20261025u;
static int8_t value(void)
{
    state ^= state << 13; state ^= state >> 17; state ^= state << 5;
    return (int8_t)state;
}

static int check_shape(size_t m, size_t n, size_t k, int pattern)
{
    size_t count = m*n, bytes = vdot_gemm_pack_bytes(n,k);
    int8_t *a = malloc(m && k ? m*k : 1), *b = malloc(k && n ? k*n : 1);
    int8_t *packed = malloc(bytes ? bytes : 1);
    int32_t *c = malloc((count+2)*sizeof *c);
    if (!a || !b || !packed || !c) return 1;
    for (size_t i = 0; i < m*k; i++) a[i] = pattern == 1 ? -128 : pattern == 2 ? 127 : value();
    for (size_t i = 0; i < k*n; i++) b[i] = pattern == 1 ? -128 : pattern == 2 ? -128 : value();
    if (bytes && vdot_gemm_pack_b(b,n,k,packed,bytes-1) != -2) return 2;
    if (vdot_gemm_pack_b(b,n,k,packed,bytes)) return 3;
    size_t stride = (k+7)&~(size_t)7;
    for (size_t j = 0; j < n; j++)
        for (size_t q = 0; q < stride; q++)
            if (packed[j*stride+q] != (q<k ? b[q*n+j] : 0)) return 4;
    for (int method = 0; method < 2; method++) {
        c[0] = INT32_C(0x13579bdf); c[count+1] = INT32_C(0x2468ace0);
        memset(c+1,0xa5,count*sizeof *c);
        if (vdot_gemm_packed(a,packed,c+1,m,n,k,(enum vdot_gemm_method)method)) return 5;
        if (c[0] != INT32_C(0x13579bdf) || c[count+1] != INT32_C(0x2468ace0)) return 6;
        for (size_t i = 0; i < m; i++) {
            for (size_t j = 0; j < n; j++) {
                int64_t expected = 0;
                for (size_t q = 0; q < k; q++) expected += (int64_t)a[i*k+q]*(int64_t)b[q*n+j];
                if ((uint32_t)c[1+i*n+j] != (uint32_t)expected) return 7;
            }
        }
    }
    free(a); free(b); free(packed); free(c);
    return 0;
}

int main(void)
{
    size_t cases = 0;
    for (size_t m = 1; m <= 4; m++) {
        for (size_t n = 1; n <= 9; n++) {
            for (size_t k = 0; k <= 41; k++) {
                int result = check_shape(m,n,k,0);
                if (result) { printf("FAIL m=%zu n=%zu k=%zu reason=%d\n",m,n,k,result); return 1; }
                cases++;
            }
        }
    }
    for (int pattern = 1; pattern <= 2; pattern++) {
        if (check_shape(3,5,13,pattern) || check_shape(1,1,131073,pattern)) return 1;
        cases += 2;
    }
    int32_t c;
    int8_t one = 1;
    if (vdot_gemm_pack_bytes(SIZE_MAX,9) || vdot_gemm_pack_bytes(1,SIZE_MAX)) return 1;
    if (vdot_gemm_pack_b(NULL,1,1,&one,1) != -1) return 1;
    if (vdot_gemm_packed(&one,&one,&c,1,1,1,(enum vdot_gemm_method)9) != -1) return 1;
    if (vdot_gemm_packed(NULL,NULL,&c,1,1,0,VDOT_GEMM_MOVX) || c) return 1;
    if (vdot_gemm_packed(NULL,NULL,NULL,0,1,1,VDOT_GEMM_MOVX)) return 1;
    printf("GEMM_API_PASS backend=%s shapes=%zu methods=2\n",vdot_gemm_backend(),cases);
    return 0;
}
