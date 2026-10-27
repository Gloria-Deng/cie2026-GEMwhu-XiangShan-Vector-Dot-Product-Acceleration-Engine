.option norvc
.section .text._start,"ax",@progbits
.globl _start
_start:
  li t0,0x600
  csrw mstatus,t0
  li t0,8
  csrw 0x744,t0
  la t0, BAD
  csrw mtvec,t0
  li sp,0x81000000
  fence.i
  la t0, LANDING_BASE
  li t1,4
  slli t1,t1,2
  add t0,t0,t1
  jr t0
.balign 4
BAD: j BAD
