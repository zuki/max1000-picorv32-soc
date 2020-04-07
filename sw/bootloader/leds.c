/// Syntacore SCR* infra
///
/// @copyright (C) Syntacore 2015-2017. All rights reserved.
/// @author mn-sc
///
/// @brief LEDs defs and inline funcs

#include "leds.h"
#include "uart.h"

void leds_init(void)
{
    leds_set(0);
}

void leds_print_info(void)
{
    uart_puthex32(PINLED_ADDR);
    uart_puts("\t ");
    uart_puts("\t" PINLED_NAME "\n");
}
