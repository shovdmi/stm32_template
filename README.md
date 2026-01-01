# Clone the repository
1 `git clone --recursive git@github.com:shovdmi/stm32_template.git`

or
1. `git clone https://github.com/shovdmi/stm32_template.git`
2. ```
    git submodule update --init stm32h
    cd stm32h
    git submodule update --init STM32F4xx
    cd ..
    ```
3. `git submodule update --init CMSIS_5`

# Set your MCU series
4. In `compile_commands.json` : 
    * change `-DSTM32F4`, `-DSTM32F401xE`, `-Istm32/STM32F4`, `-mcpu=cortex-m4` accoring to your cpu
    * change `"directory": "C:/Path/to/your/project"`
5.  `make all`
 or `make -f Makefile_simple all`

# for Cmake

4. In CMakeLists.txt
    * change `PROJECT(STM32F407)`, `ADD_DEFINITIONS(-DSTM32F407xx)`, `ADD_DEFINITIONS(-DSTM32F4)`
    * change `stm32h/STM32F4xx/Source`, `stm32h/STM32F4xx/Include`
    * change `startup_stm32f207xx.s`, `system_stm32f2xx.c`


5. `mkdir build && cd build`
   `cmake .. -G "Unix Makefiles"`
   `cmake --build .`
  
# CMakeLists.txt structure

## arm-none-eabi-toolchain.cmake
```cmake
SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR arm)

#-- Toolchain ------------------------------------------------------------------
set(TOOLCHAIN_PATH  "")
SET(CMAKE_C_COMPILER   ${TOOLCHAIN_PATH}arm-none-eabi-gcc)
SET(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH}arm-none-eabi-g++)
SET(CMAKE_ASM_COMPILER ${TOOLCHAIN_PATH}arm-none-eabi-gcc)
SET(CMAKE_LINKER       ${TOOLCHAIN_PATH}arm-none-eabi-gcc)
SET(CMAKE_OBJCOPY      ${TOOLCHAIN_PATH}arm-none-eabi-objcopy)
SET(CMAKE_OBJDUMP      ${TOOLCHAIN_PATH}arm-none-eabi-objdump)
SET(CMAKE_SIZE         ${TOOLCHAIN_PATH}arm-none-eabi-size   )

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

ENABLE_LANGUAGE(C)
ENABLE_LANGUAGE(CXX)
ENABLE_LANGUAGE(ASM)
```

## stm32f4.cmake
```cmake
set(STM32F4_TARGET_NAME stm32f4)
#-- MCU config -----------------------------------------------------------------
set(MCU_CORE             cortex-m4)
set(MCU_FAMILY           cortex-m)
set(MCU_SERIES           STM32F4)
set(MCU_CHIP             STM32F4xx)
set(MCU_NAME             STM32F401xE)
set(MCU_TARGET           thumbv7m-none-none-eabi) # for clang

set(CMSIS_CORE_INC_PATH   CMSIS_5/CMSIS/Core/Include)

set(PLATFORM_PATH         stm32h)
set(DEVICE_SRC_PATH       stm32h/${MCU_CHIP}/Source)
set(DEVICE_INC_PATH       stm32h/${MCU_CHIP}/Include)

add_library(${STM32F4_TARGET_NAME} STATIC EXCLUDE_FROM_ALL
    ${DEVICE_SRC_PATH}/Templates/system_stm32f4xx.c
    ${DEVICE_SRC_PATH}/Templates/gcc/startup_stm32f401xe.s  # enable_language(ASM). Otherwise *.s files are been ignored
)
# Specify include directories for stm32f4 library
target_include_directories(${STM32F4_TARGET_NAME} PUBLIC
    ${PLATFORM_PATH}
    ${CMSIS_CORE_INC_PATH}
    ${DEVICE_INC_PATH}
)
target_compile_definitions(${STM32F4_TARGET_NAME} PUBLIC
    -D${MCU_NAME}
    -D${MCU_SERIES}
)

set(COMMON_FLAGS
    -mthumb
    -mcpu=${MCU_CORE}
    -g3
    -ggdb
)

target_compile_options(${STM32F4_TARGET_NAME} PRIVATE
    ${COMMON_FLAGS}
    -Wall -Wextra
    -ffunction-sections -fdata-sections
)
```
