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
  vsetivli zero,8,e8,m1,tu,mu
  la t0,EXPECT_TRAP
  csrw mtvec,t0
FAULT:
  .word 0xb0942257
  j BAD
EXPECT_TRAP:
  csrr t0,mcause
  li t1,2
  bne t0,t1,BAD
  csrr t0,mepc
  la t1,FAULT
  bne t0,t1,BAD
  j OK

.balign 4
BAD: j BAD
UNEXPECTED_TRAP: j BAD
OK: j OK
