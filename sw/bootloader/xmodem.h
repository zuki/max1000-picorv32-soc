#ifndef XMODEM_H
#define XMODEM_H

#include <stdint.h>

#define XMODEM_SOH  0x01
#define XMODEM_STX  0x02
#define XMODEM_EOT  0x04
#define XMODEM_ACK  0x06
#define XMODEM_NAK  0x15
#define XMODEM_CAN  0x18
#define XMODEM_EOF  0x1a  /* Ctrl-Z */

#define XMODEM_BLOCK_SIZE 128

int xmodem_receive(uint8_t *);

#endif // XMODEM_H
