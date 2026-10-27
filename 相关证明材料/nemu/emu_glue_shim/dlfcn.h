







#ifndef EMU_SHIM_DLFCN_H
#define EMU_SHIM_DLFCN_H

#include <windows.h>

#ifdef __cplusplus
extern "C" {
#endif

#define RTLD_LAZY   0x1
#define RTLD_NOW    0x2
#define RTLD_GLOBAL 0x4
#define RTLD_LOCAL  0x8

typedef void *emu_shim_handle;

static inline void *dlopen(const char *filename, int flag) {
  (void)flag;
  return (void *)LoadLibraryA(filename);
}

static inline void *dlsym(void *handle, const char *name) {
  return (void *)GetProcAddress((HMODULE)handle, name);
}

static inline int dlclose(void *handle) {
  return FreeLibrary((HMODULE)handle) ? 0 : -1;
}

static inline const char *dlerror(void) { return "emu_shim: no error string"; }









#if defined(EMU_SHIM_ALLOW_DLMOPEN) && EMU_SHIM_ALLOW_DLMOPEN
#ifndef RTLD_DEEPBIND
#define RTLD_DEEPBIND 0x20
#endif
#ifndef LM_ID_NEWLM
#define LM_ID_NEWLM   (-1)
#endif
#define dlmopen(lmid, filename, flag) dlopen((filename), (flag))
#endif

#ifdef __cplusplus
}
#endif

#endif
