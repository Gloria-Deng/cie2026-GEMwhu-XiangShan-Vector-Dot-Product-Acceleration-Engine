















#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <stdint.h>

static void try_mmap(const char *name, size_t len) {
  void *p = mmap(NULL, len, PROT_READ | PROT_WRITE,
                 MAP_ANONYMOUS | MAP_PRIVATE | MAP_NORESERVE, -1, 0);
  printf("%-22s len=0x%zx (%.3f GiB) -> ptr=%p", name, len,
         (double)len / (1024.0 * 1024 * 1024), p);
  if (p == MAP_FAILED) {
    printf("  MAP_FAILED errno=%d (%s)", errno, strerror(errno));
  } else if (p == NULL) {
    printf("  NULL  <-- would also pass NEMU's `if (!pmem)` guard");
  } else {

    ((unsigned char *)p)[0] = 0xAB;
    printf("  ok, touched byte 0 -> %02x", ((unsigned char *)p)[0]);
  }
  printf("\n");
  fflush(stdout);
}

int main(void) {
  try_mmap("64 MiB (arm)", (size_t)0x4000000);
  try_mmap("MSIZE (certified)", (size_t)0x7ff80000000ULL);
  try_mmap("2 GiB", (size_t)0x80000000);
  printf("MAP_FAILED == (void*)%p, so `if (!pmem)` cannot detect it: %s\n",
         MAP_FAILED, MAP_FAILED != NULL ? "YES (guard is ineffective)" : "no");
  return 0;
}
