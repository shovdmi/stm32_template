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
SET(COMMON_FLAGS "-mthumb -mcpu=${MCU_CORE} -nostdlib --specs=nosys.specs --specs=nano.specs -g3 -ggdb")
SET(COMPILER_COMMON_FLAGS "-Wall -Wextra -ffunction-sections -fdata-sections")
SET(CMAKE_C_FLAGS   "${COMMON_FLAGS} ${COMPILER_COMMON_FLAGS} -std=c11"   CACHE STRING "c compiler flags")
SET(CMAKE_CXX_FLAGS "${COMMON_FLAGS} ${COMPILER_COMMON_FLAGS} -std=c++11" CACHE STRING "c++ compiler flags")
SET(CMAKE_ASM_FLAGS "-x,assembler-with-cpp -O0 -g3 -ggdb -mthumb -mcpu=${MCU_CORE}" CACHE STRING "assembler compiler flags")
SET(CMAKE_LINKER_FLAGS "${COMMON_FLAGS} -Wl,--gc-sections"                CACHE STRING "executable linker flags")
