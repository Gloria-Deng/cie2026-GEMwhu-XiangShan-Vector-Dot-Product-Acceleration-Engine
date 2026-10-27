


















#include <stdio.h>
#include <stdint.h>
#include "vdot_vv.h"

struct dir_case {
    const char *name;
    int8_t a[8];
    int8_t b[8];
    int32_t want;
};

static const struct dir_case dir_cases[] = {
    {"all_minus128_times_minus128",
     {-128,-128,-128,-128,-128,-128,-128,-128},
     {-128,-128,-128,-128,-128,-128,-128,-128}, 8 * 16384},
    {"all_minus128_times_plus127",
     {-128,-128,-128,-128,-128,-128,-128,-128},
     {127,127,127,127,127,127,127,127}, 8 * -16256},
    {"all_zero", {0,0,0,0,0,0,0,0}, {0,0,0,0,0,0,0,0}, 0},
    {"plus_and_minus_128_boundary",
     {127,-128,127,-128,127,-128,127,-128},
     {-128,127,-128,127,-128,127,-128,127},
     4 * (127 * -128) + 4 * (-128 * 127)},
    {"single_lane_hot",
     {1,0,0,0,0,0,0,0}, {37,0,0,0,0,0,0,0}, 37},
};

#define DIR_N (sizeof(dir_cases) / sizeof(dir_cases[0]))

int main(void)
{
    int failures = 0;
    int cases = 0;

    for (unsigned c = 0; c < DIR_N; c++) {
        const struct dir_case *d = &dir_cases[c];
        int32_t r1 = vdot_vv_ref(d->a, d->b);
        int32_t r2 = vdot_vv_alt(d->a, d->b);
        cases++;
        if (r1 != d->want || r2 != d->want) {
            printf("DIR-FAIL case=%u ref=%d alt=%d want=%d\n",
                   c, (int)r1, (int)r2, (int)d->want);
            failures++;
        }
    }
    printf("DIRECTED directed=%u mismatches=%d\n",
           (unsigned)DIR_N, failures);

    long n_in = 0;
    int v[16];
    while (scanf("%d", &v[0]) == 1) {
        int ok = 1;
        for (int k = 1; k < 16; k++) {
            if (scanf("%d", &v[k]) != 1) { ok = 0; break; }
        }
        if (!ok)
            break;
        int8_t a[8], b[8];
        for (int k = 0; k < 8; k++) {
            a[k] = (int8_t)v[k];
            b[k] = (int8_t)v[k + 8];
        }
        int32_t r1 = vdot_vv_ref(a, b);
        int32_t r2 = vdot_vv_alt(a, b);
        printf("CASE %ld %d %d\n", n_in, (int)r1, (int)r2);
        if (r1 != r2)
            failures++;
        n_in++;
    }

    printf("STREAM cases=%ld mismatches=%d\n", n_in, failures);
    if (failures == 0)
        printf("VDOT-SELFTEST VERDICT PASS\n");
    else
        printf("VDOT-SELFTEST VERDICT FAIL\n");
    return failures == 0 ? 0 : 1;
}
