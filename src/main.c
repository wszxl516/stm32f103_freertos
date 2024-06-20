#include <misc.h>
#include <stm32f10x.h>
#include <stm32f10x_gpio.h>
#include <stm32f10x_rcc.h>

/* FreeRTOS includes. */
#include "printf.h"
#include "uart.h"
#include <FreeRTOS.h>
#include <task.h>

TaskHandle_t xTaskHandle1 = NULL;
TaskHandle_t xTaskHandle2 = NULL;

/* The task functions prototype*/
void uart_task(void *pvParameters);
void led_task(void *pvParameters);

int main(void) {
  /* Use internal RC oscillator clock */
  RCC_DeInit();
  SystemCoreClockUpdate();
  init_uart();
  pr_debug("start!\n");
  /* Create one of the two tasks. */
  xTaskCreate(uart_task, "UART", configMINIMAL_STACK_SIZE, NULL, 2,
              &xTaskHandle1);
  /* Create second task */
  xTaskCreate(led_task, "LED", configMINIMAL_STACK_SIZE, NULL, 2,
              &xTaskHandle2);

  /* Start the scheduler */
  vTaskStartScheduler();

  for (;;)
    ;
}

void uart_task(void *pvParameters) {
  for (;;) {
      char c = getc();
      if (c != '\0') {
        pr_notice("read key: 0x%x\r\n", c);
      }
      vTaskDelay(10);
  }
}

void led_task(void *pvParameters) {

  // GPIO structure for port initialization
  GPIO_InitTypeDef GPIO;

  // enable clock on APB2
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);

  // configure port A1 for driving an LED
  GPIO.GPIO_Pin = GPIO_Pin_13;
  GPIO.GPIO_Mode = GPIO_Mode_Out_PP;  // output push-pull mode
  GPIO.GPIO_Speed = GPIO_Speed_50MHz; // highest speed
  GPIO_Init(GPIOC, &GPIO);
  for (;;) {
    GPIO_SetBits(GPIOC, GPIO_Pin_13);
    vTaskDelay(500 / portTICK_PERIOD_MS);
    GPIO_ResetBits(GPIOC, GPIO_Pin_13);
    vTaskDelay(500 / portTICK_PERIOD_MS);
  }
}
