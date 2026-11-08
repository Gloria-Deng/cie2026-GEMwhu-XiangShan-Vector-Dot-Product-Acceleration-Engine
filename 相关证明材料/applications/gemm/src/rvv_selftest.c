#include "rvv_gemm.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static uint32_t state = 20261029u;
static int8_t value(void)
{
    state ^= state << 13; state ^= state >> 17; state ^= state << 5;
    return (int8_t)state;
}

static int shape(size_t m, size_t n, size_t k, int pattern)
{
    size_t count = m*n, bytes = vdot_gemm_pack_bytes(n,k);
    int8_t *a = malloc(m && k ? m*k : 1), *b = malloc(k && n ? k*n : 1);
    int8_t *packed = malloc(bytes ? bytes : 1);
    int32_t *c = malloc((count+2)*sizeof *c), *expected = malloc((count ? count : 1)*sizeof *c);
    if (!a || !b || !packed || !c || !expected) return 1;
    for (size_t i=0;i<m*k;i++) a[i] = pattern == 1 ? -128 : pattern == 2 ? 127 : value();
    for (size_t i=0;i<k*n;i++) b[i] = pattern ? -128 : value();
    if (vdot_gemm_reference(a,b,expected,m,n,k)) return 2;
    for (int method=0;method<2;method++) {
        enum rvv_gemm_method which = (enum rvv_gemm_method)method;
        size_t required = method ? n*k : bytes;
        if (required && rvv_gemm_pack_b(b,n,k,packed,required-1,which) != -2) return 3;
        if (rvv_gemm_pack_b(b,n,k,packed,bytes,which)) return 4;
        c[0] = INT32_C(0x13579bdf); c[count+1] = INT32_C(0x2468ace0);
        memset(c+1,0xa5,count*sizeof *c);
        if (rvv_gemm_packed(a,packed,c+1,m,n,k,which)) return 5;
        if (c[0]!=INT32_C(0x13579bdf) || c[count+1]!=INT32_C(0x2468ace0)) return 6;
        for (size_t i=0;i<count;i++) if (c[i+1]!=expected[i]) return 7;
        if (!method && (vdot_gemm_packed(a,packed,c+1,m,n,k,VDOT_GEMM_MOVX) ||
                       memcmp(c+1,expected,count*sizeof *c))) return 8;
    }
    free(a); free(b); free(packed); free(c); free(expected);
    return 0;
}

int main(void)
{
    size_t cases=0;
    for (size_t m=1;m<=4;m++) for (size_t n=1;n<=9;n++) for (size_t k=0;k<=41;k++) {
        int result=shape(m,n,k,0);
        if (result) { printf("FAIL %zu %zu %zu reason=%d\n",m,n,k,result); return 1; }
        cases++;
    }
    for (int p=1;p<=2;p++) {
        if (shape(3,5,13,p) || shape(1,1,131073,p)) return 1;
        cases+=2;
    }
    int32_t out=1; int8_t one=1;
    for (int method=0;method<2;method++) {
        enum rvv_gemm_method which=(enum rvv_gemm_method)method;
        if (rvv_gemm_packed(NULL,NULL,&out,1,1,0,which) || out) return 1;
        if (rvv_gemm_packed(NULL,NULL,NULL,0,1,1,which)) return 1;
        if (rvv_gemm_packed(&one,&one,&out,SIZE_MAX,2,1,which) != -1) return 1;
        if (rvv_gemm_pack_b(&one,SIZE_MAX,2,&one,SIZE_MAX,which) != -1) return 1;
        if (rvv_gemm_packed(&one,&one,&out,1,1,SIZE_MAX,which) != -1) return 1;
    }
    if (rvv_gemm_packed(&one,&one,&out,1,1,1,(enum rvv_gemm_method)9) != -1) return 1;
    int8_t a[8],b[8]; uint32_t full[4];
    for (int p=0;p<3;p++) {
        int32_t expected=0;
        for (int i=0;i<8;i++) { a[i]=p==0?-128:p==1?127:value(); b[i]=p<2?-128:value(); expected+=(int32_t)a[i]*b[i]; }
        memset(full,0xa5,sizeof full);
        rvv_gemm_dot8_full(a,b,full);
        if (full[0]!=(uint32_t)expected || full[1] || full[2] || full[3]) return 1;
    }
    printf("RVV_GEMM_PASS backend=%s shapes=%zu methods=2 full_register=3\n",rvv_gemm_backend(),cases);
    return 0;
}
