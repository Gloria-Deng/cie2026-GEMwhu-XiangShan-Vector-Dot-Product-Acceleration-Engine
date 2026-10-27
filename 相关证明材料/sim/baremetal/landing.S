.option norvc



.section .landing,"ax",@progbits
.globl LANDING_BASE
.type LANDING_BASE,@function
LANDING_BASE:
.rept 65536
  j .
.endr
.size LANDING_BASE, .-LANDING_BASE
