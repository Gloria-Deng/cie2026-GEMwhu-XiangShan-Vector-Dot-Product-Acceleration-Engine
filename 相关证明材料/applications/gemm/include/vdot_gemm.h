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
