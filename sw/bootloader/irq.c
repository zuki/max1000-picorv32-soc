#include "uart.h"

uint32_t *irq(uint32_t *regs, uint32_t irqs)
{
    static unsigned int timer_irq_count = 0;

    // checking compressed isa q0 reg handling
    if ((irqs & 6) != 0) {  // EBREAKまたは不正命令 or BUSエラーがある // pc: 割り込み時のPC
        uint32_t pc =                                             // regs[0]: 次のPC
            (regs[0] & 1) ? regs[0] - 3 : regs[0] - 4;            // bit0=1は縮小命令
        uint32_t instr = *(uint16_t*)pc;

        if ((instr & 3) == 3)   // LSBの2bit=11: 32ビット命令
            instr = instr | (*(uint16_t*)(pc + 2)) << 16;
                                                        // 縮小命令を示す2つの条件
        if (((instr & 3) != 3) != (regs[0] & 1)) {      // LSBの2bit ^= 11 と LSB =1 が不一致
            uart_puts("Mismatch between q0 LSB and decoded instruction word! q0=0x");
            uart_puthex32(regs[0]);
            uart_puts(", instr=0x");
            if ((instr & 3) == 3)
                uart_puthex32(instr);
            else
                uart_puthex16(instr);
            uart_puts("\n");
            __asm__ volatile ("ebreak");
        }
    }

    if ((irqs & 1) != 0) {      // タイマー割り込み: TODO
        timer_irq_count++;      //   CPUは処理継続
        // uart_puts("[TIMER-IRQ]");
    }

    if ((irqs & 6) != 0)    // irq 1 or 2: 割り込み情報を出力してCPUは停止
    {
        uint32_t pc = (regs[0] & 1) ? regs[0] - 3 : regs[0] - 4;    // 縮小命令の処理
        uint32_t instr = *(uint16_t*)pc;

        if ((instr & 3) == 3)
            instr = instr | (*(uint16_t*)(pc + 2)) << 16;

        uart_puts("\n");
        uart_puts("------------------------------------------------------------\n");

        if ((irqs & 2) != 0) {  // irq 1: EBREAK
            if (instr == 0x00100073 || instr == 0x9002) {
                uart_puts("EBREAK instruction at 0x");
                uart_puthex32(pc);
                uart_puts("\n");
            } else {            // irq 1: 不正命令
                uart_puts("Illegal Instruction at 0x");
                uart_puthex32(pc);
                uart_puts(": 0x");
                if ((instr & 3) == 3)
                    uart_puthex32(instr);
                else
                    uart_puthex16(instr);
                uart_puts("\n");
            }
        }

        if ((irqs & 4) != 0) {  // BUS エラー
            uart_puts("Bus error in Instruction at 0x");
            uart_puthex32(pc);
            uart_puts(": 0x");
            if ((instr & 3) == 3)
                uart_puthex32(instr);
            else
                uart_puthex16(instr);
            uart_puts("\n");
        }

        for (int i = 0; i < 8; i++)
        for (int k = 0; k < 4; k++)
        {
            int r = i + k*8;

            if (r == 0) {
                uart_puts("pc  ");
            } else
            if (r < 10) {
                uart_putc('x');
                uart_putc('0' + r);
                uart_putc(' ');
                uart_putc(' ');
            } else
            if (r < 20) {
                uart_putc('x');
                uart_putc('1');
                uart_putc('0' + r - 10);
                uart_putc(' ');
            } else
            if (r < 30) {
                uart_putc('x');
                uart_putc('2');
                uart_putc('0' + r - 20);
                uart_putc(' ');
            } else {
                uart_putc('x');
                uart_putc('3');
                uart_putc('0' + r - 30);
                uart_putc(' ');
            }

            uart_puthex32(regs[r]);
            uart_puts(k == 3 ? "\n" : "    ");
        }

        uart_puts("------------------------------------------------------------\n");

        uart_puts("Number of timer IRQs counted: ");
        uart_puthex32(timer_irq_count);
        uart_puts("\n");

        __asm__ volatile ("ebreak");
    }

    return regs;
}
