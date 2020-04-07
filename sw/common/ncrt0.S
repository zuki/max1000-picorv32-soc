### Syntacore SCR* infra
###
### @copyright (C) Syntacore 2015-2017. All rights reserved.
###
### @brief SCR* infra startup code

    .altmacro

    .macro load_gp addr=__global_pointer$
        LOCAL rel_addr
        .option push
        .option norelax
rel_addr:
        auipc gp, %pcrel_hi(\addr)
        addi  gp, gp, %pcrel_lo(rel_addr)
        .option pop
    .endm

    .macro memcpy src_beg, src_end, dst, tmp_reg
        LOCAL memcpy_1, memcpy_2
        j    memcpy_2
    memcpy_1:
        lw   \tmp_reg, (\src_beg)
        sw   \tmp_reg, (\dst)
        add  \src_beg, \src_beg, 4
        add  \dst, \dst, 4
    memcpy_2:
        bltu \src_beg, \src_end, memcpy_1
    .endm

    .macro memset dst_beg, dst_end, val_reg
        LOCAL memset_1, memset_2
        j    memset_2
    memset_1:
        sw   \val_reg, (\dst_beg)
        add  \dst_beg, \dst_beg, 4
    memset_2:
        bltu \dst_beg, \dst_end, memset_1
    .endm

### #########################
### startup code

    .globl _start, c_start

    ## .text
    .section ".text.crt","ax",@progbits

    ## Entry point
_start:
    ## reset mstatus: MPP=3, MPIE=1, MIE=0

    ## setup gp
    load_gp

    ## init bss
    la    t0, _sbss
    la    t1, _ebss
    memset t0, t1, zero

    ## init sp
    la    sp, __C_STACK_TOP__

    j     c_start
