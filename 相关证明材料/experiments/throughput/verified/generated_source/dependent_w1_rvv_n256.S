.option norvc
.option norelax
.section .text
.globl _start
_start:
  li t0,0x600
  csrw mstatus,t0
  li t0,8
  csrw 0x744,t0
  la t0,UNEXPECTED_TRAP
  csrw mtvec,t0
  la s0,INPUT_A
  la s1,INPUT_B
  la s2,INITIAL
  la s3,OUTPUT
  la s7,EXPECTED
  vsetivli zero,16,e8,m1,ta,ma
  vle8.v v30,(s0)
  vle8.v v31,(s1)
  vsetivli zero,8,e8,m1,ta,ma
  li s4,256
  fence rw,rw
  csrr s5,cycle
  beqz s4,MEASURE_DONE
MEASURE_LOOP:
  vwmul.vv v16,v31,v30
  vsetivli zero,8,e16,m1,tu,mu
  vmv.v.i v30,0
  vwredsum.vs v30,v16,v30
  vsetivli zero,8,e8,m1,ta,ma
  addi s4,s4,-1
  bnez s4,MEASURE_LOOP
MEASURE_DONE:
  vs1r.v v30,(s3)
  addi s3,s3,16
  fence rw,rw
  la s3,OUTPUT
  ld t0,0(s3)
  ld t1,0(s7)
  bne t0,t1,BAD
  ld t0,8(s3)
  ld t1,8(s7)
  bne t0,t1,BAD
  addi s3,s3,16
  addi s7,s7,16
  csrr s6,cycle
  sub s6,s6,s5
  li t0,524288
  bgeu s6,t0,BAD
  srli s6,s6,3
  slli s6,s6,2
  la t0,LANDING
  add t0,t0,s6
  jr t0
.balign 4
BAD: j BAD
UNEXPECTED_TRAP: j BAD
OK: j OK
.balign 4
LANDING:
.rept 65536
  j .
.endr
.section .data
.balign 16
INPUT_A:
.byte 1,254,3,252,5,250,127,128,81,81,81,81,81,81,81,81
INPUT_B:
.byte 255,2,253,4,251,6,129,127,183,183,183,183,183,183,183,183
INITIAL:
.byte 165,165,165,165,165,165,165,165,165,165,165,165,165,165,165,165
OUTPUT: .zero 16
EXPECTED:
.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
