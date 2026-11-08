#ifndef RVV_GEMM_H
#define RVV_GEMM_H
#include "vdot_gemm.h"

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
