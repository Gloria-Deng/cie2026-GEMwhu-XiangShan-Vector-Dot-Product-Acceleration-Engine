












#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

typedef void (*fn_void_t)(void);
typedef void (*fn_memcpy_t)(uint64_t dest, void *src, size_t n, int direction);
typedef void (*fn_regcpy_t)(void *buf, int direction);
typedef void (*fn_exec_t)(uint64_t n);

#define CHECK(x) do { if (!(x)) { printf("MISSING  %s\n", #x); misses++; } \
                      else { printf("resolved %s\n", #x); } } while (0)

int main(int argc, char **argv) {
  const char *path = (argc > 1) ? argv[1]
      : "/d/nemu-vdot/build/riscv64-nemu-interpreter-so.exe";
  printf("dlopen(%s)\n", path);
  void *h = dlopen(path, RTLD_NOW | RTLD_GLOBAL);
  if (!h) {
    printf("DLOPEN-FAIL: %s\n", dlerror());
    return 2;
  }
  printf("dlopen ok\n");

  int misses = 0;
  void *p_init = dlsym(h, "difftest_init");
  void *p_init2 = dlsym(h, "difftest_init_v2");
  void *p_memcpy = dlsym(h, "difftest_memcpy");
  void *p_regcpy = dlsym(h, "difftest_regcpy");
  void *p_exec = dlsym(h, "difftest_exec");
  void *p_size = dlsym(h, "DIFFTEST_REG_SIZE");
  CHECK(p_init || p_init2);
  CHECK(p_memcpy);
  CHECK(p_regcpy);
  CHECK(p_exec);
  CHECK(p_size);
  if (misses) { printf("SMOKE_DLOPEN INCOMPLETE misses=%d\n", misses); return 1; }

  const unsigned *reg_size = (const unsigned *)p_size;
  printf("DIFFTEST_REG_SIZE = %u   (offset probe said sizeof(riscv64_CPU_state)=1752)\n",
         *reg_size);
  if (*reg_size != 1752) {
    printf("SMOKE_DLOPEN MISMATCH -- stop: the harness offsets would be wrong\n");
    return 3;
  }

  ((fn_void_t)(p_init2 ? p_init2 : p_init))();
  printf("difftest_%s() returned\n", p_init2 ? "init_v2" : "init");


  uint8_t st[1752];
  memset(st, 0, sizeof st);
  ((fn_regcpy_t)p_regcpy)(st, 1                        );
  uint64_t pc = *(uint64_t *)(st + 656);
  uint64_t mode = *(uint64_t *)(st + 512);
  uint64_t mstatus = *(uint64_t *)(st + 520);
  uint64_t vtype = *(uint64_t *)(st + 1352);
  uint64_t vl = *(uint64_t *)(st + 1344);
  printf("after init: pc=0x%lx mode=%lu mstatus=0x%lx vtype=0x%lx vl=%lu\n",
         (unsigned long)pc, (unsigned long)mode, (unsigned long)mstatus,
         (unsigned long)vtype, (unsigned long)vl);
  printf("SMOKE_DLOPEN PASS\n");
  dlclose(h);
  return 0;
}
