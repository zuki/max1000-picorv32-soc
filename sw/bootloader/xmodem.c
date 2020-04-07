#include <stdint.h>
#include "uart.h"
#include "xmodem.h"

/* 受信開始されるまで送信要求を出す */
static int xmodem_wait(void)
{
  int cnt = 0;

  while (!uart_rx_ready()) {
    if (++cnt >= 2000000) {
      cnt = 0;
      uart_putc(XMODEM_NAK);
    }
  }

  return 0;
}

/* ブロック単位での受信 */
static int xmodem_read_block(uint8_t block_number, uint8_t *buf)
{
  uint8_t   c, bn, check_sum = 0;
  int i;

  bn = (uint8_t)uart_getc();
  if (bn != block_number)
    return -1;

  bn ^= (uint8_t)uart_getc();
  if (bn != 0xff)
    return -1;

  for (i = 0; i < XMODEM_BLOCK_SIZE; i++) {
    c = (uint8_t)uart_getc();
    *(buf++) = c;
    check_sum += c;
  }

  check_sum ^= (uint8_t)uart_getc();
  if (check_sum)
    return -1;

  return i;
}

int xmodem_receive(uint8_t *buf)
{
  int r, receiving = 0;
  int size = 0;
  uint8_t   c, block_number = 1;
  uint8_t   trychar = 'C';

  while (1) {
    if (!receiving) {
        uart_putc(trychar);
        xmodem_wait(); /* 受信開始されるまで送信要求を出す */
    }

    c = (uint8_t)uart_getc();

    if (c == XMODEM_EOT) { /* 受信終了 */
      uart_putc(XMODEM_ACK);
      break;
    } else if (c == XMODEM_CAN) { /* 受信中断 */
      return -1;
    } else if (c == XMODEM_SOH) { /* 受信開始 */
      receiving++;
      r = xmodem_read_block(block_number, buf); /* ブロック単位での受信 */
      if (r < 0) {  /* 受信エラー */
        uart_putc(XMODEM_NAK);
      } else {      /* 正常受信 */
        block_number++;
        size += r;
        buf  += r;
        uart_putc(XMODEM_ACK);
      }
    } else {
      if (receiving)
        return -1;
    }
  }

  return size;
}
