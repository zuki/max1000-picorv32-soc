/// Syntacore SCR* infra
///
/// @copyright (C) Syntacore 2015-2017. All rights reserved.
/// @author mn-sc
///
/// @brief SCR* first stage boot loader

#include <stdint.h>
#include "bootloader.h"
#include "uart.h"
#include "leds.h"
#include "xmodem.h"

void dump_mem(uintptr_t addr, unsigned len)
{
    for (unsigned i = 0; len; ++i, addr += 16) {
        uart_puthex32(addr);
        uart_puts(": ");
        for (unsigned j = 0; j < 16 && len > j; ++j) {
            //uart_putc(' ');
            if (!(j & 3))
                uart_putc(' ');
            uart_puthex8(*(volatile uint8_t*)(addr + j));
        }
        uart_putc(' ');
        uart_putc('|');
        for (unsigned j = 0; j < 16 && len; ++j, --len) {
            unsigned ch = *(volatile uint8_t*)(addr + j);
            if (ch >= ' ' && ch < '\x7f')
                uart_putc(ch);
            else
                uart_putc('.');
        }
        uart_putc('|');
        uart_putc('\n');
    }
}

static void cmd_xload(void *arg)
{
    int st = xmodem_receive((uint8_t *)arg);

    while (uart_getc_nowait() >= 0);

    if (st < 0) {
        uart_puts("\nXmodem receive error: ");
        uart_puthex32(-st);
        uart_putc('\n');
    }
    else  {
        uart_puts("\nXmodem successfully received ");
        uart_puthex32(st);
        uart_puts(" bytes\n");
    }
}

static void cmd_start(void *arg)
{
    uart_putc('\n');
    uart_tx_flush();
    delay_us(20000);
    asm volatile ("jalr %0" :: "r"(arg));
}

static void cmd_mem_dump(void *arg)
{
    dump_mem((uintptr_t)arg, 128);
}

static void cmd_mem_modify(void *arg)
{
    uart_puthex32((uint32_t)arg);
    uart_putc(':');
    uart_putc(' ');
    unsigned long val = uart_read_hex();
    *(volatile unsigned long*)arg = val;
}

static void cmd_show_commands(void *arg)
{
    usage();
}

static const struct cmd_r commands[] = {
    {'1' | CMD_ARG_ADDR, "xmodem load @addr", cmd_xload, 0},
    {'g' | CMD_ARG_ADDR, "start @addr", cmd_start, 0},
    {'d' | CMD_ARG_ADDR | CMD_ARG_AUTOINC, "dump mem", cmd_mem_dump, (void*)128},
    {'m' | CMD_ARG_ADDR | CMD_ARG_AUTOINC, "modify mem", cmd_mem_modify, (void*)4},
    {' ' | CMD_HIDDEN, 0, cmd_show_commands, 0},
};

void usage(void)
{
    uart_puts("\n");

    for (uint8_t i = 0; i < sizeof(commands) / sizeof(*commands); ++i) {
        const struct cmd_r *cmd = &commands[i];
        if ((cmd->key & CMD_HIDDEN) == 0 && cmd->descr) {
            uart_putc(cmd->key & 0xff);
            uart_puts(": ");
            uart_puts(cmd->descr);
            uart_puts("\n");
        }
    }
}

static void leds_task(void)
{
    static uint8_t leds_val;
    static uint64_t start_time;
    static int right;
    uint64_t t2;

    if (start_time == 0) {
        start_time = now();
        leds_val = 0x1;
    }

    t2 = now();
    if (t2 - start_time < ms2ticks(LEDS_TASK_DELAY_MS)) {
        return;
    }

    start_time = now();
    leds_set(leds_val);

    if (right) {
        leds_val <<= 1;
    } else {
        leds_val >>= 1;
    }
    if (leds_val >= (1 << (PINLED_NUM - 1))) {
        right = 0;
    }
    if (leds_val <= 0x1) {
        right = 1;
        leds_val = 0x1;
    }
}

int main(void)
{
    uart_init();
    leds_init();

    usage();

    const struct cmd_r *prev_cmd = 0;
    void *prev_addr = 0;

    while (1) {
        uart_putc(':');
        uart_putc(' ');

        int c;
        while ((c = uart_getc_nowait()) == -1) {
            leds_task();
        }
        leds_set(0);

        const struct cmd_r *cmd = 0;

        for (unsigned i = 0; i < sizeof(commands) / sizeof(*commands); ++i) {
            if ((commands[i].key & 0xff) == c) {
                cmd = &commands[i];
                break;
            }
        }

        if (cmd) {
            uart_putc('\r');

            if (cmd->key & CMD_ARG_ADDR) {
                uart_puts(cmd->descr);
                uart_puts("\naddr: ");
                prev_addr = (void*)uart_read_hex();
            } else {
                prev_addr = cmd->data;
            }
            cmd->func(prev_addr);
            prev_cmd = cmd;
        } else if (c == '\r') {
            if (prev_cmd && (prev_cmd->key & CMD_ARG_AUTOINC)) {
                uart_putc('\r');
                prev_addr += (long)prev_cmd->data;
                prev_cmd->func(prev_addr);
            } else {
                uart_putc('\n');
            }
        } else {
            uart_putc(c);
            uart_puts(" - unknown command\n");
            cmd = 0;
        }
    }

    return 0;
}
