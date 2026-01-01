cmake_minimum_required(VERSION 3.8.0)

if(NOT CMAKE_GENERATOR STREQUAL "Unix Makefiles")
    message(FATAL_ERROR "generator is \"${CMAKE_GENERATOR}\"! You need to run \ncmake .. -G \"Unix Makefiles\"")
endif()
message("generator is ${CMAKE_GENERATOR}")

#-- Toolchain ------------------------------------------------------------------
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_CROSSCOMPILING 1)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

message("CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")

#  Without this flag, CMake is unable to pass the test compilation check
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
set(CMAKE_C_COMPILER_WORKS TRUE)
#set(CMAKE_CXX_COMPILER_WORKS TRUE)
# To fix compilation check: enable either these or CMAKE_TRY_COMPILE_TARGET_TYPE flag
#set(CMAKE_C_COMPILER_FORCED TRUE)
#set(CMAKE_CXX_COMPILER_FORCED TRUE)


## include(${CMAKE_CURRENT_LIST_DIR}/arm-none-eabi-toolchain.cmake)
# see https://stackoverflow.com/a/17275650 about `CACHE PATH "" FORCE `
set(TOOLCHAIN_PATH  "")
set(CMAKE_C_COMPILER   ${TOOLCHAIN_PATH}arm-none-eabi-gcc CACHE PATH "" FORCE)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH}arm-none-eabi-g++ CACHE PATH "" FORCE)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PATH}arm-none-eabi-gcc CACHE PATH "" FORCE)
set(CMAKE_LINKER       ${TOOLCHAIN_PATH}arm-none-eabi-gcc CACHE PATH "" FORCE)
set(CMAKE_SIZE         ${TOOLCHAIN_PATH}arm-none-eabi-size CACHE PATH "" FORCE)

#-- Project config -------------------------------------------------------------
project(STM32F401)                 # Project name

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    MESSAGE(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt." )
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

enable_language(ASM)                # Otherwise cmake ignores *.s files

#-- MCU config -----------------------------------------------------------------
set(MCU_CORE             cortex-m4)
set(MCU_FAMILY           cortex-m)
set(MCU_SERIES           STM32F4)
set(MCU_CHIP             STM32F4xx)
set(MCU_NAME             STM32F401xE)
set(MCU_TARGET           thumbv7m-none-none-eabi) # for clang

#-- Project paths --------------------------------------------------------------
set(APP_PATH              app)
set(PLATFORM_PATH         stm32h)
set(DEVICE_SRC_PATH       stm32h/${MCU_CHIP}/Source)
set(DEVICE_INC_PATH       stm32h/${MCU_CHIP}/Include)
set(CMSIS_CORE_INC_PATH   CMSIS_5/CMSIS/Core/Include)


set(APP_SRC
    # Moved to stm32f4 library
    #    ${DEVICE_SRC_PATH}/Templates/gcc/startup_stm32f401xe.s
    #    ${DEVICE_SRC_PATH}/Templates/system_stm32f4xx.c
    main.c
    )


set(EXECUTABLE ${PROJECT_NAME}.elf)
add_executable(${EXECUTABLE} ${APP_SRC})


target_sources(${EXECUTABLE} PRIVATE
    # Moved to stm32f4 library
    #     ${DEVICE_SRC_PATH}/Templates/system_stm32f4xx.c
    #     ${DEVICE_SRC_PATH}/Templates/gcc/startup_stm32f401xe.s  # enable_language(ASM). Otherwise *.s files are been ignored
    )

target_include_directories(${EXECUTABLE} PRIVATE
    # Moved to stm32f4 library
    #    ${APP_PATH}
    #    ${PLATFORM_PATH}
    #    ${CMSIS_CORE_INC_PATH}
    #    ${DEVICE_INC_PATH}
    )

target_compile_definitions(${EXECUTABLE} PRIVATE
    -D${MCU_NAME}
    -D${MCU_SERIES}
    )

#-- Libraries ------------------------------------------------------------------

#-- STM32F4 Sources -----------------------
add_library(stm32f4 STATIC EXCLUDE_FROM_ALL
    ${DEVICE_SRC_PATH}/Templates/system_stm32f4xx.c
    ${DEVICE_SRC_PATH}/Templates/gcc/startup_stm32f401xe.s  # enable_language(ASM). Otherwise *.s files are been ignored
    )
    # Specify include directories for stm32f4 library
target_include_directories(stm32f4 PUBLIC 
    ${PLATFORM_PATH}
    ${CMSIS_CORE_INC_PATH}
    ${DEVICE_INC_PATH}
)
target_compile_definitions(stm32f4 PRIVATE
    -D${MCU_NAME}
    -D${MCU_SERIES}
    )

#------------------------------------------
#add_library(printf STATIC EXCLUDE_FROM_ALL
#    printf/printf.c
#    )


#------------------------------------------
#add_library(tsrb STATIC EXCLUDE_FROM_ALL
#    tsrb/tsrb.c
#    )


target_link_libraries(${EXECUTABLE} PUBLIC
    stm32f4
    # tsrb
    # printf
    )

#-- Common flags ---------------------------------------------------------------
set(COMMON_FLAGS
    -mthumb
    -mcpu=${MCU_CORE}
    # If it seems like linker ignores -nostdlib options, remove from linker script:  /DISCARD/:{libc.a ( * ) libm.a ( * ) libgcc.a ( * )}, as it lead to linker to include those
    -nostdlib # -nostartfiles -nodefaultlibs -nolibc nostdlib++
    # $<$<COMPILE_LANGUAGE:CXX>:-std=c++11>  # see CMAKE_C_STANDARD
    # $<$<COMPILE_LANGUAGE:C>:-std=c11>      # see CMAKE_CXX_STANDARD
    --specs=nosys.specs
    --specs=nano.specs
    -g3 -ggdb
    )
## SET(COMPILER_COMMON_FLAGS "-Wall -Wextra -ffunction-sections -fdata-sections")
## SET(CMAKE_C_FLAGS   "${COMMON_FLAGS} ${COMPILER_COMMON_FLAGS} -std=c11"   CACHE STRING "c compiler flags")
## SET(CMAKE_CXX_FLAGS "${COMMON_FLAGS} ${COMPILER_COMMON_FLAGS} -std=c++11" CACHE STRING "c++ compiler flags")
## SET(CMAKE_ASM_FLAGS "-x,assembler-with-cpp -O0 -g3 -ggdb -mthumb -mcpu=${MCU_CORE}" CACHE STRING "assembler compiler flags")
## SET(CMAKE_LINKER_FLAGS "${COMMON_FLAGS} -Wl,--gc-sections"                CACHE STRING "executable linker flags")

target_compile_options(${EXECUTABLE} PRIVATE
    ${COMMON_FLAGS}
    -Wall -Wextra
    -ffunction-sections -fdata-sections
    )

target_link_options(${EXECUTABLE} PRIVATE
    ${COMMON_FLAGS}
    ${CMAKE_LINKER_FLAGS} 
    -T${CMAKE_SOURCE_DIR}/STM32F401RETx_FLASH.ld
    -Wl,-Map=${CMAKE_BINARY_DIR}/${PROJECT_NAME}.map
    -Wl,--print-memory-usage
    -Wl,--gc-sections
    )

#-- Project linking ------------------------------------------------------------
## TARGET_LINK_LIBRARIES(${PROJECT_NAME}.elf)


#-- Custom targets and commands ------------------------------------------------------------
ADD_CUSTOM_TARGET(${PROJECT_NAME}.hex  ALL DEPENDS ${PROJECT_NAME}.elf COMMAND ${CMAKE_OBJCOPY} -Oihex   ${PROJECT_NAME}.elf   ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.hex)
## ADD_CUSTOM_TARGET(${PROJECT_NAME}.bin  ALL DEPENDS ${PROJECT_NAME}.elf COMMAND ${CMAKE_OBJCOPY} -Obinary ${PROJECT_NAME}.elf   ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.bin)
ADD_CUSTOM_TARGET(${PROJECT_NAME}.dasm ALL DEPENDS ${PROJECT_NAME}.elf COMMAND ${CMAKE_OBJDUMP} "-DS"    ${PROJECT_NAME}.elf > ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.dasm)
ADD_CUSTOM_TARGET(PRINT_SIZES ALL DEPENDS ${PROJECT_NAME}.elf          COMMAND ${CMAKE_SIZE} ${PROJECT_NAME}.elf)
## #ADD_CUSTOM_COMMAND(TARGET ${PROJECT_NAME}.elf POST_BUILD              COMMAND ${CMAKE_SIZE} ${PROJECT_NAME}.elf)

