#include "custom_ops.S"

    .section .text
    .global irq
    .global reset_vec

reset_vec:
    // no more than 16 bytes here
    //picorv32_waitirq_insn(zero)
	picorv32_maskirq_insn(zero, zero)
    j _start


/* 割り込みハンドラ
 *    ENABLE_QREGS = 1 を仮定
 **********************************/

.balign 16
irq_vec:

    /* 現在のレジスタを保存 */
    picorv32_setq_insn(q2, x1)  // return address
    picorv32_setq_insn(q3, x2)  // stack pointer

    // 割込禁止
    //addi x1, zero, -1
    //picorv32_maskirq_insn(zero, x1)

    lui x1, %hi(irq_regs)
    addi x1, x1, %lo(irq_regs)

    // 割込時のプログラムカウンタをirq_regs[0]に保存
    picorv32_getq_insn(x2, q0)
    sw x2,   0*4(x1)
    // 割込時のリターンアドレスをirq_reg[1]に保存
    picorv32_getq_insn(x2, q2)
    sw x2,   1*4(x1)

    picorv32_getq_insn(x2, q3)  // 割込時のスタックポインタをirq_reg[2]に保存
    sw x2,   2*4(x1)            // 各レジスタをirq_regに保存
    sw x3,   3*4(x1)
    sw x4,   4*4(x1)
    sw x5,   5*4(x1)
    sw x6,   6*4(x1)
    sw x7,   7*4(x1)
    sw x8,   8*4(x1)
    sw x9,   9*4(x1)
    sw x10, 10*4(x1)
    sw x11, 11*4(x1)
    sw x12, 12*4(x1)
    sw x13, 13*4(x1)
    sw x14, 14*4(x1)
    sw x15, 15*4(x1)
    sw x16, 16*4(x1)
    sw x17, 17*4(x1)
    sw x18, 18*4(x1)
    sw x19, 19*4(x1)
    sw x20, 20*4(x1)
    sw x21, 21*4(x1)
    sw x22, 22*4(x1)
    sw x23, 23*4(x1)
    sw x24, 24*4(x1)
    sw x25, 25*4(x1)
    sw x26, 26*4(x1)
    sw x27, 27*4(x1)
    sw x28, 28*4(x1)
    sw x29, 29*4(x1)
    sw x30, 30*4(x1)
    sw x31, 31*4(x1)

    /* C関数である割り込みハンドラを呼び出す */
    // スタックを割込処理用のスタックにする
    lui sp, %hi(irq_stack)
    addi sp, sp, %lo(irq_stack)

    // arg0 = レジスタの先頭アドレス
    lui a0, %hi(irq_regs)
    addi a0, a0, %lo(irq_regs)

    // arg1 = 割込タイプ（複数の場合あり）
    picorv32_getq_insn(a1, q1)

    // 実際のC関数の呼び出し
    jal ra, irq

    /*======================================*/
    /* 割込処理が終了。レジスタを戻す       */
    /*======================================*/

    // 新たな irq_regs アドレスはC関数からa0で返される
    addi x1, a0, 0

    // q0（割込時のプログラムカウンタ）を戻す
    lw x2,   0*4(x1)
    picorv32_setq_insn(q0, x2)
    // 割込時のリターンアドレスをq1に一時保管
    lw x2,   1*4(x1)
    picorv32_setq_insn(q1, x2)
    // 割込時のスタックポインタをq2に一時保管
    lw x2,   2*4(x1)
    picorv32_setq_insn(q2, x2)

    lw x3,   3*4(x1)
    lw x4,   4*4(x1)
    lw x5,   5*4(x1)
    lw x6,   6*4(x1)
    lw x7,   7*4(x1)
    lw x8,   8*4(x1)
    lw x9,   9*4(x1)
    lw x10, 10*4(x1)
    lw x11, 11*4(x1)
    lw x12, 12*4(x1)
    lw x13, 13*4(x1)
    lw x14, 14*4(x1)
    lw x15, 15*4(x1)
    lw x16, 16*4(x1)
    lw x17, 17*4(x1)
    lw x18, 18*4(x1)
    lw x19, 19*4(x1)
    lw x20, 20*4(x1)
    lw x21, 21*4(x1)
    lw x22, 22*4(x1)
    lw x23, 23*4(x1)
    lw x24, 24*4(x1)
    lw x25, 25*4(x1)
    lw x26, 26*4(x1)
    lw x27, 27*4(x1)
    lw x28, 28*4(x1)
    lw x29, 29*4(x1)
    lw x30, 30*4(x1)
    lw x31, 31*4(x1)

    # タイマーの設定
    lui x1, 1000;
    picorv32_timer_insn(zero, x1);

    // リターンアドレスとスタックポインタを戻す
    picorv32_getq_insn(x1, q1)
    picorv32_getq_insn(x2, q2)

    // 割込オン
    picorv32_maskirq_insn(zero, zero)
    picorv32_retirq_insn()


/* Main program
 **********************************/

_start:
    /* zero-initialize all registers */

    addi x1, zero, 0
    addi x2, zero, 0
    addi x3, zero, 0
    addi x4, zero, 0
    addi x5, zero, 0
    addi x6, zero, 0
    addi x7, zero, 0
    addi x8, zero, 0
    addi x9, zero, 0
    addi x10, zero, 0
    addi x11, zero, 0
    addi x12, zero, 0
    addi x13, zero, 0
    addi x14, zero, 0
    addi x15, zero, 0
    addi x16, zero, 0
    addi x17, zero, 0
    addi x18, zero, 0
    addi x19, zero, 0
    addi x20, zero, 0
    addi x21, zero, 0
    addi x22, zero, 0
    addi x23, zero, 0
    addi x24, zero, 0
    addi x25, zero, 0
    addi x26, zero, 0
    addi x27, zero, 0
    addi x28, zero, 0
    addi x29, zero, 0
    addi x30, zero, 0
    addi x31, zero, 0

# Update LEDs: LEDで処理状況を示す
    li a0, 0x03000000
    li a1, 1
    sw a1, 0(a0)

# copy data section
    la a0, _sidata
    la a1, _sdata
    la a2, _edata
    bge a1, a2, end_init_data

loop_init_data:
    lw a3, 0(a0)
    sw a3, 0(a1)
    addi a0, a0, 4
    addi a1, a1, 4
    blt a1, a2, loop_init_data
end_init_data:

    # Update LEDs
    li a0, 0x03000000
    li a1, 2
    sw a1, 0(a0)

# zero-init bss section
    la a0, _sbss
    la a1, _ebss
    bge a0, a1, end_init_bss
loop_init_bss:
    sw zero, 0(a0)
    addi a0, a0, 4
    blt a0, a1, loop_init_bss
    end_init_bss:

    # Update LEDs
    li a0, 0x03000000
    li a1, 3
    sw a1, 0(a0)

#set divisor (0x68 = 104 = 12MHz/115.2Kbps, 0x1b2 = 434 = 50MHz/115.2Kbps)
#            (0x364  = 868 = 100MHz/115.2Kbps) - 1
    lui a0, 0x02000
#    li a1, 0x67
#    li a1, 0x1b1
    li a1, 0x363
    sw a1, 0x10(a0)

    # Update LEDs
    li a0, 0x03000000
    li a1, 4
    sw a1, 0(a0)

    /* set stack pointer */
#    lui sp, 0x01800
#    lui sp, 0x00014
    lui sp, %hi(_stack_pointer)
    addi sp, sp, %lo(_stack_pointer)


    # Update LEDs
    li a0, 0x03000000
    li a1, 5
    sw a1, 0(a0)

    /* set gp and tp */
#    lui gp, %hi(0x01000800)
#    addi gp, gp, %lo(0x01000800)
#    lui gp, %hi(0x00010800)
#    addi gp, gp, %lo(0x00010800)
    lui gp, %hi(_sdata+0x800)
    addi gp, gp, %lo(_sdata+0x800)
    addi tp, gp, 0

    # Update LEDs
    li a0, 0x03000000
    li a1, 6
    sw a1, 0(a0)


#set irq_mask
    picorv32_maskirq_insn(zero, zero)

    # Update LEDs
    li a0, 0x03000000
    li a1, 7
    sw a1, 0(a0)

#disenable timer
    lui x1, 0
    picorv32_timer_insn(zero, x1);

    # Update LEDs
    li a0, 0x03000000
    li a1, 8
    sw a1, 0(a0)

    // interrupt off
    //addi x1, zero, -1
    //picorv32_maskirq_insn(zero, x1)

    # Update LEDs
    //li a0, 0x03000000
    //li a1, 9
    //sw a1, 0(a0)

    j   main                # jump to main


    .balign 4
    .section .data
irq_regs:
    // 割込処理時にここにレジスタを保存する
    // プログラムカウンタはレジスタ０に保存される
    .fill 32,4

    // 割込書利用のスタック領域
    .fill 128,4
irq_stack:
