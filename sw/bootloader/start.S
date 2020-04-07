#include "custom_ops.S"

    .section .text
    .global irq
    .global reset_vec

reset_vec:
    // ここでの設定は16バイト以内 !
    add x1, zero, -1                    // 全irqをマスク
    picorv32_maskirq_insn(zero, x1)     // 割り込み禁止
    j _start                            // 処理開始


/* 割り込みハンドラ
 **********************************/

.balign 16
irq_vec:
    /* レジスタの保存 */

    picorv32_setq_insn(q2, x1)
    picorv32_setq_insn(q3, x2)

    lui x1, %hi(irq_regs)          // x1にirq_regsを設定し
    addi x1, x1, %lo(irq_regs)     // reg保存のbpとして使用

    // 割込時のプログラムカウンタをirq_regs[0]に保存
    picorv32_getq_insn(x2, q0)
    sw x2,   0*4(x1)
    // 割込時のリターンアドレスをirq_reg[1]に保存
    picorv32_getq_insn(x2, q2)
    sw x2,   1*4(x1)
    // 割込時のスタックポインタをirq_reg[2]に保存
    picorv32_getq_insn(x2, q3)
    sw x2,   2*4(x1)
    // 各レジスタをirq_regに保存
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

    /* 割り込みハンドラ(C関数)の呼び出し */

    // スタックを割込処理用のスタックにする
    lui sp, %hi(irq_stack)
    addi sp, sp, %lo(irq_stack)

    // arg0 = レジスタの先頭アドレス
    lui a0, %hi(irq_regs)
    addi a0, a0, %lo(irq_regs)

    // arg1 = 処理すべき割り込みマスク（複数の場合あり）
    picorv32_getq_insn(a1, q1)

    // C関数のcall
    jal ra, irq

    /* レジスタの復元 */

    // 新規irq_regsアドレスはC関数からa0で返される
    addi x1, a0, 0
    // q0（割込時のプログラムカウンタ）を復元
    lw x2,   0*4(x1)
    picorv32_setq_insn(q0, x2)  // ハンドラのリターンアドレス
    // 割込時のリターンアドレスをq1に一時保管
    lw x2,   1*4(x1)
    picorv32_setq_insn(q1, x2)
    // 割込時のスタックポインタをq2に一時保管
    lw x2,   2*4(x1)
    picorv32_setq_insn(q2, x2)
    // 各レジスタを復元
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

    // リターンアドレスとスタックポインタを戻す
    picorv32_getq_insn(x1, q1)
    picorv32_getq_insn(x2, q2)

    # タイマーの設定
    li x1, 100000000         // 1s = 10 ns * 100 * 10^6
    picorv32_timer_insn(zero, x1)
    // 割込オン
    picorv32_maskirq_insn(zero, zero)
    // 割り込み処理終了
    picorv32_retirq_insn()

/* Main プログラム
 **********************************/

_start:
    /* すべてのレジスタを０で初期化 */

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

    ## gpの設定
    load_gp

    # .bssの初期化
    la    t0, _sbss
    la    t1, _ebss
    memset t0, t1, zero

    ## stack, spの初期化
    la    sp, __TLS0_BASE__
    mv    tp, sp

    ## init HART0 TLS
    la    t0, _tdata_begin
    la    t1, _tdata_end
    mv    t2, tp
    memcpy t0, t1, t2, a0
    la    t0, _tbss_end
    sub   t0, t0, t1
    add   t0, t0, t2
    memset t2, t0, zero

    /* bootloaderのCコードを呼び出し */
    mv a0, zero
    mv a1, zero
    jal main

    .balign 4
    .section .data
irq_regs:
    // 割り込みハンドラの処理中、レジスタはこのメモリ領域に
    // 保存される。プログラムカウンタはregister 0に保存される
    .fill 32,4

    // 割り込みハンドラ用のスタック領域
    .fill 128,4
irq_stack:
