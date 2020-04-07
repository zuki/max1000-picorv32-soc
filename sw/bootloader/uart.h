/// Syntacore SCR* infra
///
/// @copyright (C) Syntacore 2015-2019. All rights reserved.
/// @author mn-sc
///
/// @brief UART defs and inline funcs

#ifndef UART_H
#define UART_H

#define UART_BASE      0x02000000
#define UART_BAUDRATE  115200

#define UART_RXD       (0x00) // receive data
#define UART_TXD       (0x04) // transmit data
#define UART_STATUS    (0x08) // status register
#define UART_CONTROL   (0x0c) // control register
#define UART_DIV       (0x10) // baud rate divisor register

// UART status register bits
#define UART_ST_E      (1 << 8) // 1: error, 0: ok
#define UART_ST_RRDY   (1 << 7) // 1: exit data, 0: no data
#define UART_ST_TRDY   (1 << 6) // 1: can trans, 0: busy

#define UART_DIV_115200 0x363   // (SYS_FREQ / UART_BAUDRATE) - 1 = 867

#ifndef __ASSEMBLER__

#include <stdint.h>

// uart low level i/o
static inline void uart_write(uintptr_t uart_base, unsigned reg, uint16_t val)
{
    *(volatile uint32_t *)(uart_base + reg) = val;
}

static inline uint16_t uart_read(uintptr_t uart_base, unsigned reg)
{
    return *(volatile uint32_t *)(uart_base + reg);
}

// inlines

static inline int uart_rx_ready(void)
{
    return uart_read(UART_BASE, UART_STATUS) & UART_ST_RRDY;
}

static inline int uart_tx_ready(void)
{
    return uart_read(UART_BASE, UART_STATUS) & UART_ST_TRDY;
}

static inline void uart_tx_flush(void)
{
    while ((uart_read(UART_BASE, UART_STATUS) & UART_ST_TRDY) == 0);
}

static inline void uart_put(uint8_t v)
{
    while (!uart_tx_ready());
    uart_write(UART_BASE, UART_TXD, v);
}

static inline int uart_getc_nowait(void)
{
    if (uart_rx_ready())
        return uart_read(UART_BASE, UART_RXD);
    return -1; // no input
}

static inline int uart_getc(void)
{
    int c;

    do {
        c = uart_getc_nowait();
    } while (c == -1);

    return c;
}

// complex uart init/io
void uart_init(void);
int uart_putc(int v);
void uart_puthex4(uint8_t val);
void uart_puthex8(uint8_t val);
void uart_puthex16(uint16_t val);
void uart_puthex32(uint32_t val);
void uart_puts(const char *s);
unsigned long uart_read_hex(void);
unsigned uart_read_str(char *buf, unsigned size);

#endif // __ASSEMBLER__

#endif // UART_H
