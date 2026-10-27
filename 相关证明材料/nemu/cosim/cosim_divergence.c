






















#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>

#include "cosim_layout.h"

typedef void (*fn_init_t)(unsigned state_size);
typedef void (*fn_void_t)(void);
typedef void (*fn_memcpy_t)(uint64_t dest, void *src, size_t n, int direction);
typedef void (*fn_regcpy_t)(void *buf, int direction);
typedef void (*fn_exec_t)(uint64_t n);

#define DIFFTEST_TO_DUT 0
#define DIFFTEST_TO_REF 1
#define CONFIG_MBASE_G  0x80000000ull
#define CODE_ADDR       (CONFIG_MBASE_G + 0x200)

#define FUNCT6_VDOT 0b101100
#define OP_V        0b1010111
#define FUNCT3_VV   0b010

#define VS1_REG 5
#define VS2_REG 2
#define VD_REG  4

static uint32_t encode_vv(int vd, int vs1, int vs2, int vm) {
  return ((uint32_t)FUNCT6_VDOT << 26) | ((uint32_t)(vm & 1) << 25)
       | ((uint32_t)vs2 << 20) | ((uint32_t)vs1 << 15)
       | ((uint32_t)FUNCT3_VV << 12) | ((uint32_t)vd << 7) | OP_V;
}
#define W_VSETIVLI_E8 0xcc047057u

static uint8_t blob[OFF_END];
static fn_memcpy_t mem_cpy;
static fn_regcpy_t reg_cpy;
static fn_exec_t exec_n;

static char phase_buf[48];
static void say(const char *what) {
  snprintf(phase_buf, sizeof phase_buf, "%s", what);
  printf("  phase: %s\n", what); fflush(stdout);
}

static void put64(size_t off, uint64_t v) { memcpy(blob + off, &v, 8); }
static uint64_t get64(size_t off) { uint64_t v; memcpy(&v, blob + off, 8); return v; }
static uint8_t *vr(int r) { return blob + OFF_VR + VR_STRIDE * r; }
static uint32_t lane0_of(int r) {
  const uint8_t *p = vr(r);
  return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16)
       | ((uint32_t)p[3] << 24);
}
static int bytes_all(int r, uint8_t v) {
  for (int i = 0; i < 16; i++) if (vr(r)[i] != v) return 0;
  return 1;
}

static void seed(uint64_t vstart) {
  memset(blob, 0, sizeof blob);
  for (int r = 0; r < 32; r++) memset(vr(r), 0xa5, 16);
  for (int i = 0; i < 8; i++) { vr(VS1_REG)[i] = 17; vr(VS2_REG)[i] = (uint8_t)(i + 1); }
  for (int i = 8; i < 16; i++) { vr(VS1_REG)[i] = 0; vr(VS2_REG)[i] = 0; }
  put64(OFF_MODE, 3);
  put64(OFF_MSTATUS, (uint64_t)3 << 9);
  put64(OFF_PC, CODE_ADDR);
  put64(OFF_VSTART, vstart);
  put64(OFF_VTYPE, 0);
  put64(OFF_VL, 8);
}

static const char *TAG = "tree";
static const char *cur_arm = "?";









static void arm(const char *name, int vm, uint64_t vstart) {
  cur_arm = name;
  uint32_t w0 = W_VSETIVLI_E8, w1 = encode_vv(VD_REG, VS1_REG, VS2_REG, vm);
  uint32_t rb = 0;
  printf("== arm %s/%s vm=%d vstart=%llu ==\n", TAG, name, vm, (unsigned long long)vstart);
  fflush(stdout);
  seed(vstart);
  say("mem_cpy write vsetivli");
  mem_cpy(CODE_ADDR, &w0, 4, DIFFTEST_TO_REF);
  say("mem_cpy write vdot");
  mem_cpy(CODE_ADDR + 4, &w1, 4, DIFFTEST_TO_REF);
  say("readback vsetivli");
  mem_cpy(CODE_ADDR, &rb, 4, DIFFTEST_TO_DUT);
  if (rb != w0) { printf("ARM %s %s verdict=SETUP-FAIL vsetivli not in memory (0x%08x)\n",
                         TAG, name, rb); return; }
  rb = 0;
  say("readback vdot");
  mem_cpy(CODE_ADDR + 4, &rb, 4, DIFFTEST_TO_DUT);
  if (rb != w1) { printf("ARM %s %s verdict=SETUP-FAIL vdot word not in memory (0x%08x)\n",
                         TAG, name, rb); return; }
  say("reg_cpy push state");
  reg_cpy(blob, DIFFTEST_TO_REF);
  uint64_t pc_setup0 = get64(OFF_PC);
  say("exec vsetivli");
  exec_n(1);
  reg_cpy(blob, DIFFTEST_TO_DUT);
  uint64_t pc_cfg = get64(OFF_PC);
  if (pc_cfg != pc_setup0 + 4) {
    printf("ARM %s %s verdict=SETUP-FAIL vsetivli did not retire (pc 0x%llx -> 0x%llx)\n",
           TAG, name, (unsigned long long)pc_setup0, (unsigned long long)pc_cfg);
    return;
  }
  uint64_t pc_before = get64(OFF_PC);
  int vd_untouched = bytes_all(VD_REG, 0xa5);
  say("exec vdot");
  exec_n(1);
  reg_cpy(blob, DIFFTEST_TO_DUT);
  uint64_t pc_after = get64(OFF_PC);
  put64(OFF_PC, pc_after);
  int advanced = (pc_after == pc_before + 4);
  int vd_written = !bytes_all(VD_REG, 0xa5);
  printf("ARM %s %s enc=0x%08x vm=%d vstart=%llu word=%s pc=%llx->%llx retired=%s "
         "vd_untouched_before=%d vd_written=%s vd_lane0=0x%x expected_lane0=0x%x "
         "vstart_now=%llu mode=%llu\n",
         TAG, name, w1, vm, (unsigned long long)vstart,
         (w1 == encode_vv(VD_REG, VS1_REG, VS2_REG, 1)) ? "vm1" : "vm0-or-vstart",
         (unsigned long long)pc_before, (unsigned long long)pc_after,
         advanced ? "yes" : "NO", vd_untouched, vd_written ? "yes" : "NO",
         lane0_of(VD_REG), 17u * (1 + 2 + 3 + 4 + 5 + 6 + 7 + 8),
         (unsigned long long)get64(OFF_VSTART), (unsigned long long)get64(OFF_MODE));
}

static volatile int g_ok = 0;
static void on_signal(int sig) {


  printf("ARM %s %s retired=SEGV rc=%d signal_seen=yes\n", TAG, cur_arm, 90 + sig);
  fflush(stdout);
  _exit(0);
}

int main(int argc, char **argv) {
  const char *dll = (argc > 1) ? argv[1]
                  : "/d/nemu-vx/build/riscv64-nemu-interpreter-so.exe";




  TAG = (argc > 2) ? argv[2] : "tree";
  setvbuf(stdout, NULL, _IONBF, 0);
  signal(SIGABRT, on_signal); signal(SIGSEGV, on_signal); signal(SIGFPE, on_signal);

  void *h = dlopen(dll, RTLD_NOW | RTLD_GLOBAL);
  if (!h) { printf("SETUP-FAIL dlopen: %s\n", dlerror()); return 2; }
  void *p_init2 = dlsym(h, "difftest_init_v2");
  void *p_init0 = dlsym(h, "difftest_init");
  mem_cpy = (fn_memcpy_t)dlsym(h, "difftest_memcpy");
  reg_cpy = (fn_regcpy_t)dlsym(h, "difftest_regcpy");
  exec_n  = (fn_exec_t)dlsym(h, "difftest_exec");
  const unsigned *reg_size = (const unsigned *)dlsym(h, "DIFFTEST_REG_SIZE");
  if (!mem_cpy || !reg_cpy || !exec_n || (!p_init2 && !p_init0)) {
    printf("SETUP-FAIL: a required difftest symbol is missing in %s\n", dll); return 2;
  }
  printf("LIBRARY %s DIFFTEST_REG_SIZE=%s OFF_END=%zu\n", dll,
         reg_size ? "" : "none", (size_t)OFF_END);
  if (!reg_size) { printf("SETUP-FAIL no DIFFTEST_REG_SIZE export\n"); return 2; }
  printf("LIBRARY size=%u layout_off_end=%zu agree=%s\n", *reg_size, (size_t)OFF_END,
         (*reg_size == (unsigned)OFF_END) ? "yes" : "NO");
  if (*reg_size != (unsigned)OFF_END) {
    printf("SETUP-FAIL LAYOUT MISMATCH: refusing to read state at offsets from another "
           "struct definition\n"); return 4;
  }
  say("difftest_init");
  if (p_init2) ((fn_init_t)p_init2)((unsigned)OFF_END);
  else ((fn_void_t)p_init0)();
  say("difftest_init returned");












  arm("ctrl", 1, 0);
  arm("vm0", 0, 0);
  arm("vstart4", 1, 4);
  const char *want = "all";
  (void)want;
  printf("COSIM_DIV done arm=%s\n", want);
  return 0;
}
