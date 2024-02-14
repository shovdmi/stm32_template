CMAKE_MINIMUM_REQUIRED(VERSION 3.8.0)

#-- MCU config -----------------------------------------------------------------
SET(MCU_CORE   "cortex-m4")
SET(MCU_FAMILY "cortex-m")
SET(MCU_SERIES "STM32F4")
SET(MCU_CHIP   "STM32F4xx")
SET(MCU_NAME   "STM32F401xE")

#-- Toolchain (uses ${MCU_CORE} setting)
include(${CMAKE_CURRENT_LIST_DIR}/arm-none-eabi-toolchain.cmake)


#-- Project config -------------------------------------------------------------
PROJECT(STM32F401)                 # Project name

IF(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    MESSAGE(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt." )
ENDIF()

SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)


#-- Defines --------------------------------------------------------------------
ADD_DEFINITIONS(-D${MCU_NAME})
ADD_DEFINITIONS(-D${MCU_SERIES})

#-- Project paths --------------------------------------------------------------
SET(APP_PATH              app)
SET(PLATFORM_PATH         stm32h)
SET(DEVICE_SRC_PATH       stm32h/${MCU_CHIP}/Source)
SET(DEVICE_INC_PATH       stm32h/${MCU_CHIP}/Include)
SET(CMSIS_CORE_INC_PATH   CMSIS_5/CMSIS/Core/Include)


#-- Include dirs ---------------------------------------------------------------
INCLUDE_DIRECTORIES(${APP_PATH})
INCLUDE_DIRECTORIES(${PLATFORM_PATH})
INCLUDE_DIRECTORIES(${CMSIS_CORE_INC_PATH})
INCLUDE_DIRECTORIES(${DEVICE_INC_PATH})

#-- Sources list ---------------------------------------------------------------
LIST(APPEND APP_SRC ${DEVICE_SRC_PATH}/Templates/gcc/startup_stm32f401xe.s)
LIST(APPEND APP_SRC ${DEVICE_SRC_PATH}/Templates/system_stm32f4xx.c)
LIST(APPEND APP_SRC main.c)
#LIST(APPEND APP_SRC printf.c)


#-- Linker script --------------------------------------------------------------
SET(LDSCRIPT ${CMAKE_SOURCE_DIR}/STM32F401RETx_FLASH.ld)
SET(CMAKE_EXE_LINKER_FLAGS "${CMAKE_LINKER_FLAGS} -T${LDSCRIPT} -Wl,-Map=${CMAKE_BINARY_DIR}/${PROJECT_NAME}.map -Wl,--print-memory-usage")


#-- Project linking ------------------------------------------------------------
ADD_EXECUTABLE(${PROJECT_NAME}.elf ${APP_SRC})
TARGET_LINK_LIBRARIES(${PROJECT_NAME}.elf)


#-- Custom targets and commands ------------------------------------------------------------
ADD_CUSTOM_TARGET(${PROJECT_NAME}.hex  ALL DEPENDS ${PROJECT_NAME}.elf COMMAND ${CMAKE_OBJCOPY} -Oihex   ${PROJECT_NAME}.elf   ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.hex)
ADD_CUSTOM_TARGET(${PROJECT_NAME}.bin  ALL DEPENDS ${PROJECT_NAME}.elf COMMAND ${CMAKE_OBJCOPY} -Obinary ${PROJECT_NAME}.elf   ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.bin)
ADD_CUSTOM_TARGET(${PROJECT_NAME}.dasm ALL DEPENDS ${PROJECT_NAME}.elf COMMAND ${CMAKE_OBJDUMP} "-DS"    ${PROJECT_NAME}.elf > ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.dasm)
ADD_CUSTOM_TARGET(PRINT_SIZES ALL DEPENDS ${PROJECT_NAME}.elf          COMMAND ${CMAKE_SIZE} ${PROJECT_NAME}.elf)
#ADD_CUSTOM_COMMAND(TARGET ${PROJECT_NAME}.elf POST_BUILD              COMMAND ${CMAKE_SIZE} ${PROJECT_NAME}.elf)

