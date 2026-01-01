set(STM32F4_TARGET_NAME stm32f4)
#-- MCU config -----------------------------------------------------------------
set(MCU_CORE             cortex-m4)
set(MCU_FAMILY           cortex-m)
set(MCU_SERIES           STM32F4)
set(MCU_CHIP             STM32F4xx)
set(MCU_NAME             STM32F401xE)
set(MCU_TARGET           thumbv7m-none-none-eabi) # for clang

set(COMMON_FLAGS
    -mthumb
    -mcpu=${MCU_CORE}
    -g3
    -ggdb
)

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
target_compile_options(${STM32F4_TARGET_NAME} PRIVATE
    ${COMMON_FLAGS}
    -Wall -Wextra
    -ffunction-sections -fdata-sections
)