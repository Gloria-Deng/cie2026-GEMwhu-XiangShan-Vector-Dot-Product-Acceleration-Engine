












#ifndef EMU_SHIM_SYS_MMAN_H
#define EMU_SHIM_SYS_MMAN_H

#include <stddef.h>
#include <stdint.h>
#include <winsock2.h>
#include <windows.h>
#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef long off_t_emu;
#ifndef MAP_FAILED
#define MAP_FAILED ((void *)-1)
#endif
#define PROT_NONE  0
#define PROT_READ  1
#define PROT_WRITE 2
#define PROT_EXEC  4
#define MAP_SHARED    0x01
#define MAP_PRIVATE   0x02
#define MAP_ANONYMOUS 0x20
#define MAP_ANON      MAP_ANONYMOUS
#define MAP_FIXED     0x10
#define MADV_NORMAL   0
#define MADV_SEQUENTIAL 2

static inline int emu_shim_prot(int prot) {
  if ((prot & (PROT_READ | PROT_WRITE)) == (PROT_READ | PROT_WRITE)) return PAGE_READWRITE;
  if (prot & PROT_WRITE) return PAGE_READWRITE;
  if (prot & PROT_READ) return PAGE_READONLY;
  return PAGE_NOACCESS;
}

static inline void *mmap(void *addr, size_t length, int prot, int flags, int fd,
                         off_t_emu offset) {
  (void)addr; (void)flags;
  if (fd >= 0) return MAP_FAILED;
  if (offset != 0) return MAP_FAILED;
  void *p = VirtualAlloc(NULL, length, MEM_COMMIT | MEM_RESERVE, emu_shim_prot(prot));
  return p ? p : MAP_FAILED;
}

static inline int munmap(void *addr, size_t length) {
  (void)length;
  return VirtualFree(addr, 0, MEM_RELEASE) ? 0 : -1;
}

static inline int mprotect(void *addr, size_t length, int prot) {
  DWORD old = 0;
  return VirtualProtect(addr, length, emu_shim_prot(prot), &old) ? 0 : -1;
}

static inline int msync(void *addr, size_t length, int flags) {
  (void)addr; (void)length; (void)flags; return 0;
}

static inline int madvise(void *addr, size_t length, int advice) {
  (void)addr; (void)length; (void)advice; return 0;
}

#ifdef __cplusplus
}
#endif

#endif
