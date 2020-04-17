/// Syntacore SCR* infra
///
/// @copyright (C) Syntacore 2015-2016. All rights reserved.
/// @author mn-sc
///
/// @brief tiny xmodem loader

#ifndef XMODEM_H
#define XMODEM_H

#include <stdint.h>

#define MAX_XMODEM_RX_LEN (8*1024*1024)

int xmodem_receive(uint8_t *buf, unsigned buf_sz);

#endif // XMODEM_H
