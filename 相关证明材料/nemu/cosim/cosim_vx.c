















































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

#define FUNCT6_VDOT   0b101100
#define OP_V          0b1010111
#define FUNCT3_VV     0b010
#define FUNCT3_VX     0b110

static uint32_t encode_vdot_vv(int vd, int vs1, int vs2) {
  return ((uint32_t)FUNCT6_VDOT << 26) | (1u << 25) | ((uint32_t)vs2 << 20)
       | ((uint32_t)vs1 << 15) | ((uint32_t)FUNCT3_VV << 12) | ((uint32_t)vd << 7) | OP_V;
}
static uint32_t encode_vdot_vx(int vd, int vs2, int rs1) {
  return ((uint32_t)FUNCT6_VDOT << 26) | (1u << 25) | ((uint32_t)vs2 << 20)
       | ((uint32_t)rs1 << 15) | ((uint32_t)FUNCT3_VX << 12) | ((uint32_t)vd << 7) | OP_V;
}
static uint32_t encode_addi(int rd, int rs1, int imm) {
  return (((uint32_t)imm & 0xFFFu) << 20) | ((uint32_t)rs1 << 15) | (0u << 12)
       | ((uint32_t)rd << 7) | 0x13u;
}



#define W_VSETIVLI_E8 0xcc047057u

#define K_REG     5
#define VD1_REG   1
#define VD3_REG   3
#define VD4_REG   4
#define VS2_REG   2
#define VS1_REG   5
#define PATTERN   0x11

#define NSTEP 5
static const char *STEP_NAME[NSTEP] = {
  "vsetivli->e8", "addi x5,x0,K", "vdot.vv v4,v5,v2",
  "vdot.vx v1,v2,x5", "vdot.vx v3,v2,x0"
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
static void phase(const char *p) { snprintf(last_phase, sizeof last_phase, "%s", p); }

static void put64(size_t off, uint64_t v) { memcpy(blob + off, &v, 8); }
static uint64_t get64(size_t off) { uint64_t v; memcpy(&v, blob + off, 8); return v; }
static uint8_t *vr(int r) { return blob + OFF_VR + VR_STRIDE * r; }
static uint32_t lane0(int r) {
  const uint8_t *p = vr(r);
  return (uint32_t)p[0] | ((uint32_t)p[1] << 8) | ((uint32_t)p[2] << 16) | ((uint32_t)p[3] << 24);
}
static int upper_zero(int r) { for (int i = 4; i < 16; i++) if (vr(r)[i]) return 0; return 1; }
static int all_of(int r, uint8_t v) { for (int i = 0; i < 16; i++) if (vr(r)[i] != v) return 0; return 1; }

static void seed_case(const uint8_t *vs2, uint64_t code_base) {
  memset(blob, 0, sizeof blob);
  for (int r = 0; r < 32; r++) memset(vr(r), 0xa5, 16);
  memset(vr(VS1_REG), PATTERN, 16);
  memcpy(vr(VS2_REG), vs2, 16);
  put64(OFF_MODE, 3);
  put64(OFF_MSTATUS, (uint64_t)3 << 9);
  put64(OFF_PC, code_base);
  put64(OFF_VSTART, 0);
  put64(OFF_VTYPE, 0);
  put64(OFF_VL, 8);
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
  const char *dll = (argc > 1) ? argv[1] : "/d/nemu-vx/build/riscv64-nemu-interpreter-so.exe";
  const char *cases = (argc > 2) ? argv[2] : "/d/nemu_vx_arm/vx_cases.txt";
  int inject = 0, verbose = 3;
  for (int i = 3; i < argc; i++) {
    if (!strcmp(argv[i], "--inject-bug")) inject = 1;
    else if (!strncmp(argv[i], "--verbose=", 10)) verbose = atoi(argv[i] + 10);
  }

  setvbuf(stdout, NULL, _IONBF, 0);
  signal(SIGABRT, on_signal); signal(SIGSEGV, on_signal); signal(SIGFPE, on_signal);

  void *h = dlopen(dll, RTLD_NOW | RTLD_GLOBAL);
  if (!h) { printf("SETUP-FAIL dlopen: %s\n", dlerror()); return 2; }
  void *p_init2 = dlsym(h, "difftest_init_v2");
  void *p_init0 = dlsym(h, "difftest_init");
  if (!p_init2 && !p_init0) { printf("SETUP-FAIL: no init exported\n"); return 2; }
  mem_cpy = (fn_memcpy_t)dlsym(h, "difftest_memcpy");
  reg_cpy = (fn_regcpy_t)dlsym(h, "difftest_regcpy");
  exec_n  = (fn_exec_t)dlsym(h, "difftest_exec");
  const unsigned *reg_size = (const unsigned *)dlsym(h, "DIFFTEST_REG_SIZE");
  nr_guest_instr = (const uint64_t *)dlsym(h, "g_nr_guest_instr");
  if (!mem_cpy || !reg_cpy || !exec_n || !reg_size) {
    printf("SETUP-FAIL: a required symbol is missing\n"); return 2;
  }
  printf("library path=%s DIFFTEST_REG_SIZE=%u header OFF_END=%zu g_nr_guest_instr=%s\n",
         dll, *reg_size, (size_t)OFF_END, nr_guest_instr ? "resolved" : "NOT-RESOLVED");
  if (*reg_size != (unsigned)OFF_END) {
    printf("LAYOUT MISMATCH: refusing to run with offsets from a different blob\n"); return 4;
  }
  phase("difftest_init");
  if (p_init2) ((fn_init_t)p_init2)((unsigned)OFF_END); else ((fn_void_t)p_init0)();





  {





    uint32_t a = encode_vdot_vv(1, VS1_REG, VS2_REG);
    uint32_t b = encode_vdot_vx(1, VS2_REG, VS1_REG);
    printf("ENCODE vv=0x%08x vx=0x%08x xor=0x%08x funct3_only=%s\n", a, b, a ^ b,
           ((a ^ b) == ((uint32_t)(FUNCT3_VV ^ FUNCT3_VX) << 12)) ? "yes" : "NO");
    if (a == b) { printf("SETUP-FAIL: the two forms encode identically\n"); return 2; }
  }

  FILE *f = fopen(cases, "r");
  if (!f) { printf("SETUP-FAIL: cannot open %s\n", cases); return 2; }
  char ln[512];
  int total = 0, vx_bad = 0, vv_bad = 0, x0_bad = 0, wb_bad = 0, src_bad = 0;
  int pc_ok = 0, pc_bad = 0, steps = 0, code_bad = 0;
  unsigned long long ic0 = 0, ic1 = 0;

  while (fgets(ln, sizeof ln, f)) {
    if (ln[0] == '#' || ln[0] == '\n') continue;
    char hs[80], hk[80], hw2[80], hw4[80];
    if (sscanf(ln, "%79s %79s %79s %79s", hs, hk, hw2, hw4) != 4) continue;
    uint8_t vs2[16];
    if (!hex_to_bytes(hs, vs2, 16) || strlen(hk) != 2) {
      printf("SETUP-FAIL: unparsable case line: %s", ln); return 2;
    }
    unsigned k_byte = (unsigned)strtoul(hk, NULL, 16);
    uint32_t want2 = (uint32_t)strtoul(hw2, NULL, 16);
    uint32_t want4 = (uint32_t)strtoul(hw4, NULL, 16);
    if (inject) want2 ^= 0xdeadbeefu;

    int imm = (int)(k_byte >= 128 ? (int)k_byte - 256 : (int)k_byte);
    uint32_t word[NSTEP];
    word[0] = W_VSETIVLI_E8;
    word[1] = encode_addi(K_REG, 0, imm);
    word[2] = encode_vdot_vv(VD4_REG, VS1_REG, VS2_REG);
    word[3] = encode_vdot_vx(VD1_REG, VS2_REG, K_REG);
    word[4] = encode_vdot_vx(VD3_REG, VS2_REG, 0);









    uint64_t code_base = CODE_ADDR + (uint64_t)total * 0x40ull;
    if (code_base + NSTEP * 4ull > CODE_ADDR + 0x10000ull) {
      printf("SETUP-FAIL: code window would run past the 64 KiB scratch region at case %d\n",
             total);
      return 5;
    }
    seed_case(vs2, code_base);
    int this_code_bad = 0;
    for (int i = 0; i < NSTEP; i++) {
      uint32_t rb = 0;
      phase("mem_cpy write");
      mem_cpy(code_base + 4ull * i, &word[i], 4, DIFFTEST_TO_REF);
      phase("mem_cpy readback");
      mem_cpy(code_base + 4ull * i, &rb, 4, DIFFTEST_TO_DUT);
      if (rb != word[i]) {
        this_code_bad = 1; code_bad++;
        printf("  CODE-NOT-IN-MEMORY step%d enc=0x%08x readback=0x%08x\n", i, word[i], rb);
      } else if (total < verbose) {
        printf("  [%d] @0x%lx %-18s enc=0x%08x readback=0x%08x\n", i,
               (unsigned long)(code_base + 4ull * i), STEP_NAME[i], word[i], rb);
      }
    }
    if (this_code_bad) continue;
    reg_cpy(blob, DIFFTEST_TO_REF);

    int case_vx_ok = 1, case_vv_ok = 1, case_x0_ok = 1, case_wb_ok = 1, case_src_ok = 1;
    if (nr_guest_instr) ic0 = *nr_guest_instr;
    for (int i = 0; i < NSTEP; i++) {
      uint64_t before = get64(OFF_PC);
      phase("exec");
      exec_n(1);
      reg_cpy(blob, DIFFTEST_TO_DUT);
      uint64_t after = get64(OFF_PC);
      steps++;
      if (after == before + 4) pc_ok++;
      else { pc_bad++;
             printf("    STEP%d-BAD pc 0x%lx -> 0x%lx (%s)\n", i,
                    (unsigned long)before, (unsigned long)after, STEP_NAME[i]); }
      put64(OFF_PC, after);
      if (total < verbose) {
        printf("    step%d %-18s pc 0x%lx->0x%lx v1=%08x v3=%08x v4=%08x v5[0]=0x%02x\n",
               i, STEP_NAME[i], (unsigned long)before, (unsigned long)after,
               lane0(VD1_REG), lane0(VD3_REG), lane0(VD4_REG), vr(VS1_REG)[0]);
      }
      if (i == 2) {
        if (lane0(VD4_REG) != want4) case_vv_ok = 0;
        if (!all_of(VS1_REG, PATTERN) || memcmp(vr(VS2_REG), vs2, 16) != 0) case_src_ok = 0;
        if (!upper_zero(VD4_REG) || all_of(VD4_REG, 0xa5)) case_wb_ok = 0;
      }
      if (i == 3) {
        if (lane0(VD1_REG) != want2) case_vx_ok = 0;
        if (!upper_zero(VD1_REG) || all_of(VD1_REG, 0xa5)) case_wb_ok = 0;
      }
      if (i == 4 && lane0(VD3_REG) != 0u) case_x0_ok = 0;
      if (i == 4 && !upper_zero(VD3_REG)) case_wb_ok = 0;
    }
    if (nr_guest_instr) ic1 = *nr_guest_instr;

    if (!case_vx_ok) vx_bad++;
    if (!case_vv_ok) vv_bad++;
    if (!case_x0_ok) x0_bad++;
    if (!case_wb_ok) wb_bad++;
    if (!case_src_ok) src_bad++;
    int case_ok = case_vx_ok && case_vv_ok && case_x0_ok && case_wb_ok && case_src_ok;


    if (!case_ok || total < verbose) {
      printf("  case%-4d %s K=0x%02x imm=%-5d want_vx=0x%08x got=0x%08x %s | "
             "x0-witness got=0x%08x %s | vv want=0x%08x got=0x%08x %s | wb=%s src=%s\n",
             total, case_ok ? "ok" : "FAIL", k_byte, imm, want2, lane0(VD1_REG),
             case_vx_ok ? "OK" : "MISMATCH", lane0(VD3_REG), case_x0_ok ? "OK" : "MISMATCH",
             want4, lane0(VD4_REG), case_vv_ok ? "OK" : "MISMATCH",
             case_wb_ok ? "OK" : "BAD", case_src_ok ? "OK" : "BAD");
    }
    total++;
  }
  fclose(f);

  int mismatches = vx_bad + vv_bad + x0_bad + wb_bad + src_bad;
  printf("INSTR-COUNT g_nr_guest_instr delta=%llu (cases=%d, %d steps each)\n",
         (unsigned long long)(ic1 - ic0), total, NSTEP);
  printf("CHECKS code_readback_bad=%d pc_ok=%d pc_bad=%d steps=%d writeback_bad=%d src_bad=%d\n",
         code_bad, pc_ok, pc_bad, steps, wb_bad, src_bad);
  printf("ARM vx_mismatches=%d vv_mismatches=%d x0_witness_mismatches=%d\n",
         vx_bad, vv_bad, x0_bad);
  if (total == 0) { printf("COSIM_VX cases=0 VERDICT NO-CASES\n"); return 3; }
  printf("COSIM_VX cases=%d steps=%d mismatches=%d pc_bad=%d inject=%s\n",
         total, steps, mismatches, pc_bad, inject ? "yes" : "no");
  return mismatches == 0 && pc_bad == 0 && code_bad == 0 ? 0 : 1;
}
