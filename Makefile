AS=arm-none-eabi-gcc
CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc

MCPU=cortex-m4

ASFLAGS= -x,assembler-with-cpp
ASFLAGS= -O0
ASFLAGS= -mthumb -mcpu=$(MCPU)

STARTUP_FILE_DIR=stm32h/STM32F4xx/Source/Templates/gcc/
STARTUP_FILE=startup_stm32f401xe

CCFLAGS= -mthumb -mcpu=$(MCPU)
CCFLAGS+=-DSTM32F4
CCFLAGS+=-DSTM32F401xE
CCFLAGS+=-ICMSIS_5/CMSIS/Core/Include
CCFLAGS+=-Istm32h/
CCFLAGS+=-Istm32h/STM32F4xx
CCFLAGS+=-Istm32h/STM32F4xx/Include

CCFLAGS_EXTRA=--specs=nosys.specs -nostdlib

LDFLAGS=-Wl,--gc-section --specs=nano.specs --specs=nosys.specs -TSTM32F401RETx_FLASH.ld

build:
	$(AS) $(ASFLAGS) -c $(STARTUP_FILE_DIR)/$(STARTUP_FILE).s
	$(CC) $(CCFLAGS) $(CCFLAGS_EXTRA) -c stm32h/STM32F4xx/Source/Templates/system_stm32f4xx.c
	$(CC) $(CCFLAGS) $(CCFLAGS_EXTRA) -c main.c

link:
	$(LD) $(LDFLAGS) $(STARTUP_FILE).o system_stm32f4xx.o main.o -o main.elf
