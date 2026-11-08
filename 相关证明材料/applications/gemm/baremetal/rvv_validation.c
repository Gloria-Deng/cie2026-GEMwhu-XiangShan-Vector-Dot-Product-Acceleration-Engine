#include "rvv_gemm.h"

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
