CMAKE_MINIMUM_REQUIRED(VERSION 3.8.0)

#-- System ---------------------------------------------------------------------
SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR arm)

#-- Toolchain ------------------------------------------------------------------
set(TOOLCHAIN_PATH  "")
SET(CMAKE_C_COMPILER   ${TOOLCHAIN_PATH}arm-none-eabi-gcc)
SET(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH}arm-none-eabi-g++)
SET(CMAKE_ASM_COMPILER ${TOOLCHAIN_PATH}arm-none-eabi-gcc)
SET(CMAKE_LINKER       ${TOOLCHAIN_PATH}arm-none-eabi-gcc)
SET(CMAKE_OBJCOPY      ${TOOLCHAIN_PATH}arm-none-eabi-objcopy CACHE STRING "objcopy tool")
SET(CMAKE_OBJDUMP      ${TOOLCHAIN_PATH}arm-none-eabi-objdump CACHE STRING "objdump tool")
SET(CMAKE_SIZE         ${TOOLCHAIN_PATH}arm-none-eabi-size    CACHE STRING "size tool")


#  Without this flag, CMake is unable to pass the test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
# To fix compilation check: enable either these or CMAKE_TRY_COMPILE_TARGET_TYPE flag
#set(CMAKE_C_COMPILER_FORCED TRUE)
#set(CMAKE_CXX_COMPILER_FORCED TRUE)

ENABLE_LANGUAGE(C)
ENABLE_LANGUAGE(CXX)
ENABLE_LANGUAGE(ASM)


#-- Common flags ---------------------------------------------------------------
SET(COMPILER_COMMON_FLAGS "-mthumb -mcpu=cortex-m4 --specs=nosys.specs --specs=nano.specs -nostdlib -Wall -Wextra -ffunction-sections -fdata-sections")
SET(CMAKE_C_FLAGS   "${COMPILER_COMMON_FLAGS} -std=c11"   CACHE STRING "c compiler flags")
SET(CMAKE_CXX_FLAGS "${COMPILER_COMMON_FLAGS} -std=c++11" CACHE STRING "c++ compiler flags")
SET(CMAKE_ASM_FLAGS "-x,assembler-with-cpp -O0 -g3 -ggdb -mthumb -mcpu=cortex-m4" CACHE STRING "assembler compiler flags")
SET(CMAKE_LINKER_FLAGS "-mthumb -mcpu=cortex-m4 -nostdlib --specs=nosys.specs --specs=nano.specs -Wl,--gc-sections -g3 -ggdb" CACHE STRING "executable linker flags")


IF(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    MESSAGE(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt." )
ENDIF()
SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#-- Project config -------------------------------------------------------------
PROJECT(STM32F401)                 # Project name

#-- Defines --------------------------------------------------------------------
ADD_DEFINITIONS(-DSTM32F401xE)
ADD_DEFINITIONS(-DSTM32F4)

#-- Project paths --------------------------------------------------------------
SET(APP_PATH              app)
SET(PLATFORM_PATH         stm32h)
SET(DEVICE_SRC_PATH       stm32h/STM32F4xx/Source)
SET(DEVICE_INC_PATH       stm32h/STM32F4xx/Include)
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

#-- Custom commands ------------------------------------------------------------
ADD_CUSTOM_COMMAND(TARGET ${PROJECT_NAME}.elf POST_BUILD
		COMMAND "echo"  "Post build: " ${CMAKE_OBJCOPY}
        COMMAND ${CMAKE_OBJCOPY} "-Oihex" ${PROJECT_NAME}.elf ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.hex
        COMMAND ${CMAKE_OBJCOPY} "-Obinary" ${PROJECT_NAME}.elf ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.bin
        COMMAND ${CMAKE_OBJDUMP} "-DS" ${PROJECT_NAME}.elf > ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.dasm
        COMMAND ${CMAKE_SIZE} ${PROJECT_NAME}.elf)

