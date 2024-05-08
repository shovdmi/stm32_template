#-- System ---------------------------------------------------------------------
SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR arm)

#-- Toolchain ------------------------------------------------------------------
set(TOOLCHAIN_PATH  "")
SET(CMAKE_C_COMPILER   ${TOOLCHAIN_PATH}clang -D__GNUC__)
SET(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH}clang)
SET(CMAKE_ASM_COMPILER ${TOOLCHAIN_PATH}clang)
SET(CMAKE_LINKER       ${TOOLCHAIN_PATH}clang)
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
SET(COMMON_FLAGS "--target=${MCU_TARGET} -mthumb -mcpu=${MCU_CORE} -nostdlib --specs=nosys.specs --specs=nano.specs -g3 -ggdb")
SET(COMPILER_COMMON_FLAGS "-Wall -Wextra -ffunction-sections -fdata-sections")
SET(CMAKE_C_FLAGS   "${COMMON_FLAGS} ${COMPILER_COMMON_FLAGS} -std=c11")
SET(CMAKE_CXX_FLAGS "${COMMON_FLAGS} ${COMPILER_COMMON_FLAGS} -std=c++11")
SET(CMAKE_ASM_FLAGS "--target=${MCU_TARGET} -O0 -g3 -ggdb -mthumb -mcpu=${MCU_CORE}")
SET(CMAKE_LINKER_FLAGS "${COMMON_FLAGS} -Wl,--gc-sections")
