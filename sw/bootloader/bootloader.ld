ENTRY(reset_vec)

MEMORY
{
    RAM (xrw)     : ORIGIN = 0x00000000, LENGTH = 0x8000   /* 32 KB */
    SDRAM (xrw)   : ORIGIN = 0x01000000, LENGTH = 0x800000 /*  8 MB */
}


SECTIONS {
    /* プログラムコードとその他のデータはRAMに */
    .text : {
        . = ALIGN(4);
        *(.text)           /* .text sections (code) */
        *(.text*)          /* .text* sections (code) */
        *(.rodata)         /* .rodata sections (constants, strings, etc.) */
        *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
        . = ALIGN(4);
        _etext = .;        /* コード終了地点のグローバルシンボルを定義 */
        _sidata = _etext;  /* .dataセクション初期化の開始地点として使用 */
    } >RAM


    /* 初期化済みデータセクション
     *   プログラムはデータがSDRAMにあることを知って実行
     *   するが、ローダは初期値をRAMに置く(inidata)
     *   初期値をRAMからSDRAMにコピーするのはstartupの仕事
     */

    .data : {
        . = ALIGN(4);
        _sdata = .;  /* データ開始地点を示すグローバルシンボル */
        _ram_start = .;    /* ガーベジコレクタ用にRAM開始地点を示すグローバルシンボル */
        . = ALIGN(4);
        *(.data)           /* .data sections */
        *(.data*)          /* .data* sections */
        *(.sdata)          /* .sdata sections */
        *(.sdata*)         /* .sdata* sections */
        . = ALIGN(4);
        _edata = .;        /* データ終了地点を示すグローバルシンボルを定義。startupで使用 */
        __global_pointer$ = . + 0x800;
    } > RAM

    /* 非初期化データセクション */
    .bss :
    {
        . = ALIGN(4);
        _sbss = .;         /* bss開始地点を示すグローバルシンボル */
        *(.bss)
        *(.bss*)
        *(.sbss)
        *(.sbss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;         /* bss終了地点を示すグローバルシンボル */
    } > RAM

    /* スレッドローカルなデータセクション */
    .tdata : {
      . = ALIGN(4);
      _tls_data = .;
      _tdata_begin = .;
      KEEP(*(.tdata .tdata.*));
      _tdata_end = .;
      . = ALIGN(0x10);
    } > RAM

    .tbss  : {
      . = ALIGN(4);
      _tbss_begin = .;
      KEEP(*(.tbss .tbss.*));
      . = ALIGN(32);
      _tbss_end = .;
    } > RAM

    __TLS_SIZE__ = _tbss_end - _tdata_begin;

    __TLS0_BASE__ = __C_STACK_TOP__ - __TLS_SIZE__;

    .stack : {
      _data_end = ORIGIN(RAM)+LENGTH(RAM);
      . = _data_end - 4;
      _stack_pointer = .;
      __C_STACK_TOP__ = .;
    } > RAM

    /DISCARD/ : {
      *(.eh_frame .eh_frame.*)
    }

}
