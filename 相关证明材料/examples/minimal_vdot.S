.option norvc
.option norelax
.section .text
.globl _start
_start:

  li t0, 0x600
  csrw mstatus, t0
  li t0, 8
  csrw 0x744, t0
  la t0, UNEXPECTED_TRAP
  csrw mtvec, t0

  la s0, INPUT_A
  la s1, INPUT_B
  la s2, OUT
  la s3, POISON
  vsetivli zero, 16, e8, m1, ta, ma
  vle8.v v4, (s3)
  vle8.v v8, (s0)
  vle8.v v9, (s1)
  vsetivli zero, 8, e8, m1, tu, mu


  .word 0xb2942257


  vs1r.v v4, (s2)
  ld t0, 0(s2)
  li t1, 204
  bne t0, t1, BAD
  ld t0, 8(s2)
  bnez t0, BAD
  j OK

.balign 4
BAD: j BAD
UNEXPECTED_TRAP: j BAD
OK: j OK

.section .data
.balign 16
INPUT_A:
  .byte 1,2,3,4,5,6,7,8,0,0,0,0,0,0,0,0
INPUT_B:
  .byte 1,2,3,4,5,6,7,8,0,0,0,0,0,0,0,0
POISON:
  .fill 16,1,0xa5
OUT:
  .zero 16
