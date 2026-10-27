ENTRY(_start)
SECTIONS
{
  . = 0x80000000;
  .text : { *(.text._start) *(.text*) }
  .rodata : { *(.rodata*) }
  . = 0x80100000;
  .result : { *(.result) }
  .data : { *(.data*) }
  . = 0x80180000;
  .bss : { *(.bss*) *(COMMON) }
  . = 0x81000000;
  __stack_top = .;
}
