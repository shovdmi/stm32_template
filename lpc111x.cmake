set(LPC111x_TARGET_NAME lpc111x)
#-- MCU config -----------------------------------------------------------------
set(MCU_CORE             cortex-m0)
set(MCU_FAMILY           cortex-m)
set(MCU_SERIES           LPC11XX)
set(MCU_CHIP             LPC11XX)
set(MCU_NAME             LPC1114)
set(MCU_TARGET           thumbv6m-none-none-eabi) # for clang

set(TARGET_COMPILE_FLAGS
    -mthumb
    -mcpu=${MCU_CORE}
    -mfloat-abi=soft
)

set(CMSIS_CORE_INC_PATH   CMSIS_5/CMSIS/Core/Include)

set(PLATFORM_PATH         lpc111x)
set(DEVICE_SRC_PATH       lpc111x)
set(DEVICE_INC_PATH       lpc111x)

set(TARGET_DEFAULT_LD_SCRIPT ${CMAKE_SOURCE_DIR}/${PLATFORM_PATH}/LPC1114.ld)

add_library(${LPC111x_TARGET_NAME} STATIC EXCLUDE_FROM_ALL
    ${DEVICE_SRC_PATH}/startup_LPC11xx.s  # enable_language(ASM). Otherwise *.s files are been ignored
)
# Specify include directories for stm32f4 library
target_include_directories(${LPC111x_TARGET_NAME} PUBLIC
    ${PLATFORM_PATH}
    ${CMSIS_CORE_INC_PATH}
    ${DEVICE_INC_PATH}
)
target_compile_definitions(${LPC111x_TARGET_NAME} PUBLIC
    -D${MCU_NAME}
    -D${MCU_SERIES}
)
target_compile_options(${LPC111x_TARGET_NAME} PRIVATE
    ${COMMON_COMPILE_FLAGS}
    ${TARGET_COMPILE_FLAGS}
)
target_link_options(${LPC111x_TARGET_NAME} PRIVATE
    ${TARGET_COMPILE_FLAGS}
    ${CMAKE_LINKER_FLAGS} 
    -Wl,-Map=${CMAKE_BINARY_DIR}/${PROJECT_NAME}.map
    -Wl,--print-memory-usage
    -Wl,--gc-sections
    #-lgcc
    )
target_link_libraries(${LPC111x_TARGET_NAME} PUBLIC
    gcc
)
