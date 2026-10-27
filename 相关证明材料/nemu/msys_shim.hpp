
























#ifndef NEMU_SHIM_HPP
#define NEMU_SHIM_HPP

#if defined(__cplusplus)

#include <cerrno>
#include <cstddef>

inline void sync() { errno = 0; }

inline int mincore(void *, size_t, unsigned char *) {
  errno = ENOSYS;
  return -1;
}

#endif

#endif
