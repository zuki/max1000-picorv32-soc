#include <stdio.h>
#include <stdint.h>

#include "uart.h"

#ifdef putchar
#undef putchar
#endif

// A simplified implementation of putchar
int putchar(int ch)
{
    if (ch == '\n') {
        uart_putc('\r');
    }

    return uart_putc(ch);
}

static inline void __attribute__((noreturn)) shutdown(void)
{
    while (1);
}

void __attribute__((noreturn)) exit(int status)
{
    uart_putstr("\nExit ");
    uart_puthex32(status);
    putchar('\n');
    shutdown();
}

void __attribute__((noreturn)) abort(void)
{
    uart_putstr("\nAbort.");
    shutdown();
}

int main(int argc, char **argv);

void c_start(void)
{
    uart_init();

    exit(main(0, 0));
}
