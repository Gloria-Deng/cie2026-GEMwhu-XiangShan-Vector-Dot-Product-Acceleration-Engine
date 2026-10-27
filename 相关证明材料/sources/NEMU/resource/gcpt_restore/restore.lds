/* See LICENSE for license details. */

OUTPUT_ARCH( "riscv" )

ENTRY( restorer_size_location )

SECTIONS
{

  /*--------------------------------------------------------------------*/
  /* Code and read-only segment                                         */
  /*--------------------------------------------------------------------*/

  /* Beginning of code and text segment */
  . = ALIGN(4);

  gcpt_begin = .;

  .restore.size :
  {
    *(.restore.size)
  }

  . = gcpt_begin + 0x10;

  .restore.location :
  {
    *(.restore.location)
  }

  /* restore: Restore Program code section */
  .restore.code :
  {
    *(.restore.code)
  }

  . = ALIGN(0x400);
  .restore.flag :
  {
    *(.restore.flag)
  }

  gcpt_end = .;


  . = gcpt_begin + 0x100000;
  .payload :
  {
    PROVIDE(_payload_start = .);
    *(.payload)
    . = ALIGN(8);
    PROVIDE(_payload_end = .);
  }
}
