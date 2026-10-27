
#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cosim_layout.h"

int main(int argc, char **argv) {
  setvbuf(stdout, NULL, _IONBF, 0);
  setvbuf(stderr, NULL, _IONBF, 0);
  if (argc != 6) { fprintf(stderr, "usage: lib image ok bad max_instr\n"); return 2; }
  void *h = dlopen(argv[1], RTLD_NOW | RTLD_GLOBAL);
  if (!h) { fprintf(stderr, "dlopen: %s\n", dlerror()); return 3; }
  void (*init2)(unsigned) = dlsym(h, "difftest_init_v2");
  void (*setramsize)(size_t) = dlsym(h, "difftest_set_ramsize");
  void (*mem)(uint64_t, void *, size_t, int) = dlsym(h, "difftest_memcpy");
  void (*reg)(void *, int) = dlsym(h, "difftest_regcpy");
  void (*step)(uint64_t) = dlsym(h, "difftest_exec");
  unsigned *size = dlsym(h, "DIFFTEST_REG_SIZE");
  if (!init2 || !mem || !reg || !step || !size || !setramsize) { fprintf(stderr, "missing difftest symbols\n"); return 3; }
  if (*size != OFF_END) { fprintf(stderr, "state size %u != %u\n", *size, (unsigned)OFF_END); return 3; }
  
  setramsize(0x08000000ULL);
  init2(OFF_END);
  FILE *f = fopen(argv[2], "rb"); if (!f) { perror("fopen"); return 4; }
  fseek(f, 0, SEEK_END); long len = ftell(f); rewind(f);
  if (len <= 0 || len > 32 * 1024 * 1024) return 4;
  void *image = malloc(len);
  if (!image || fread(image, 1, len, f) != (size_t)len) return 4;
  fclose(f);
  mem(0x80000000, image, len, 1);
  free(image);
  uint8_t blob[OFF_END];
  reg(blob, 0);
  memset(blob + OFF_GPR, 0, 32 * 8);
  uint64_t mode = 3, pc = 0x80000000, status = 3ULL << 9;
  memcpy(blob + OFF_MODE, &mode, 8);
  memcpy(blob + OFF_PC, &pc, 8);
  memcpy(blob + OFF_MSTATUS, &status, 8);
  reg(blob, 1);
  uint64_t ok = strtoull(argv[3], 0, 0), bad = strtoull(argv[4], 0, 0);
  uint64_t limit = strtoull(argv[5], 0, 0);
  for (uint64_t i = 0; i < limit; i++) {
    step(1);
    reg(blob, 0);
    memcpy(&pc, blob + OFF_PC, 8);
    if (pc == bad || pc == ok) {
      printf("IMAGE_%s pc=0x%llx instructions=%llu\n", pc == ok ? "PASS" : "FAIL",
             (unsigned long long)pc, (unsigned long long)(i + 1));
      printf("GPR");
      for (int k = 0; k < 8; k++) {
        uint64_t v; memcpy(&v, blob + OFF_GPR + 8 * (10 + k), 8);
        printf(" %llx", (unsigned long long)v);
      }
      printf("\n");
      return pc == ok ? 0 : 1;
    }
  }
  printf("IMAGE TIMEOUT pc=0x%llx\n", (unsigned long long)pc);
  return 5;
}
