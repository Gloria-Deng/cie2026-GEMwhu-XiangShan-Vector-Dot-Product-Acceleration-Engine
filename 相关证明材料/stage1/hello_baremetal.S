/* UARTLite: SoC.scala UARTLiteRange; NEMU uartlite.c TX=4, status=8. */
.option norvc
.option norelax
.section .text
.globl _start
_start:
  la t0,UNEXPECTED_TRAP
  csrw mtvec,t0
  la s0,HELLO_TEXT
  li s1,0x40600000
NEXT_CHAR:
  lbu t1,0(s0)
  beqz t1,DONE
UART_WAIT:
  lbu t2,8(s1)
  andi t2,t2,8
  bnez t2,UART_WAIT
  sb t1,4(s1)
  addi s0,s0,1
  j NEXT_CHAR
DONE:
  fence iorw,iorw
  j OK
.balign 4
BAD: j BAD
UNEXPECTED_TRAP: j BAD
OK: j OK
.section .data
.balign 16
HELLO_TEXT:
.include "hello_message.inc"
