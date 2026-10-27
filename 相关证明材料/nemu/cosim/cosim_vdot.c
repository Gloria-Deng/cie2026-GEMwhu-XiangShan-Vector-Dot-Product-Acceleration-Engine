





















#include <dlfcn.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>

#include "cosim_layout.h"







static char last_phase[64] = "start";
static void on_signal(int sig) {
  fprintf(stderr, "DIED-IN-SIGNAL %d during phase [%s]\n", sig, last_phase);
  fflush(stderr); fflush(stdout);
  _exit(90 + sig);
}
static void on_exit_cb(void) {
  fprintf(stderr, "EXIT-CALLBACK during phase [%s]\n", last_phase);
  fflush(stderr); fflush(stdout);
}
static void phase(const char *p) {
  snprintf(last_phase, sizeof last_phase, "%s", p);
  fflush(stdout);
}


#define VS2_REG 9
#define VS1_REG 8
#define VD_REG  1
static uint32_t encode_vdot(void) {
  return ((uint32_t)0b101100 << 26) | (1u << 25)
       | ((uint32_t)VS2_REG << 20) | ((uint32_t)VS1_REG << 15)
       | ((uint32_t)0b010 << 12) | ((uint32_t)VD_REG << 7) | 0b1010111;
}

typedef void (*fn_init_t)(unsigned state_size);
typedef void (*fn_void_t)(void);
typedef void (*fn_memcpy_t)(uint64_t dest, void *src, size_t n, int direction);
typedef void (*fn_regcpy_t)(void *buf, int direction);
typedef void (*fn_exec_t)(uint64_t n);












#define DIFFTEST_TO_DUT 0
#define DIFFTEST_TO_REF 1







#define CONFIG_MBASE_G 0x80000000ull
#define CODE_ADDR      (CONFIG_MBASE_G + 0x200)

static uint8_t blob[OFF_END];
static fn_memcpy_t mem_cpy;
static fn_regcpy_t reg_cpy;
static fn_exec_t exec_n;

static void put64(size_t off, uint64_t v) { memcpy(blob + off, &v, 8); }
static uint64_t get64(size_t off) { uint64_t v; memcpy(&v, blob + off, 8); return v; }

static void seed(uint64_t pc, const uint8_t *vs1, const uint8_t *vs2) {
  memset(blob, 0, sizeof blob);
  put64(OFF_MODE, 3);
  put64(OFF_MSTATUS, (uint64_t)3 << 9);
  put64(OFF_PC, pc);
  put64(OFF_VSTART, 0);
  put64(OFF_VTYPE, 0);
  put64(OFF_VL, 8);
  memcpy(blob + OFF_VR + VR_STRIDE * VS1_REG, vs1, 16);
  memcpy(blob + OFF_VR + VR_STRIDE * VS2_REG, vs2, 16);
}

static void run_one(void) {
  reg_cpy(blob, DIFFTEST_TO_REF);
  exec_n(1);
  reg_cpy(blob, DIFFTEST_TO_DUT);
}

static int hex_to_bytes(const char *s, uint8_t *out, int n) {
  if ((int)strlen(s) != n * 2) return 0;
  for (int i = 0; i < n; i++) {
    char b[3] = { s[2*i], s[2*i+1], 0 };
    char *e;
    long v = strtol(b, &e, 16);
    if (*e) return 0;
    out[i] = (uint8_t)v;
  }
  return 1;
}

int main(int argc, char **argv) {
  const char *dll = (argc > 1) ? argv[1]
      : "/d/nemu-vdot/build/riscv64-nemu-interpreter-so.exe";
  const char *cases = (argc > 2) ? argv[2] : "/d/nemu_cosim/cases.txt";
  int inject = (argc > 3 && strcmp(argv[3], "--inject-bug") == 0);





  setvbuf(stdout, NULL, _IONBF, 0);
  signal(SIGABRT, on_signal);
  signal(SIGSEGV, on_signal);
  signal(SIGFPE,  on_signal);
  atexit(on_exit_cb);

  void *h = dlopen(dll, RTLD_NOW | RTLD_GLOBAL);
  if (!h) { printf("SETUP-FAIL dlopen: %s\n", dlerror()); return 2; }




  void *p_init2 = dlsym(h, "difftest_init_v2");
  void *p_init0 = dlsym(h, "difftest_init");
  if (!p_init2 && !p_init0) {
    printf("SETUP-FAIL: neither difftest_init_v2 nor difftest_init is exported\n");
    return 2;
  }
  mem_cpy = (fn_memcpy_t)dlsym(h, "difftest_memcpy");
  reg_cpy = (fn_regcpy_t)dlsym(h, "difftest_regcpy");
  exec_n  = (fn_exec_t)  dlsym(h, "difftest_exec");
  const unsigned *reg_size = (const unsigned *)dlsym(h, "DIFFTEST_REG_SIZE");
  if (!mem_cpy || !reg_cpy || !exec_n || !reg_size) {
    printf("SETUP-FAIL: a required symbol is missing\n"); return 2;
  }
  printf("library DIFFTEST_REG_SIZE=%u, header OFF_END=%zu, STATE_SIZE=%zu\n",
         *reg_size, (size_t)OFF_END, (size_t)STATE_SIZE);
  if (*reg_size != (unsigned)OFF_END) {



    printf("LAYOUT MISMATCH: refusing to run with offsets from a different blob\n");
    return 4;
  }

  phase("difftest_init");
  if (p_init2) ((fn_init_t)p_init2)((unsigned)OFF_END);
  else         ((fn_void_t)p_init0)();
  printf("... difftest_init returned\n"); fflush(stdout);




  memset(blob, 0, sizeof blob);
  uint32_t word = encode_vdot();
  uint64_t pc = CODE_ADDR;



  phase("mem_cpy write");
  printf("placing 0x%08x at guest addr 0x%lx ...\n", word, (unsigned long)pc);
  fflush(stdout);
  mem_cpy(pc, &word, 4, DIFFTEST_TO_REF);
  phase("mem_cpy readback");
  printf("... placed; reading back ...\n"); fflush(stdout);
  uint32_t readback = 0;
  mem_cpy(pc, &readback, 4, DIFFTEST_TO_DUT);
  printf("... read back 0x%08x\n", readback); fflush(stdout);
  printf("vdot.vv vs2=v%d vs1=v%d vd=v%d encodes to 0x%08x; wrote @0x%lx, read back 0x%08x\n",
         VS2_REG, VS1_REG, VD_REG, word, (unsigned long)pc, readback);
  if (readback != word) {
    printf("CODE NOT IN MEMORY: refusing to run (fetch would decode someone else's "
           "instruction)\n");
    return 6;
  }

  FILE *f = fopen(cases, "r");
  if (!f) { printf("SETUP-FAIL: cannot open %s\n", cases); return 2; }

  char ln[512];
  int total = 0, bad = 0, first_bad = -1;
  int ctrl_pass = 0, ctrl_bad = 0;
  while (fgets(ln, sizeof ln, f)) {
    char a[64], b[64], e[64];
    if (ln[0] == '#' || ln[0] == '\n') continue;
    if (sscanf(ln, "%63s %63s %63s", a, b, e) != 3) continue;
    uint8_t vs1[16], vs2[16];
    if (!hex_to_bytes(a, vs1, 16) || !hex_to_bytes(b, vs2, 16)) {
      printf("SETUP-FAIL: unparsable case line: %s", ln); return 2;
    }
    seed(pc, vs1, vs2);
    if (total == 0) printf("about to exec case 1...\n");
    run_one();
    if (total == 0) printf("...exec returned\n");
    uint8_t vd[16];
    memcpy(vd, blob + OFF_VR + VR_STRIDE * VD_REG, 16);
    uint32_t got = (uint32_t)vd[0] | ((uint32_t)vd[1] << 8)
                 | ((uint32_t)vd[2] << 16) | ((uint32_t)vd[3] << 24);
    int hi_nonzero = 0;
    for (int i = 4; i < 16; i++) if (vd[i]) hi_nonzero = 1;


    uint32_t want = (uint32_t)strtoul(e, NULL, 16);



    int inject_this = inject && (total == 0);
    uint32_t against = inject_this ? (want ^ 0xdeadbeefu) : want;

    total++;
    int mismatch = (got != against) || hi_nonzero || (get64(OFF_PC) != pc + 4);
    if (inject_this) { if (mismatch) ctrl_bad++; else ctrl_pass++; }
    else if (mismatch) {
      bad++;
      if (first_bad < 0) {
        first_bad = total;
        printf("MISMATCH case %d: vs1=%s vs2=%s want=%08x got=%08x "
               "hi_nonzero=%d npc=0x%lx\n", total, a, b,
               (unsigned)want, (unsigned)got, hi_nonzero,
               (unsigned long)get64(OFF_PC));
      }
    }
  }
  fclose(f);

  printf("cases=%d mismatches=%d pc=%s\n", total, bad,
         bad ? "see first MISMATCH above" : "advanced by 4 every case");
  if (inject) {
    printf("POSITIVE CONTROL (expect the comparison to report a mismatch): "
           "detected=%d missed=%d\n", ctrl_bad, ctrl_pass);
    if (ctrl_bad == 0) { printf("NEMU_COSIM BROKEN: comparison never fires\n"); return 5; }
    if (ctrl_pass) { printf("NEMU_COSIM BROKEN: wrong value accepted\n"); return 5; }
    printf("NEMU_COSIM CONTROL PASS\n");
    return 0;
  }
  if (total == 0) { printf("NEMU_COSIM BROKEN: zero cases ran\n"); return 5; }
  printf("NEMU_COSIM %s\n", bad ? "FAIL" : "PASS");
  return bad ? 1 : 0;
}
