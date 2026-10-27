






typedef unsigned long u64;

#define VDOT_VV_WORD(vs2, vs1, vd) \
  (0xB0000000u | 0x02000000u | ((unsigned)(vs2) << 20) | \
   ((unsigned)(vs1) << 15) | 0x2000u | ((unsigned)(vd) << 7) | 0x57u)

#define N 1024
static const signed char A[16] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};
static const signed char B[16] = {8,7,6,5,4,3,2,1,-1,-2,-3,-4,-5,-6,-7,-8};

static inline u64 rdinstret(void) { u64 x; __asm__ volatile("rdinstret %0" : "=r"(x)); return x; }
__attribute__((noinline, used)) void OK(void) { for(;;) __asm__ volatile(""); }
__attribute__((noinline, used)) void BAD(void) { for(;;) __asm__ volatile(""); }

void run(void) {
  __asm__ volatile("vsetivli t6,8,e8,m1,ta,ma\n\t"
                   "vle8.v v24,(%0)\n\t"
                   "vle8.v v25,(%1)\n\t"
                   : : "r"(A), "r"(B) : "t6","v24","v25","memory");
  u64 t0 = rdinstret();
  for (int i = 0; i < N; i++)
    __asm__ volatile(".word %0" : : "i"(VDOT_VV_WORD(24, 25, 26))
                     : "v26","memory");
  u64 t1 = rdinstret();
  u64 vdot_instr = t1 - t0;

  __asm__ volatile("vsetivli t6,8,e16,m1,tu,mu\n\t"
                   "vmv.v.i v4,0\n\t"
                   "vsetivli t6,8,e8,m1,ta,ma" ::: "t6","v4","memory");
  u64 t2 = rdinstret();
  for (int i = 0; i < N; i++)
    __asm__ volatile("vwmul.vv v26,v25,v24\n\t"
                     "vsetivli t6,8,e16,m1,tu,mu\n\t"
                     "vmv.v.i v4,0\n\t"
                     "vwredsum.vs v4,v26,v4\n\t"
                     "vsetivli t6,8,e8,m1,ta,ma"
                     : : : "t6","v4","v26","memory");
  u64 t3 = rdinstret();
  u64 base_instr = t3 - t2;


  u64 t4 = rdinstret();
  for (int i = 0; i < N; i++)
    __asm__ volatile(".word %0\n\t"
                     "vmv1r.v v24,v26"
                     : : "i"(VDOT_VV_WORD(24, 25, 26))
                     : "v24","v26","memory");
  u64 t5 = rdinstret();
  u64 vdot_dep = t5 - t4;
  u64 t6 = rdinstret();
  for (int i = 0; i < N; i++)
    __asm__ volatile("vwmul.vv v26,v25,v24\n\t"
                     "vsetivli t6,8,e16,m1,tu,mu\n\t"
                     "vmv.v.i v4,0\n\t"
                     "vwredsum.vs v4,v26,v4\n\t"
                     "vsetivli t6,8,e8,m1,ta,ma\n\t"
                     "vmv1r.v v24,v4"
                     : : : "t6","v4","v24","v26","memory");
  u64 t7 = rdinstret();
  u64 base_dep = t7 - t6;

  register u64 a0 __asm__("a0") = vdot_instr;
  register u64 a1 __asm__("a1") = base_instr;
  register u64 a2 __asm__("a2") = N;
  register u64 a3 __asm__("a3") = (vdot_instr > N && base_instr > N && vdot_dep > N && base_dep > N);
  register u64 a4 __asm__("a4") = vdot_dep;
  register u64 a5 __asm__("a5") = base_dep;
  __asm__ volatile("" : : "r"(a0),"r"(a1),"r"(a2),"r"(a3),"r"(a4),"r"(a5));
  if (a3) OK(); else BAD();
}
