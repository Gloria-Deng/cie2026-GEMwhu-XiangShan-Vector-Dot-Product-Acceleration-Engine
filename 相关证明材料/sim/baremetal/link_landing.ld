ENTRY(_start)
SECTIONS
{
  . = 0x80000000;
  .text : { *(.text._start) *(.text*) }
  .rodata : { *(.rodata*) }
  . = ALIGN(0x1000);
  .landing : { KEEP(*(.landing)) }
  . = 0x80100000;
  .result : { *(.result) }
  .data : { *(.data*) }
  . = 0x80180000;
  .bss : { *(.bss*) *(COMMON) }
  . = 0x82000000;
  __stack_top = .;
}
