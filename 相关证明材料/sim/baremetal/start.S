.option norvc
.section .text._start,"ax",@progbits
.globl _start
_start:
  li t0,0x600
  csrw mstatus,t0
  li t0,8
  csrw 0x744,t0
  la t0,BAD
  csrw mtvec,t0
  li sp,0x81000000
  call run
1: j 1b
