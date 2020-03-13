// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include "firmware.h"

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
    static unsigned int ext_irq_4_count = 0;
    static unsigned int ext_irq_5_count = 0;
    static unsigned int timer_irq_count = 0;

    // 縮小命令の妥当性チェック
    if ((irqs & 6) != 0) {  // irq 1, 2の割込あり
        // (regs[0] & 1)== 1: 縮小命令
        uint32_t pc = (regs[0] & 1) ? regs[0] - 3 : regs[0] - 4;    // 割込時の命令のPC
        uint32_t instr = *(uint16_t*)pc;

        if ((instr & 3) == 3)   // 32ビット長命令
            instr = instr | (*(uint16_t*)(pc + 2)) << 16;

        if (((instr & 3) != 3) != (regs[0] & 1)) {
            print_str("Mismatch between q0 LSB and decoded instruction word! q0=0x");
            print_hex(regs[0], 8);
            print_str(", instr=0x");
            if ((instr & 3) == 3)
                print_hex(instr, 8);
            else
                print_hex(instr, 4);
            print_str("\n");
            __asm__ volatile ("ebreak");
        }
    }

    // 外部割込(irq 4)の処理
    if ((irqs & (1<<4)) != 0) {
        ext_irq_4_count++;
        print_str("[EXT-IRQ-4: uart]");
    }
    // 外部割込(irq 5)の処理
    if ((irqs & (1<<5)) != 0) {
        ext_irq_5_count++;
        print_str("[EXT-IRQ-5]");
    }
    // タイマー割込(irq 0)の処理
    if ((irqs & 1) != 0) {
        timer_irq_count++;
        print_str("[TIMER-IRQ]");
        print_dec(timer_irq_count);
        print_str("\n");
    }
    // 内部割込(irq 1/2)の処理
    if ((irqs & 6) != 0)
    {
        uint32_t pc = (regs[0] & 1) ? regs[0] - 3 : regs[0] - 4;
        uint32_t instr = *(uint16_t*)pc;

        if ((instr & 3) == 3)
            instr = instr | (*(uint16_t*)(pc + 2)) << 16;

        print_str("\n");
        print_str("------------------------------------------------------------\n");
        // irq 1: EBREAK、または、不正命令
        if ((irqs & 2) != 0) {
            if (instr == 0x00100073 || instr == 0x9002) {
                print_str("EBREAK instruction at 0x");
                print_hex(pc, 8);
                print_str("\n");
            } else {
                print_str("Illegal Instruction at 0x");
                print_hex(pc, 8);
                print_str(": 0x");
                print_hex(instr, ((instr & 3) == 3) ? 8 : 4);
                print_str("\n");
            }
        }
        // irq 2: バスエラー
        if ((irqs & 4) != 0) {
            print_str("Bus error in Instruction at 0x");
            print_hex(pc, 8);
            print_str(": 0x");
            print_hex(instr, ((instr & 3) == 3) ? 8 : 4);
            print_str("\n");
        }

        for (int i = 0; i < 8; i++) {
            for (int k = 0; k < 4; k++) {
                int r = i + k*8;    // 0 <= r <= 31

                if (r == 0) {
                    print_str("pc  ");
                } else if (r < 10) {
                        print_chr('x');
                        print_chr('0' + r);
                        print_chr(' ');
                        print_chr(' ');
                } else if (r < 20) {
                        print_chr('x');
                        print_chr('1');
                        print_chr('0' + r - 10);
                        print_chr(' ');
                } else if (r < 30) {
                    print_chr('x');
                    print_chr('2');
                    print_chr('0' + r - 20);
                    print_chr(' ');
                } else {
                    print_chr('x');
                    print_chr('3');
                    print_chr('0' + r - 30);
                    print_chr(' ');
                }

                print_hex(regs[r], 8);
                print_str(k == 3 ? "\n" : "    ");
            } // end of for k
        } // end of for i

        // irq 1/2 はebreakで処理終了

        print_str("------------------------------------------------------------\n");

        print_str("Number of fast external IRQs counted: ");
        print_dec(ext_irq_4_count);
        print_str("\n");

        print_str("Number of slow external IRQs counted: ");
        print_dec(ext_irq_5_count);
        print_str("\n");

        print_str("Number of timer IRQs counted: ");
        print_dec(timer_irq_count);
        print_str("\n");

        __asm__ volatile ("ebreak");

    } // end of irq 1/2

    // TODO: irq 6-32 は無処理

    return regs;
}
