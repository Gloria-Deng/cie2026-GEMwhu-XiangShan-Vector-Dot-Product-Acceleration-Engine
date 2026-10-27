


























#include <dlfcn.h>
#include <inttypes.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "cosim_layout.h"



#define VS1_REG 1
#define VS2_REG 2

#define I_VMV_VI_V4_0   0x5e003257u
#define I_VWMUL_VV_V6   0xee20a357u
#define I_VSETIVLI_E16  0xcc847057u
#define I_VREDSUM_V4    0x02622257u
#define I_VWREDSUM_V8   0xc6620457u
#define I_VSETIVLI_E16_TU 0xc0847057u
#define I_VWREDSUM_V4     0xc6620257u












#define I_VMV_VI_V6_0   0x5e003357u
#define I_VMV_VI_V7_0   0x5e0033d7u
#define I_VWMACC_V6     0xf6112357u
#define I_VSETIVLI_E16M2 0xcc947057u
#define I_VSETIVLI_E8V16 0xcc087057u

typedef struct { const char *name; uint32_t w[8]; int n; int result_reg;




                 int ra, rb, garbage; } variant_t;
static const variant_t VARIANTS[] = {

  { "doc3",  { I_VMV_VI_V4_0, I_VWMUL_VV_V6, I_VREDSUM_V4, 0 },          3, 4, 1, 2, 0 },


  { "e16",   { I_VMV_VI_V4_0, I_VWMUL_VV_V6, I_VSETIVLI_E16, I_VREDSUM_V4 }, 4, 4, 1, 2, 0 },



  { "vwred", { I_VWMUL_VV_V6, I_VSETIVLI_E16_TU, I_VMV_VI_V4_0, I_VWREDSUM_V4 }, 4, 4, 1, 2, 0 },
  { "legacy-tail", { I_VMV_VI_V4_0, I_VWMUL_VV_V6, I_VSETIVLI_E16, I_VWREDSUM_V8 }, 4, 8, 1, 2, 1 },














  { "vwred-g", { I_VWMUL_VV_V6, I_VSETIVLI_E16_TU, I_VMV_VI_V4_0, I_VWREDSUM_V4 }, 4, 4, 1, 2, 1 },














  { "vwmacc6",  { I_VSETIVLI_E8V16, I_VMV_VI_V6_0, I_VMV_VI_V4_0, I_VWMACC_V6,
                  I_VSETIVLI_E16, I_VWREDSUM_V8 },                              6, 8, 1, 2, 1 },
  { "vwmacc5",  { I_VSETIVLI_E8V16, I_VMV_VI_V6_0, I_VWMACC_V6,
                  I_VSETIVLI_E16, I_VWREDSUM_V8 },                              5, 8, 1, 2, 1 },
  { "vwmacc4",  { I_VSETIVLI_E8V16, I_VMV_VI_V4_0, I_VWMACC_V6,
                  I_VSETIVLI_E16, I_VWREDSUM_V8 },                              4, 8, 1, 2, 1 },
  { "vwmacc3",  { I_VSETIVLI_E8V16, I_VMV_VI_V6_0, I_VWMACC_V6 },               3, 8, 1, 2, 1 },




  { "vdot",      { 0xb2b52657u },                                               1, 12, 10, 11, 0 },









  { "vdot_low",  { 0xb29420d7u },                                               1, 1, 8, 9, 0 },
};
static variant_t var;



static uint32_t encode_vdot(int vd, int vs1, int vs2) {
  return ((uint32_t)0b101100 << 26) | (1u << 25)
       | ((uint32_t)vs2 << 20) | ((uint32_t)vs1 << 15)
       | ((uint32_t)0b010 << 12) | ((uint32_t)vd << 7) | 0b1010111;
}

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
static void phase(const char *p) { snprintf(last_phase, sizeof last_phase, "%s", p); fflush(stdout); }

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
  if (var.garbage) {



    for (int r = 0; r < 32; r++)
      memset(blob + OFF_VR + VR_STRIDE * r, 0xa5, 16);
  }
  put64(OFF_MODE, 3);
  put64(OFF_MSTATUS, (uint64_t)3 << 9);
  put64(OFF_PC, pc);
  put64(OFF_VSTART, 0);
  put64(OFF_VTYPE, 0);
  put64(OFF_VL, 8);
  memcpy(blob + OFF_VR + VR_STRIDE * var.ra, vs1, 16);
  memcpy(blob + OFF_VR + VR_STRIDE * var.rb, vs2, 16);
}

static int step_bad = 0;









static const uint64_t *nr_guest_instr = NULL;
static uint64_t ic_total = 0;
static uint64_t ic_first = 0, ic_last = 0;
static int ic_cases = 0, ic_uniform = 1;
static int inject_broken = 0;
static void run_seq(uint64_t pc) {
  uint64_t c0 = nr_guest_instr ? *nr_guest_instr : 0;









  reg_cpy(blob, DIFFTEST_TO_REF);
  for (int i = 0; i < var.n; i++) {
    uint64_t before = get64(OFF_PC);
    uint64_t sb = nr_guest_instr ? *nr_guest_instr : 0;
    exec_n(1);
    reg_cpy(blob, DIFFTEST_TO_DUT);
    uint64_t after = get64(OFF_PC);






    if (nr_guest_instr && ic_cases == 0) {
      printf("STEP_INSTR arm=%s i=%d word=0x%08x retired=%llu pc=0x%llx->0x%llx\n",
             var.name, i, var.w[i], (unsigned long long)(*nr_guest_instr - sb),
             (unsigned long long)before, (unsigned long long)after);
    }
    if (after != before + 4) { step_bad++; break; }
    put64(OFF_PC, after);
  }
  if (nr_guest_instr) {
    uint64_t d = *nr_guest_instr - c0;
    if (!ic_cases) ic_first = d;
    else if (d != ic_first) ic_uniform = 0;
    ic_cases++;
    ic_last = d;
    ic_total += d;
  }
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





static int run_case_arm(const char *cases, int inject, int *total_out,
                        uint64_t *per_seq_out, int *uniform_out) {
  memset(blob, 0, sizeof blob);
  uint64_t pc = CODE_ADDR;
  ic_total = 0; ic_cases = 0; ic_uniform = 1; ic_last = 0;

  for (int i = 0; i < var.n; i++) {
    uint32_t word = var.w[i], rb = 0;
    uint64_t a = pc + 4ull * i;
    phase("mem_cpy write");
    mem_cpy(a, &word, 4, DIFFTEST_TO_REF);
    phase("mem_cpy readback");
    mem_cpy(a, &rb, 4, DIFFTEST_TO_DUT);
    printf("  [%d] @0x%lx 0x%08x readback 0x%08x%s\n", i, (unsigned long)a, word, rb,
           rb == word ? "" : "   <-- NOT IN MEMORY");
    if (rb != word) { printf("CODE NOT IN MEMORY: refusing to run\n"); return -6; }
  }
  printf("variant=%s instructions=%d result=v%d seed=%s\n", var.name, var.n,
         var.result_reg, var.garbage ? "garbage-0xa5" : "zero");
  if (!strcmp(var.name, "vdot") || !strcmp(var.name, "vdot_low")) {


    uint32_t built = encode_vdot(var.result_reg, var.ra, var.rb);
    printf("custom-op encoding: table 0x%08x bit-fields(vs1=v%d,vs2=v%d,vd=v%d) "
           "0x%08x %s\n", var.w[0], var.ra, var.rb, var.result_reg, built,
           var.w[0] == built ? "AGREE" : "DISAGREE");
    if (var.w[0] != built) { printf("ENCODING DISAGREEMENT: refusing to run\n"); return -7; }
  }

  FILE *f = fopen(cases, "r");
  if (!f) { printf("SETUP-FAIL: cannot open %s\n", cases); return 2; }
  char ln[512];
  int total = 0, bad = 0, hi = 0, low_bad = 0, tail_bad = 0;
  int ctrl_pass = 0, ctrl_bad = 0;
  uint32_t first_want = 0, first_got = 0;
  while (fgets(ln, sizeof ln, f)) {
    char a[64], b[64], e[64];
    if (ln[0] == '#' || ln[0] == '\n') continue;
    if (sscanf(ln, "%63s %63s %63s", a, b, e) != 3) continue;
    uint8_t vs1[16], vs2[16];
    if (!hex_to_bytes(a, vs1, 16) || !hex_to_bytes(b, vs2, 16)) {
      printf("SETUP-FAIL: unparsable case line: %s", ln); fclose(f); return 2;
    }
    seed(pc, vs1, vs2);
    int sb0 = step_bad;
    run_seq(pc);
    int step_failed = (step_bad != sb0);
    uint8_t vd[16];
    memcpy(vd, blob + OFF_VR + VR_STRIDE * var.result_reg, 16);
    uint32_t got = (uint32_t)vd[0] | ((uint32_t)vd[1] << 8)
                 | ((uint32_t)vd[2] << 16) | ((uint32_t)vd[3] << 24);
    uint32_t want = (uint32_t)strtoul(e, NULL, 16);
    int inject_this = inject && (total == 0);
    uint32_t against = inject_this ? (want ^ 0xdeadbeefu) : want;
    int pc_ok = (get64(OFF_PC) == pc + 4ull * var.n);
    int upper_nonzero = 0;
    for (int i = 4; i < 16; i++) if (vd[i]) { hi++; upper_nonzero = 1; }
    total++;
    int mismatch = (got != against) || upper_nonzero || !pc_ok || step_failed;
    if (inject_this) { if (mismatch) ctrl_bad++; else ctrl_pass++; continue; }
    if (got != want) low_bad++;
    if (upper_nonzero) tail_bad++;
    if (mismatch) {
      bad++;
      if (bad == 1) {
        first_want = want; first_got = got;
        printf("MISMATCH case %d: vs1=%s vs2=%s want=%08x got=%08x pc_ok=%d npc=0x%lx\n",
               total, a, b, (unsigned)want, (unsigned)got, pc_ok,
               (unsigned long)get64(OFF_PC));
      }
    }
  }
  fclose(f);
  printf("cases=%d mismatches=%d variant=%s n_inst=%d nonzero_upper_lanes=%d low_mismatches=%d tail_mismatches=%d compare_bits=128\n",
         total, bad, var.name, var.n, hi, low_bad, tail_bad);
  if (bad) {
    printf("first difference: want 0x%08x got 0x%08x (delta as int32 %d)\n",
           (unsigned)first_want, (unsigned)first_got,
           (int32_t)first_got - (int32_t)first_want);
  }
  if (inject) {
    printf("POSITIVE CONTROL: detected=%d missed=%d\n", ctrl_bad, ctrl_pass);
    inject_broken = (ctrl_bad == 0) || ctrl_pass;
    if (inject_broken)
      printf("BASELINE BROKEN: %s\n", ctrl_bad == 0 ? "comparison never fires"
                                                    : "wrong value accepted");
  }
  if (total == 0) { printf("BASELINE BROKEN: zero cases ran\n"); inject_broken = 1; }

  printf("ICOUNT arm=%s declared=%d counter=%s per_seq=%llu total=%llu cases=%d "
         "uniform=%d\n", var.name, var.n, nr_guest_instr ? "g_nr_guest_instr" : "MISSING",
         (unsigned long long)(ic_cases ? ic_total / (unsigned long long)ic_cases : 0),
         (unsigned long long)ic_total, total, ic_uniform);
  fflush(stdout);
  if (total_out) *total_out = total;
  if (per_seq_out) *per_seq_out = ic_cases ? ic_total / (unsigned long long)ic_cases : 0;
  if (uniform_out) *uniform_out = ic_uniform && ic_cases;
  return bad;
}

static int lookup_variant(const char *name) {
  for (unsigned i = 0; i < sizeof VARIANTS / sizeof VARIANTS[0]; i++)
    if (!strcmp(VARIANTS[i].name, name)) { var = VARIANTS[i]; return var.n; }
  var.n = 0;
  return 0;
}

int main(int argc, char **argv) {
  const char *dll = (argc > 1) ? argv[1] : "/d/nemu-vdot/build/riscv64-nemu-interpreter-so.exe";
  const char *cases = (argc > 2) ? argv[2] : "/d/nemu_cosim/cases.txt";
  const char *want_name = "doc3";
  int inject = 0, multi = 0;
  for (int i = 3; i < argc; i++) {
    if (!strcmp(argv[i], "--inject-bug")) inject = 1;
    else if (!strcmp(argv[i], "--multi"))  multi = 1;
    else want_name = argv[i];
  }
  if (!multi && !lookup_variant(want_name)) {
    printf("SETUP-FAIL: unknown variant '%s'; known:", want_name);
    for (unsigned i = 0; i < sizeof VARIANTS / sizeof VARIANTS[0]; i++)
      printf(" %s", VARIANTS[i].name);
    printf("\n");
    return 2;
  }

  setvbuf(stdout, NULL, _IONBF, 0);
  signal(SIGABRT, on_signal); signal(SIGSEGV, on_signal); signal(SIGFPE, on_signal);
  atexit(on_exit_cb);

  void *h = dlopen(dll, RTLD_NOW | RTLD_GLOBAL);
  if (!h) { printf("SETUP-FAIL dlopen: %s\n", dlerror()); return 2; }
  void *p_init2 = dlsym(h, "difftest_init_v2");
  void *p_init0 = dlsym(h, "difftest_init");
  if (!p_init2 && !p_init0) { printf("SETUP-FAIL: no init exported\n"); return 2; }
  mem_cpy = (fn_memcpy_t)dlsym(h, "difftest_memcpy");
  reg_cpy = (fn_regcpy_t)dlsym(h, "difftest_regcpy");
  exec_n  = (fn_exec_t)  dlsym(h, "difftest_exec");
  const unsigned *reg_size = (const unsigned *)dlsym(h, "DIFFTEST_REG_SIZE");
  if (!mem_cpy || !reg_cpy || !exec_n || !reg_size) {
    printf("SETUP-FAIL: a required symbol is missing\n"); return 2;
  }



  nr_guest_instr = (const uint64_t *)dlsym(h, "g_nr_guest_instr");
  printf("library DIFFTEST_REG_SIZE=%u, header OFF_END=%zu, g_nr_guest_instr=%s\n",
         *reg_size, (size_t)OFF_END, nr_guest_instr ? "resolved" : "NOT-RESOLVED");
  if (*reg_size != (unsigned)OFF_END) {
    printf("LAYOUT MISMATCH: refusing to run with offsets from a different blob\n");
    return 4;
  }
  phase("difftest_init");
  if (p_init2) ((fn_init_t)p_init2)((unsigned)OFF_END); else ((fn_void_t)p_init0)();

  if (multi) {






    const char **arms = (const char **)(argv + 4);
    int narms = argc - 4;
    if (narms < 2) {
      printf("SETUP-FAIL: --multi needs at least 2 arm names, got %d\n", narms);
      return 2;
    }
    uint64_t per[8] = { 0 };
    int uniform[8] = { 0 }, badn[8] = { 0 }, rc = 0;
    if (narms > 8) narms = 8;
    for (int a = 0; a < narms; a++) {
      if (!lookup_variant(arms[a])) {
        printf("SETUP-FAIL: multi mode lost variant '%s'\n", arms[a]); return 2;
      }
      badn[a] = run_case_arm(cases, inject, NULL, &per[a], &uniform[a]);
      if (badn[a] < 0) return -badn[a];
      if (!uniform[a]) { printf("ICOUNT-FAIL per-sequence delta was not constant for "
                                "arm %s -- the counter is not counting what the "
                                "sequence steps\n", arms[a]); rc = 7; }
    }
    if (rc) return rc;
    if (!nr_guest_instr || per[0] == 0 || per[1] == 0) {
      printf("INSTR UNAVAILABLE: counter missing or read 0 -- refusing to print a ratio\n");
      return 8;
    }










    int steps[2];
    lookup_variant(arms[0]); steps[0] = var.n;
    lookup_variant(arms[1]); steps[1] = var.n;
    double f0 = (double)per[0] / steps[0], f1 = (double)per[1] / steps[1];
    uint64_t n0 = per[0] / (uint64_t)(f0 + 0.5), n1 = per[1] / (uint64_t)(f1 + 0.5);
    printf("COUNT_CALIBRATION arm0=%s steps=%d raw=%llu per_step=%.2f "
           "arm1=%s steps=%d raw=%llu per_step=%.2f same_factor=%d\n",
           arms[0], steps[0], (unsigned long long)per[0], f0,
           arms[1], steps[1], (unsigned long long)per[1], f1,
           (f0 == f1) && (per[0] % (uint64_t)steps[0] == 0)
             && (per[1] % (uint64_t)steps[1] == 0));
    printf("RAW_INSTR vdot=%llu baseline=%llu ratio=%.2f\n",
           (unsigned long long)per[0], (unsigned long long)per[1],
           (double)per[1] / (double)per[0]);
    printf("INSTR vdot=%llu baseline=%llu ratio=%.2f raw_vdot=%llu raw_baseline=%llu "
           "vdot_mismatches=%d baseline_mismatches=%d\n",
           (unsigned long long)n0, (unsigned long long)n1,
           (double)per[1] / (double)per[0],
           (unsigned long long)per[0], (unsigned long long)per[1], badn[0], badn[1]);


    int ok = (n1 > n0) && (n0 == (uint64_t)steps[0]) && (n1 == (uint64_t)steps[1])
             && f0 == f1;
    printf("NEMU_INSTR_COUNT ok=%d vdot=%llu declared=%d baseline=%llu declared=%d "
           "factor=%.2f\n", ok, (unsigned long long)n0, steps[0],
           (unsigned long long)n1, steps[1], f0);
    return ok ? 0 : 9;
  }

  int bad = run_case_arm(cases, inject, NULL, NULL, NULL);
  if (bad < 0) return -bad;
  if (inject) return inject_broken ? 5 : 0;
  printf("BASELINE %s %s\n", var.name, bad ? "FAIL" : "PASS");
  return bad ? 1 : 0;
}
