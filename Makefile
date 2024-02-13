AS=arm-none-eabi-gcc
CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy

MCPU=cortex-m3

ASFLAGS= -x,assembler-with-cpp
ASFLAGS= -O0 -g3 -ggdb
ASFLAGS= -mthumb -mcpu=$(MCPU)

CCFLAGS= -mthumb -mcpu=$(MCPU)
CCFLAGS+=-DSTM32F2
CCFLAGS+=-DSTM32F207xx
CCFLAGS+=-ICMSIS_5/CMSIS/Core/Include
CCFLAGS+=-Istm32h/
CCFLAGS+=-Istm32h/STM32F2xx
CCFLAGS+=-Istm32h/STM32F2xx/Include

CCFLAGS_EXTRA = --specs=nosys.specs --specs=nano.specs -nostdlib
CCFLAGS_EXTRA+= -g3 -ggdb

LDFLAGS = -mthumb -mcpu=$(MCPU)
LDFLAGS+= -Wl,--gc-section -nostdlib --specs=nano.specs --specs=nosys.specs -TSTM32F401RETx_FLASH.ld
LDFLAGS+= -g3 -ggdb

# File order is important!
ASM_SOURCES = stm32h/STM32F2xx/Source/Templates/gcc/startup_stm32f207xx.s
C_SOURCES =   stm32h/STM32F2xx/Source/Templates/system_stm32f2xx.c
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

openocd:
	openocd \
	-f board/st_nucleo_f4.cfg \
	-c "init" \
	-c "reset init" \
	-c "flash probe 0" \
	-c "flash info 0"
# 	-f interface/stlink.cfg
# for debugging add :        -d3

debug: main.elf
	$(GDB) main.elf -ex "target extended-remote :3333" -ex "mon reset" -ex "load"
	#$(GDB) main.elf -ex "target extended-remote :3333" -ex "display/i $$pc" -ex "load"

run:
	"%USERPROFILE%\AppData\Roaming\xPacks\qemu-arm\xpack-qemu-arm-7.1.0-1\bin\qemu-system-gnuarmeclipse.exe" -cpu cortex-m3 -machine STM32F4-Discovery -gdb tcp::3333 -nographic -kernel "main.elf"
