/// Syntacore SCR* infra
///
/// @copyright (C) Syntacore 2015-2017. All rights reserved.
/// @author mn-sc
///
/// @brief implementation of UART i/o funcs

#include "uart.h"

void uart_init(void)
{
    // 割込の無効化
    uart_write(UART_BASE, UART_CONTROL, 0);
    // ボーレートの設定
    uart_write(UART_BASE, UART_DIV, UART_DIV_115200 & 0xffff);
}

int uart_putc(int c)
{
    if (c == '\n') {
        uart_put('\r');
    }
    uart_put(c);
    return c;
}

void uart_putstr(const char *s)
{
    while (*s)
        uart_putc(*s++);
}

void uart_puthex64(uint64_t val)
{
    uart_puthex32(val >> 32);
    uart_puthex32(val);
}

void uart_puthex32(uint32_t val)
{
    uart_puthex16(val >> 16);
    uart_puthex16(val);
}

void uart_puthex16(uint16_t val)
{
    uart_puthex8(val >> 8);
    uart_puthex8(val);
}

void uart_puthex8(uint8_t val)
{
    uart_puthex4(val >> 4);
    uart_puthex4(val);
}

void uart_puthex4(uint8_t val)
{
    uint8_t c = val & 0xf;
    uart_putc(c + (c > 9 ? ('A' - 10) : '0'));
}

void uart_putdec(uint32_t v)
{
    uint32_t res0 = 0;
    uint32_t i0 = 0;

    if (!v) {
        uart_putc('0');
        return;
    }

    for (; i0 < 8 && v; ++i0) {
        res0 = (res0 << 4) | v % 10;
        v /= 10;
    }

    if (v) {
        uint32_t res1 = 0;
        uint32_t i1 = 0;
        for (; i1 < 2 && v; ++i1) {
            res1 = (res1 << 4) | v % 10;
            v /= 10;
        }
        while (i1--) {
            uart_putc((res1 & 0xf) + '0');
            res1 >>= 4;
        }
    }
    while (i0--) {
        uart_putc((res0 & 0xf) + '0');
        res0 >>= 4;
    }
}

unsigned long uart_read_hex(void)
{
    unsigned len = 0;
    unsigned long res = 0;
    while (1) {
        int c = uart_getc();
        if ((c >= '0' && c <= '9') || ((c & ~0x20) >= 'A' && (c & ~0x20) <= 'F')) {
            if (len >= sizeof(unsigned long) * 2)
                continue;
            uart_putc(c);
            if (c > '9')
                c = (c & ~0x20) - 'A' + 10;
            else
                c = c - '0';
            ++len;
            res = (res << 4) + (c & 0xf);
        } else if (c == 0x7f || c == 0x8) { // DEL/BS
            if (!len)
                continue;
            --len;
            res >>= 4;
            uart_putc(0x8);
            uart_putc(' ');
            uart_putc(0x8);
        } else if (c == '\r') {
            uart_putc('\n');
            break;
        }
    }

    return res;
}

unsigned uart_read_str(char *buf, unsigned size)
{
    unsigned len = 0;

    while (1) {
        int c = uart_getc();
        if (c > 0x20 && c < 0x7f) {
            if (len + 1 >= size)
                continue;
            uart_putc(c);
            buf[len++] = c;
        } else if (c == 0x7f || c == 0x8) {
            if (!len)
                continue;
            --len;
            uart_putc(0x8);
            uart_putc(' ');
            uart_putc(0x8);
        } else if (c == '\r') {
            if (size)
                buf[len] = 0;
            uart_putc('\n');
            break;
        }
    }

    return len;
}
