ENTRY(reset_vec)

MEMORY
{
    ROM (rx)      : ORIGIN = 0x00000000, LENGTH = 0x8000   /* 32 KB */
    SDRAM (xrw)   : ORIGIN = 0x01000000, LENGTH = 0x800000 /*  8 MB */
}


SECTIONS {
    /* The program code and other data goes into ROM */
    .text :
    {
        . = ALIGN(4);
        *(.text)           /* .text sections (code) */
        *(.text*)          /* .text* sections (code) */
        *(.rodata)         /* .rodata sections (constants, strings, etc.) */
        *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
        *(.srodata)        /* .rodata sections (constants, strings, etc.) */
        *(.srodata*)       /* .rodata* sections (constants, strings, etc.) */
        . = ALIGN(4);
        _etext = .;        /* define a global symbol at end of code */
        _sidata = _etext;  /* This is used by the startup in order to initialize the .data secion */
    } >ROM


    /* This is the initialized data section
    The program executes knowing that the data is in the SDRAM
    but the loader puts the initial values in the ROM (inidata).
    It is one task of the startup to copy the initial values from ROM to SDRAM. */
    .data : AT ( _sidata )
    {
        . = ALIGN(4);
        _sdata = ABSOLUTE(.);  /* create a global symbol at data start; used by startup code in order to initialise the .data section in RAM */
        _ram_start = ABSOLUTE(.);    /* create a global symbol at ram start for garbage collector */
        . = ALIGN(4);
        *(.data)           /* .data sections */
        *(.data*)          /* .data* sections */
        *(.sdata)           /* .sdata sections */
        *(.sdata*)          /* .sdata* sections */
        . = ALIGN(4);
        _edata = ABSOLUTE(.);        /* define a global symbol at data end; used by startup code in order to initialise the .data section in RAM */
    } > SDRAM

    /* Uninitialized data section */
    .bss :
    {
        . = ALIGN(4);
        _sbss = ABSOLUTE(.);         /* define a global symbol at bss start; used by startup code */
        *(.bss)
        *(.bss*)
        *(.sbss)
        *(.sbss*)
        *(COMMON)

        . = ALIGN(4);
        _ebss = ABSOLUTE(.);         /* define a global symbol at bss end; used by startup code */
    } > SDRAM

    /* this is to define the start of the heap, and make sure we have a minimum size */
    .sdram :
    {
        . = ALIGN(4);
        _end = ABSOLUTE(.);
        end = ABSOLUTE(.);
        _stack_base = ABSOLUTE(.);
    } > SDRAM

    _data_end = ORIGIN(SDRAM)+LENGTH(SDRAM);
    PROVIDE(_stack_pointer = _data_end);
    PROVIDE(_stack_limit   = _stack_base);
    PROVIDE(_heap_start    = end);
    PROVIDE(_heap_limit    = _data_end);
}
