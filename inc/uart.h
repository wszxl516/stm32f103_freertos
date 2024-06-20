#ifndef __UART__
#define __UART__
void init_uart(void);
void putc(char ch);
void puts(char *ptr);
char getc();
#endif //__UART__
