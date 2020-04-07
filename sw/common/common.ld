ENTRY(_start)

MEMORY {
  SDRAM (rwx) : ORIGIN = 0x01000000, LENGTH = 8M
}

STACK_SIZE = 2048;

SECTIONS {

  .text.crt ORIGIN(SDRAM) : {
    *(.text.crt*)
  } >SDRAM

  .text : {
    . = ALIGN(4);
    _stext = .;
    *(.text .text.*)
    *(.rodata .rodata.*)
     . = ALIGN(4);
     _etext = .;
  } >SDRAM

  .data : {
    . = ALIGN(4);
    _sdata = .;
    *(.data .data.*)
    *(.sdata .sdata.*)
    . = ALIGN(4);
    _edata = .;
    __global_pointer$ = . + 0x800;
  } >SDRAM

  .bss : {
    . = ALIGN(4);
    _sbss = .;
    *(.bss .bss.*)
    *(.sbss .sbss.*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } >SDRAM

  . = ALIGN(16);

  _end = .;
  PROVIDE(__end = .);

  /* End of uninitalized data segement */

  .stack ORIGIN(SDRAM) + LENGTH(SDRAM) - STACK_SIZE : {
    PROVIDE(__STACK_START__ = .);
    . += STACK_SIZE;
    PROVIDE(__C_STACK_TOP__ = .);
    PROVIDE(__STACK_END__ = .);
  } >SDRAM

  /DISCARD/ : {
    *(.eh_frame .eh_frame.*)
  }
}
