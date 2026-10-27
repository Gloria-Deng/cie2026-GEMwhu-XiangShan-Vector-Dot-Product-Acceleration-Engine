







#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "vdot_vv.h"

#define M_DIM 32
#define N_DIM 32
#define K_MAX 512

static int8_t A_buf[M_DIM * K_MAX];
static int8_t B_buf[N_DIM * K_MAX];
static int32_t C_vdot[M_DIM * N_DIM];
static int32_t C_base[M_DIM * N_DIM];

static uint32_t fill_state = 20261008u;

static uint32_t fill_next(void)
{
    uint32_t x = fill_state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    fill_state = x;
    return x;
}

static void fill_buffers(unsigned k)
{
    for (unsigned i = 0; i < M_DIM * k; i++)
        A_buf[i] = (int8_t)(fill_next() % 7u) - 3;
    for (unsigned i = 0; i < N_DIM * k; i++)
        B_buf[i] = (int8_t)(fill_next() % 7u) - 3;
}

static void run_vdot_arm(unsigned k)
{
    for (unsigned m = 0; m < M_DIM; m++) {
        for (unsigned n = 0; n < N_DIM; n++) {
            const int8_t *ar = &A_buf[m * k];
            const int8_t *br = &B_buf[n * k];
            int32_t acc = 0;
            for (unsigned kk = 0; kk < k; kk += 8)
                acc += vdot_vv_ref(&ar[kk], &br[kk]);
            C_vdot[m * N_DIM + n] = acc;
        }
    }
}

static void run_baseline_arm(unsigned k)
{



    for (unsigned m = 0; m < M_DIM; m++) {
        for (unsigned n = 0; n < N_DIM; n++) {
            const int8_t *ar = &A_buf[m * k];
            const int8_t *br = &B_buf[n * k];
            int32_t acc = 0;
            for (unsigned kk = 0; kk < k; kk++)
                acc += (int32_t)((int16_t)ar[kk] * (int16_t)br[kk]);
            C_base[m * N_DIM + n] = acc;
        }
    }
}

int main(void)
{
    static const unsigned ks[] = { 64, 128, 256, 512 };
    int mismatches = 0;

    for (unsigned ki = 0; ki < sizeof(ks) / sizeof(ks[0]); ki++) {
        unsigned k = ks[ki];
        fill_buffers(k);
        run_vdot_arm(k);
        run_baseline_arm(k);
        for (unsigned i = 0; i < M_DIM * N_DIM; i++) {
            if (C_vdot[i] != C_base[i]) {
                printf("GEMM-MISMATCH k=%u idx=%u vdot=%d base=%d\n",
                       k, i, (int)C_vdot[i], (int)C_base[i]);
                mismatches++;
            }
        }
        printf("GEMM-K k=%u cells=%d mismatches=%d\n",
               k, (int)(M_DIM * N_DIM), mismatches);
    }

    if (mismatches == 0)
        printf("GEMM-REF-EQUIV VERDICT PASS\n");
    else
        printf("GEMM-REF-EQUIV VERDICT FAIL\n");
    return mismatches == 0 ? 0 : 1;
}
