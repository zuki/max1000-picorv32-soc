/// Syntacore SCR* infra
///
/// @copyright (C) Syntacore 2015-2017. All rights reserved.
/// @author mn-sc
///
/// @brief SCR* infra defines and structs

#ifndef BOOTLOADER_H
#define BOOTLOADER_H

#include <stdint.h>

#define SYS_FREQ     100000000      // 100MHz
#define SYS_TICK     10             // 1/SYS_FREQ (ns)

#define CONSOLE_PUTCHAR 1
#define CONSOLE_GETCHAR 2
#define SHUTDOWN 8

typedef struct hart_storage {
    uint32_t xreg[32];
} hart_storage;

static inline uint64_t rdcycle(void)
{
    uint32_t __cycleh, __cyclel;
    asm volatile ("rdcycle %0" : "=r"(__cyclel));
    asm volatile ("rdcycleh %0" : "=r"(__cycleh));
    return ((__cycleh << 32) | (__cyclel));
}

static inline uint64_t now(void)
{
    return rdcycle();
}

static inline uint32_t ticks2ms(uint64_t t)
{
    return t / (SYS_FREQ / 1000);
}

static inline uint64_t ms2ticks(uint32_t t)
{
    return t * SYS_FREQ / 1000;
}

static inline void delay_us(uint32_t us)
{
    uint64_t t = now();
    uint64_t ticks = ms2ticks(us/1000);
    do ; while ((now() - t) < ticks);
}


#define CMD_HIDDEN (1 << 8)
#define CMD_ARG_ADDR (1 << 9)
#define CMD_ARG_AUTOINC (1 << 10)

struct cmd_r {
    int key;
    const char *descr;
    void (*func)(void*);
    void *data;
};

void usage(void);

#endif // BOOTLOADER_H
