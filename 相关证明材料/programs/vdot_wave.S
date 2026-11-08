/* Fixed-layout full-core waveform program: 11 cases, 4 dependent, 4 independent. */
.option norvc
.option norelax
.macro DOT rd, rs1, rs2
  .word ((0x2c << 26) | (1 << 25) | (\rs2 << 20) | (\rs1 << 15) | (2 << 12) | (\rd << 7) | 0x57)
.endm
.macro CHECK reg, expected
  vs1r.v v\reg,(s1)
  ld t0,0(s1)
  li t1,(\expected & 0xffffffff)
  bne t0,t1,BAD
  ld t0,8(s1)
  bnez t0,BAD
.endm
.macro CASE number, offset, expected, rd=4
  addi t0,s0,\offset
  vle8.v v8,(t0)
  addi t0,t0,16
  vle8.v v9,(t0)
VDOT_CASE_\number:
  DOT \rd,9,8
  CHECK \rd,\expected
.endm
.section .text
.globl _start
_start:
  li t0,0x600
  csrw mstatus,t0
  li t0,8
  csrw 0x744,t0
  la t0,UNEXPECTED_TRAP
  csrw mtvec,t0
  la s0,INPUTS
  la s1,OUT
  vsetivli zero,16,e8,m1,tu,mu
  vmv.v.i v4,-1
  CASE 01,0,8
  CASE 02,32,204
  CASE 03,64,-8
  CASE 04,96,0
  CASE 05,128,131072
  CASE 06,160,-130048
  CASE 07,192,129032
  CASE 08,224,0
  CASE 09,256,120
  CASE 10,288,-1
  CASE 11,320,8,9
  /* Reload after vd=vs1 case; chain consumes each preceding result as int8 bytes. */
  vle8.v v8,(s0)
  addi t0,s0,16
  vle8.v v9,(t0)
VDOT_CHAIN_1: DOT 16,9,8
VDOT_CHAIN_2: DOT 17,9,16
VDOT_CHAIN_3: DOT 18,9,17
VDOT_CHAIN_4: DOT 19,9,18
  CHECK 16,8
  CHECK 17,8
  CHECK 18,8
  CHECK 19,8
VDOT_INDEPENDENT_1: DOT 20,9,8
VDOT_INDEPENDENT_2: DOT 21,9,8
VDOT_INDEPENDENT_3: DOT 22,9,8
VDOT_INDEPENDENT_4: DOT 23,9,8
  CHECK 20,8
  CHECK 21,8
  CHECK 22,8
  CHECK 23,8
  j OK
.balign 4
BAD: j BAD
UNEXPECTED_TRAP: j BAD
OK: j OK
.section .data
.balign 16
OUT: .zero 16
INPUTS:
/* Every record is 16-byte vs2 followed by 16-byte vs1; high halves are deliberately nonzero. */
.byte 1,1,1,1,1,1,1,1,99,98,97,96,95,94,93,92,1,1,1,1,1,1,1,1,91,90,89,88,87,86,85,84
.byte 1,2,3,4,5,6,7,8,99,98,97,96,95,94,93,92,1,2,3,4,5,6,7,8,91,90,89,88,87,86,85,84
.byte -1,-1,-1,-1,-1,-1,-1,-1,99,98,97,96,95,94,93,92,1,1,1,1,1,1,1,1,91,90,89,88,87,86,85,84
.byte 1,-1,1,-1,1,-1,1,-1,99,98,97,96,95,94,93,92,1,1,1,1,1,1,1,1,91,90,89,88,87,86,85,84
.byte -128,-128,-128,-128,-128,-128,-128,-128,99,98,97,96,95,94,93,92,-128,-128,-128,-128,-128,-128,-128,-128,91,90,89,88,87,86,85,84
.byte -128,-128,-128,-128,-128,-128,-128,-128,99,98,97,96,95,94,93,92,127,127,127,127,127,127,127,127,91,90,89,88,87,86,85,84
.byte 127,127,127,127,127,127,127,127,99,98,97,96,95,94,93,92,127,127,127,127,127,127,127,127,91,90,89,88,87,86,85,84
.byte 0,0,0,0,0,0,0,0,99,98,97,96,95,94,93,92,127,-128,5,-6,7,-8,9,-10,91,90,89,88,87,86,85,84
.byte 1,2,3,4,5,6,7,8,99,98,97,96,95,94,93,92,8,7,6,5,4,3,2,1,91,90,89,88,87,86,85,84
.byte -1,0,0,0,0,0,0,0,99,98,97,96,95,94,93,92,1,0,0,0,0,0,0,0,91,90,89,88,87,86,85,84
.byte 1,1,1,1,1,1,1,1,99,98,97,96,95,94,93,92,1,1,1,1,1,1,1,1,91,90,89,88,87,86,85,84
