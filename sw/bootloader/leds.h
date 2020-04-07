/// Syntacore SCR* infra
///
/// @copyright (C) Syntacore 2015-2017. All rights reserved.
/// @author mn-sc
///
/// @brief LEDs defs and inline funcs

#ifndef FPGA_LEDS_H
#define FPGA_LEDS_H

// LEDs
#define PINLED_ADDR  0x03000000
#define PINLED_NUM   8
#define PINLED_INV   0
#define PINLED_NAME "LED"

#define LEDS_TASK_DELAY_MS  200

#ifndef __ASSEMBLER__

#include <stdint.h>

static inline void leds_set(unsigned int v)
{
    *(volatile unsigned int*)(PINLED_ADDR) = v ^ PINLED_INV;
}

void leds_init(void);
void leds_print_info(void);

#endif // __ASSEMBLER__

#endif // FPGA_LEDS_H
