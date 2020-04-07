#include <sys/stat.h>

#include "uart.h"

int __attribute__((used)) close(int file)
{
    return -1;
}

int __attribute__((used)) fstat(int file, struct stat *st)
{
    st->st_mode = S_IFCHR;
    return 0;
}

int __attribute__((used)) isatty(int file)
{
    return 1;
}

int __attribute__((used)) lseek(int file, int ptr, int dir)
{
    return 0;
}

int __attribute__((used)) open(const char *name, int flags, int mode)
{
    return -1;
}

int __attribute__((used,optimize("no-unroll-loops"))) read(int file, char *ptr, int len)
{
    int res = 0;

    int c;

    while ((res < len) && ((c = uart_getc()) >= 0))
        ptr[res++] = (char)c;

    return res;
}

int __attribute__((used,optimize("no-unroll-loops"))) write(int file, char *ptr, int len)
{
    for (int i = 0; i < len; ++i)
        uart_putc(*ptr++);

    return len;
}

caddr_t __attribute__((used)) sbrk(int incr)
{
    static char *heap_end = 0;

    extern char _end;            /* リンカスクリプトで定義 */
    extern char __STACK_START__; /* リンカスクリプトで定義 */

    char *prev_heap_end;

    if (heap_end == 0) {
        heap_end = &_end;
    }
    prev_heap_end = heap_end;

    if (heap_end + incr > &__STACK_START__) {
        /* ヒープとスタックが衝突 */
        return (caddr_t)0;
    }

    heap_end += incr;
    return (caddr_t) prev_heap_end;
}
