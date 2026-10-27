












































#include <dlfcn.h>
#include <inttypes.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "cosim_layout.h"

typedef void (*fn_init_t)(unsigned state_size);
typedef void (*fn_void_t)(void);
typedef void (*fn_memcpy_t)(uint64_t dest, void *src, size_t n, int direction);
typedef void (*fn_regcpy_t)(void *buf, int direction);
typedef void (*fn_exec_t)(uint64_t n);


#define DIFFTEST_TO_DUT 0
#define DIFFTEST_TO_REF 1
#define CONFIG_MBASE_G 0x80000000ull
#define CODE_ADDR      (CONFIG_MBASE_G + 0x200)


static uint32_t encode_vdot(int vd, int vs1, int vs2) {
  return ((uint32_t)0b101100 << 26) | (1u << 25)
       | ((uint32_t)vs2 << 20) | ((uint32_t)vs1 << 15)
       | ((uint32_t)0b010 << 12) | ((uint32_t)vd << 7) | 0b1010111;
}











#define W_VSETIVLI_E16   0xcc847057u
#define W_VSETIVLI_E8    0xcc047057u
#define W_VMV_VI_V13_0   0x5e0036d7u
#define W_VMV_VI_V14_0   0x5e003757u
#define W_VMV_V_V_V12_V1 0x5e008657u

#define RA_REG 10
#define RB_REG 11
#define VD1_REG 1
#define RD_REG  12
#define VD2_REG 2
#define W13_REG   13
#define W14_REG   14

#define NSTEP 7
static const char *STEP_NAME[NSTEP] = {
  "vsetivli->e16", "vmv.v.i v13,0", "vsetivli->e8", "vmv.v.i v14,0",
  "vdot.vv v1,v10,v11", "vmv.v.v v12,v1", "vdot.vv v2,v1,v11"
};

static uint8_t blob[OFF_END];
static fn_memcpy_t mem_cpy;
static fn_regcpy_t reg_cpy;
static fn_exec_t exec_n;
static const uint64_t *nr_guest_instr = NULL;

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

static void put64(size_t off, uint64_t v) { memcpy(blob + off, &v, 8); }
static uint64_t get64(size_t off) { uint64_t v; memcpy(&v, blob + off, 8); return v; }
static uint8_t *vr(int r) { return blob + OFF_VR + VR_STRIDE * r; }
static uint32_t lane0(int r) {
  const uint8_t *p = vr(r);
  return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16)
       | ((uint32_t)p[3] << 24);
}
static int upper_zero(int r) { for (int i = 4; i < 16; i++) if (vr(r)[i]) return 0; return 1; }
static int all_of(int r, uint8_t v) { for (int i = 0; i < 16; i++) if (vr(r)[i] != v) return 0; return 1; }
static int low8_zero(int r) { for (int i = 0; i < 8; i++) if (vr(r)[i]) return 0; return 1; }




static int hi8_nonzero(int r) { for (int i = 8; i < 16; i++) if (vr(r)[i]) return 1; return 0; }

static void seed(const uint8_t *a, const uint8_t *b) {
  memset(blob, 0, sizeof blob);




  for (int r = 0; r < 32; r++) memset(vr(r), 0xa5, 16);
  put64(OFF_MODE, 3);
  put64(OFF_MSTATUS, (uint64_t)3 << 9);
  put64(OFF_PC, CODE_ADDR);
  put64(OFF_VSTART, 0);
  put64(OFF_VTYPE, 0);
  put64(OFF_VL, 8);
  memcpy(vr(RA_REG), a, 16);
  memcpy(vr(RB_REG), b, 16);
}

static int hex_to_bytes(const char *s, uint8_t *out, int n) {
  if ((int)strlen(s) != n * 2) return 0;
  for (int i = 0; i < n; i++) {
    char b[3] = { s[2*i], s[2*i+1], 0 }, *e;
    long v = strtol(b, &e, 16);
    if (*e) return 0;
    out[i] = (uint8_t)v;
  }
  return 1;
}

int main(int argc, char **argv) {
  const char *dll = (argc > 1) ? argv[1]
      : "/d/nemu-cosim/build/riscv64-nemu-interpreter-so.exe";
  const char *cases = (argc > 2) ? argv[2] : "/d/nemu_cosim/seq_cases.txt";
  int inject = (argc > 3 && !strcmp(argv[3], "--inject-bug"));

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
  nr_guest_instr = (const uint64_t *)dlsym(h, "g_nr_guest_instr");
  if (!mem_cpy || !reg_cpy || !exec_n || !reg_size) {
    printf("SETUP-FAIL: a required symbol is missing\n"); return 2;
  }
  printf("library DIFFTEST_REG_SIZE=%u header OFF_END=%zu g_nr_guest_instr=%s\n",
         *reg_size, (size_t)OFF_END, nr_guest_instr ? "resolved" : "NOT-RESOLVED");
  if (*reg_size != (unsigned)OFF_END) {
    printf("LAYOUT MISMATCH: refusing to run with offsets from a different blob\n");
    return 4;
  }
  phase("difftest_init");
  if (p_init2) ((fn_init_t)p_init2)((unsigned)OFF_END); else ((fn_void_t)p_init0)();


  uint32_t word[NSTEP];
  word[0] = W_VSETIVLI_E16;
  word[1] = W_VMV_VI_V13_0;
  word[2] = W_VSETIVLI_E8;
  word[3] = W_VMV_VI_V14_0;
  word[4] = encode_vdot(VD1_REG, RA_REG, RB_REG);
  word[5] = W_VMV_V_V_V12_V1;
  word[6] = encode_vdot(VD2_REG, VD1_REG, RB_REG);
  if (word[4] == word[6]) { printf("SETUP-FAIL: two vdot steps decoded to one word\n"); return 2; }
  memset(blob, 0, sizeof blob);
  for (int i = 0; i < NSTEP; i++) {
    uint32_t rb = 0;
    uint64_t a = CODE_ADDR + 4ull * i;
    phase("mem_cpy write");
    mem_cpy(a, &word[i], 4, DIFFTEST_TO_REF);
    phase("mem_cpy readback");
    mem_cpy(a, &rb, 4, DIFFTEST_TO_DUT);
    printf("  [%d] @0x%lx %-18s enc=0x%08x readback=0x%08x%s\n", i, (unsigned long)a,
           STEP_NAME[i], word[i], rb, rb == word[i] ? "" : "   <-- NOT IN MEMORY");
    if (rb != word[i]) { printf("CODE NOT IN MEMORY: refusing to run\n"); return 6; }
  }

  FILE *f = fopen(cases, "r");
  if (!f) { printf("SETUP-FAIL: cannot open %s\n", cases); return 2; }
  char ln[512];
  int total = 0, bad = 0, pc_ok_steps = 0, pc_bad_steps = 0;
  int witness1 = 0, witness3 = 0, readback5 = 0, overlap6 = 0;
  int ctrl_pass = 0, ctrl_bad = 0;
  uint64_t ic_min = 0, ic_max = 0, ic_total = 0, step_ic[NSTEP] = { 0 };
  while (fgets(ln, sizeof ln, f)) {
    char ha[64], hb[64], e4[64], e5[64], e6[64];
    if (ln[0] == '#' || ln[0] == '\n') continue;
    if (sscanf(ln, "%63s %63s %63s %63s %63s", ha, hb, e4, e5, e6) != 5) continue;
    uint8_t a[16], b[16];
    if (!hex_to_bytes(ha, a, 16) || !hex_to_bytes(hb, b, 16)) {
      printf("SETUP-FAIL: unparsable case line: %s", ln); return 2;
    }
    uint32_t want[NSTEP];
    for (int i = 0; i < NSTEP; i++) want[i] = 0;
    want[4] = (uint32_t)strtoul(e4, NULL, 16);
    want[5] = (uint32_t)strtoul(e5, NULL, 16);
    want[6] = (uint32_t)strtoul(e6, NULL, 16);
    if (inject) want[4] ^= 0xdeadbeefu;
    seed(a, b);
    reg_cpy(blob, DIFFTEST_TO_REF);

    int case_ok = 1, steps_pc_ok = 0;
    uint64_t c0 = nr_guest_instr ? *nr_guest_instr : 0;
    for (int i = 0; i < NSTEP; i++) {
      uint64_t before = get64(OFF_PC);
      uint64_t cb = nr_guest_instr ? *nr_guest_instr : 0;
      phase("exec");
      exec_n(1);
      reg_cpy(blob, DIFFTEST_TO_DUT);
      uint64_t after = get64(OFF_PC);
      if (nr_guest_instr) step_ic[i] += *nr_guest_instr - cb;
      if (after == before + 4) { steps_pc_ok++; pc_ok_steps++; }
      else { pc_bad_steps++;
             printf("    STEP%d-BAD pc did not advance by 4 (0x%lx -> 0x%lx)\n",
                    i, (unsigned long)before, (unsigned long)after); }
      put64(OFF_PC, after);
      printf("    step%d %-18s pc 0x%lx->0x%lx vtype.blob=0x%lx vl=%llu | "
             "v13=%02x..%02x v14=%02x..%02x v1=%08x v12=%08x v2=%08x\n",
             i, STEP_NAME[i], (unsigned long)before, (unsigned long)after,
             (unsigned long)get64(OFF_VTYPE), (unsigned long long)get64(OFF_VL),
             vr(W13_REG)[0], vr(W13_REG)[15], vr(W14_REG)[0], vr(W14_REG)[15],
             lane0(VD1_REG), lane0(RD_REG), lane0(VD2_REG));
      int here = 0;
      if (i == 1) {

        if (all_of(W13_REG, 0)) witness1++;
        else { printf("    STEP1-BAD v13 not fully cleared (byte15=0x%02x) => the "
                      "e16 reconfiguration of step 0 did NOT take effect\n",
                      vr(W13_REG)[15]); here = 1; }
      }
      if (i == 3) {

        if (low8_zero(W14_REG) && hi8_nonzero(W14_REG)) witness3++;
        else { printf("    STEP3-BAD v14 low8zero=%d hi8nonzero=%d => at SEW=8 this vmv.v.i should have cleared 8 bytes and left bytes 8..15 alone; the e8 "
                      "reconfiguration of step 2 did NOT take effect\n",
                      low8_zero(W14_REG), hi8_nonzero(W14_REG)); here = 1; }
      }
      if (i == 4) {
        if (lane0(VD1_REG) != want[4] || !upper_zero(VD1_REG)) {
          printf("    STEP4-BAD vdot result v1=%08x want=%08x upper_zero=%d\n",
                 lane0(VD1_REG), want[4], upper_zero(VD1_REG)); here = 1;
        }
      }
      if (i == 5) {
        if (lane0(RD_REG) != want[5]) {
          printf("    STEP5-BAD the read of v1 landed v12=%08x want=%08x (v12 started "
                 "as 0xa5a5a5a5)\n", lane0(RD_REG), want[5]); here = 1;
        } else if (all_of(RD_REG, 0xa5)) {
          printf("    STEP5-BAD v12 still holds seed garbage -- the copy never ran\n");
          here = 1;
        } else readback5++;
      }
      if (i == 6) {
        if (lane0(VD2_REG) != want[6] || !upper_zero(VD2_REG)) {
          printf("    STEP6-BAD second vdot v2=%08x want=%08x upper_zero=%d -- want is "
                 "the dot product of step 4's WRITEBACK against v11; had vs1 still held "
                 "its 0xa5 seed the value would be different\n",
                 lane0(VD2_REG), want[6], upper_zero(VD2_REG)); here = 1;
        } else overlap6++;
      }
      if (here) case_ok = 0;
    }
    uint64_t d = nr_guest_instr ? (*nr_guest_instr - c0) : 0;
    if (ic_total == 0) { ic_min = d; ic_max = d; }
    if (d < ic_min) ic_min = d;
    if (d > ic_max) ic_max = d;
    ic_total += d;
    total++;
    if (steps_pc_ok != NSTEP) case_ok = 0;
    if (!case_ok) {
      bad++;
      if (bad == 1) printf("  SEQ-MISMATCH first failing case: a=%s b=%s\n", ha, hb);
    }
    if (inject) { if (!case_ok) ctrl_bad++; else ctrl_pass++; }
  }
  fclose(f);

  printf("steps=%d cases=%d mismatches=%d pc_steps_ok=%d pc_steps_bad=%d "
         "counter_delta_min=%llu counter_delta_max=%llu counter_delta_total=%llu\n",
         NSTEP, total, bad, pc_ok_steps, pc_bad_steps,
         (unsigned long long)ic_min, (unsigned long long)ic_max,
         (unsigned long long)ic_total);
  printf("witness vtype_e16=%d/%d vtype_e8=%d/%d read_of_writeback=%d/%d "
         "second_vdot_sees_first=%d/%d\n",
         witness1, total, witness3, total, readback5, total, overlap6, total);
  printf("per_step_counter");
  for (int i = 0; i < NSTEP; i++) printf(" s%d=%llu", i, (unsigned long long)step_ic[i]);
  printf(" (delta of g_nr_guest_instr across each step, summed over %d cases)\n", total);
  printf("SEQ_SUMMARY steps=%d mismatches=%d%s\n", NSTEP, bad,
         (!bad && pc_bad_steps == 0 && total > 0) ? " all_checks=pass" : "");
  printf("pc=advanced by 4 every step (%d of %d steps across %d cases)%s\n",
         pc_ok_steps, NSTEP * total, total,
         pc_ok_steps == NSTEP * total ? "" : "   <-- SOME STEP DID NOT MOVE");
  if (inject) {
    printf("POSITIVE CONTROL (one expectation was deliberately wrong): detected=%d "
           "missed=%d\n", ctrl_bad, ctrl_pass);
    if (ctrl_bad == 0) { printf("COSIM_SEQ BROKEN: the per-step comparison never fires\n"); return 5; }
    if (ctrl_pass) { printf("COSIM_SEQ BROKEN: a wrong step value was accepted\n"); return 5; }
    printf("COSIM_SEQ CONTROL PASS\n");
    return 0;
  }
  if (total == 0) { printf("COSIM_SEQ BROKEN: zero cases ran\n"); return 5; }
  printf("SEQ_ARM %s\n", (bad || pc_bad_steps) ? "FAIL" : "PASS");
  return (bad || pc_bad_steps) ? 1 : 0;
}
