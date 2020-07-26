
#include "main.h"


void delay() 
{
	volatile uint32_t i;
	for (i = 0; i != 1500000; i++) ; // ~ 1 s
}

int main()
{
	RCC_Init();
	GPIO_Init();
	
	while(1)
	{	
		GPIOC->ODR ^= GPIO_ODR_ODR13;
        delay();
	}
}
