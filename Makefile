AS=arm-none-eabi-gcc
CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc

MCPU=cortex-m4

ASFLAGS= -x,assembler-with-cpp
ASFLAGS= -O0 -g3 -ggdb
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

CCFLAGS_EXTRA = --specs=nosys.specs --specs=nano.specs -nostdlib
CCFLAGS_EXTRA+= -g3 -ggdb

LDFLAGS = -mthumb -mcpu=$(MCPU)
LDFLAGS+= -Wl,--gc-section -nostdlib --specs=nano.specs --specs=nosys.specs -TSTM32F401RETx_FLASH.ld
LDFLAGS+= -g3 -ggdb

all: clean build

build: compile link

compile:
	@echo "Compiling..."
	$(AS) $(ASFLAGS) -c $(STARTUP_FILE_DIR)/$(STARTUP_FILE).s -g3 -ggdb
	$(CC) $(CCFLAGS) $(CCFLAGS_EXTRA) -c stm32h/STM32F4xx/Source/Templates/system_stm32f4xx.c
	$(CC) $(CCFLAGS) $(CCFLAGS_EXTRA) -c main.c

link:
	@echo "Linking *.o int elf"
	$(LD) $(LDFLAGS) $(STARTUP_FILE).o system_stm32f4xx.o main.o -o main.elf

clean:
	@echo "Removing *.o"
	del *.o

run:
	"%USERPROFILE%\AppData\Roaming\xPacks\qemu-arm\xpack-qemu-arm-7.1.0-1\bin\qemu-system-gnuarmeclipse.exe" -cpu cortex-m4 -machine STM32F4-Discovery -gdb tcp::3333 -nographic -kernel "main.elf"
