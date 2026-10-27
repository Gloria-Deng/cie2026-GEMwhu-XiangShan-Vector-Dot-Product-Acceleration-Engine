// nemu_shim.hpp -- BUILD-COPY-ONLY host portability shim for MSYS2.
//
// Injected with  CXX='g++ -include /d/nemu_shim.hpp'  so that no file inside the
// NEMU tree, and no file in the delivery, is edited for this.  It supplies two
// POSIX entry points Linux has and the MSYS runtime does not, at global scope,
// which is where NEMU's unqualified calls resolve to.
//
//   sync()    -- src/base/output.cpp:340 calls it between directory removals.
//                POSIX sync() flushes all buffers; the surrounding code only
//                wants the filesystem to notice deleted entries.  A no-op is
//                behaviourally weaker but cannot corrupt the simulator.
//
//   mincore() -- src/checkpoint/serializer.cpp:177 asks which pages of the
//                guest image are resident to size a checkpoint.  Its caller does
//                `if (mincore(...) != 0) { free(vec); return offset; }`, i.e. a
//                non-zero return is the already-written safe fallback.  So
//                returning -1/ENOSYS takes an existing error path, not an
//                invented one.  Checkpointing is not on the vdot path at all.
//
// Everything is inside #ifdef __cplusplus: this header is also reachable from C
// translation units through the shared -include, and <cerrno> is C++-only.
//
// Neither stub is on the path that executes vdot; they exist so the difftest
// shared library compiles and links on this host.  That is checked by the build
// artifacts recorded in docs/05, not by this comment.
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

#endif  // __cplusplus

#endif  // NEMU_SHIM_HPP
