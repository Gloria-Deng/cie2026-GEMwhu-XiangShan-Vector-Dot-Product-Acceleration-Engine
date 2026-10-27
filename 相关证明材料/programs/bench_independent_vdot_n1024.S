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
  la s2,POISON
  la s3,OUT
  vsetivli zero,16,e8,m1,ta,ma
  vle8.v v8,(s0)
  vle8.v v9,(s1)
  vle8.v v4,(s2)
  vsetivli zero,8,e8,m1,ta,ma
  li s4,1024
  fence rw,rw
  csrr s5,cycle
BENCH_LOOP:
  .word 0xb2942257
  addi s4,s4,-1
  bnez s4,BENCH_LOOP
  vs1r.v v4,(s3)
  fence rw,rw
  ld t0,0(s3)
  ld t1,8(s3)
  csrr s6,cycle
  li t2,0xffffffdc
  slli t2,t2,32
  srli t2,t2,32
  bne t0,t2,BAD
  bnez t1,BAD
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
.byte 1,2,3,4,5,6,7,8,81,81,81,81,81,81,81,81
INPUT_B:
.byte 1,254,3,252,5,250,7,248,183,183,183,183,183,183,183,183
POISON:
.byte 165,165,165,165,165,165,165,165,165,165,165,165,165,165,165,165
OUT: .zero 16
