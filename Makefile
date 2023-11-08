AS=arm-none-eabi-gcc
CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy
GDB=arm-none-eabi-gdb

MCPU=cortex-m7

ASFLAGS= -x,assembler-with-cpp
ASFLAGS= -O0 -g3 -ggdb
#ASFLAGS= -mthumb -mcpu=$(MCPU)
ASFLAGS=  -mcpu=$(MCPU)

#CCFLAGS= -mthumb -mcpu=$(MCPU)
CCFLAGS= -mcpu=$(MCPU)
CCFLAGS+=-DSTM32F7
CCFLAGS+=-DSTM32F746xx
CCFLAGS+=-DHSE_VALUE=25000000
CCFLAGS+=-ICMSIS_5/CMSIS/Core/Include
CCFLAGS+=-Istm32h/
CCFLAGS+=-Istm32h/STM32F7xx
CCFLAGS+=-Istm32h/STM32F7xx/Include

CCFLAGS_EXTRA = --specs=nosys.specs --specs=nano.specs -nostdlib
CCFLAGS_EXTRA+= -g3 -ggdb

LDFLAGS = -mthumb -mcpu=$(MCPU)
LDFLAGS+= -Wl,--gc-section -nostdlib --specs=nano.specs --specs=nosys.specs -TSTM32F401RETx_FLASH.ld
LDFLAGS+= -g3 -ggdb

# File order is important!
ASM_SOURCES = stm32h/STM32F7xx/Source/Templates/gcc/startup_stm32f746xx.s
C_SOURCES =   stm32h/STM32F7xx/Source/Templates/system_stm32f7xx.c
C_SOURCES+= main.c
#C_SOURCES+= printf/printf.c # printf submodule

OBJFILES = $(patsubst %.s, %.o, $(notdir ${ASM_SOURCES}))
OBJFILES+= $(patsubst %.c, %.o, $(notdir ${C_SOURCES}))

SOURCEDIRS = $(dir $(ASM_SOURCES))
SOURCEDIRS+= $(dir $(C_SOURCES))

VPATH = $(SOURCEDIRS)

all: build hex
	@echo "SOURCEDIRS = " $(SOURCEDIRS)
	@echo "OBJFILES = " $(OBJFILES)

hex: build
	$(OBJCOPY) main.elf -O ihex main.hex

build: ${OBJFILES}
	@echo Linking...
	$(LD) $(LDFLAGS) $^ -o main.elf

%.o: %.c
	@echo Compiling: $^ into $@
	$(CC) $(CCFLAGS) $(CCFLAGS_EXTRA) -c $^ -o $@

%.o: %.s
	@echo Compiling assembly: $^ into $@
	$(AS) $(ASFLAGS) -c $^ -o $@

clean:
	@echo "Removing *.o and *.elf"
	del *.o
	del *.elf

run:
	"%USERPROFILE%\AppData\Roaming\xPacks\qemu-arm\xpack-qemu-arm-7.1.0-1\bin\qemu-system-gnuarmeclipse.exe" -cpu cortex-m4 -machine STM32F4-Discovery -gdb tcp::3333 -nographic -kernel "main.elf"
