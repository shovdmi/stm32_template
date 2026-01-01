#-- System ---------------------------------------------------------------------
SET(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_CROSSCOMPILING 1)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

#  Without this flag, CMake is unable to pass the test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
#set(CMAKE_C_COMPILER_WORKS TRUE)
#set(CMAKE_CXX_COMPILER_WORKS TRUE)
# To fix compilation check: enable either these or CMAKE_TRY_COMPILE_TARGET_TYPE flag
#set(CMAKE_C_COMPILER_FORCED TRUE)
#set(CMAKE_CXX_COMPILER_FORCED TRUE)

#-- Toolchain ------------------------------------------------------------------
# see https://stackoverflow.com/a/17275650 about `CACHE PATH "" FORCE `
set(TOOLCHAIN_PATH  "")
SET(CMAKE_C_COMPILER   ${TOOLCHAIN_PATH}arm-none-eabi-gcc)
SET(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH}arm-none-eabi-g++)
SET(CMAKE_ASM_COMPILER ${TOOLCHAIN_PATH}arm-none-eabi-gcc)
SET(CMAKE_LINKER       ${TOOLCHAIN_PATH}arm-none-eabi-gcc)
SET(CMAKE_OBJCOPY      ${TOOLCHAIN_PATH}arm-none-eabi-objcopy)
SET(CMAKE_OBJDUMP      ${TOOLCHAIN_PATH}arm-none-eabi-objdump)
SET(CMAKE_SIZE         ${TOOLCHAIN_PATH}arm-none-eabi-size   )

ENABLE_LANGUAGE(C)
ENABLE_LANGUAGE(CXX)
ENABLE_LANGUAGE(ASM)