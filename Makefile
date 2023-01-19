CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc

CCFLAGS= -mthumb -mcpu=cortex-m4
CCFLAGS+=-DSTM32F4
CCFLAGS+=-DSTM32F401xE
CCFLAGS+=-ICMSIS_5/CMSIS/Core/Include
CCFLAGS+=-Istm32h/
CCFLAGS+=-Istm32h/STM32F4xx
CCFLAGS+=-Istm32h/STM32F4xx/Include

build:
	$(CC) $(CCFLAGS) -c main.c

link:
	$(LD) $(LDFLAGS) main.o -o main.elf
