#ifndef __COMMON__
#define __COMMON__
// #define vPortSVCHandler SVC_Handler
// #define xPortSysTickHandler SysTick_Handler
// #define xPortPendSVHandler PendSV_Handler

#define HANDLER_DEFINE(f, h) void f(void) asm(#h)

extern unsigned long _sidata;
extern unsigned long _sdata;
extern unsigned long _edata;
extern unsigned long _sbss;
extern unsigned long _ebss;
extern void _estack(void);
void start(void);

#endif //__COMMON__
