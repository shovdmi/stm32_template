cmake_minimum_required(VERSION 3.8.0)

if(NOT CMAKE_GENERATOR STREQUAL "Unix Makefiles")
    message(FATAL_ERROR "generator is \"${CMAKE_GENERATOR}\"! You need to run \ncmake .. -G \"Unix Makefiles\"")
endif()
message("generator is ${CMAKE_GENERATOR}")

#-- Toolchain ------------------------------------------------------------------
include(${CMAKE_CURRENT_LIST_DIR}/arm-none-eabi-toolchain.cmake)
message("CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")

#-- Project config -------------------------------------------------------------
project(firmware)                 # Project name

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    MESSAGE(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt." )
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#enable_language(ASM)                # Otherwise cmake ignores *.s files

#-- Project paths --------------------------------------------------------------
set(APP_PATH              app)
set(APP_SRC
    main.c
    )

set(EXECUTABLE ${PROJECT_NAME}.elf)
add_executable(${EXECUTABLE} ${APP_SRC})


target_sources(${EXECUTABLE} PRIVATE
    )

target_include_directories(${EXECUTABLE} PRIVATE
    )

target_compile_definitions(${EXECUTABLE} PRIVATE
    # -D${MCU_NAME}    # provided by stm32f4.cmake
    # -D${MCU_SERIES   # provided by stm32f4.cmake
    )

#-- Libraries ------------------------------------------------------------------
# Provides  MCU_CORE cortex-m4, MCU_FAMILY cortex-m, MCU_SERIES STM32F4, 
# MCU_CHIP STM32F4xx, MCU_NAME STM32F401xE, (for clang) MCU_TARGET thumbv7m-none-none-eabi 
include(stm32f4.cmake) # system_stm32f4xx, startup_stm32f401xe
#include(tsrb.cmake)
#include(printf.cmake)

target_link_libraries(${EXECUTABLE} PUBLIC
    stm32f4
    #tsrb
    #printf
    )

#-- Common flags ---------------------------------------------------------------
set(COMMON_FLAGS
    -mthumb
    -mcpu=${MCU_CORE}
    # $<$<COMPILE_LANGUAGE:CXX>:-std=c++11>  # see CMAKE_C_STANDARD
    # $<$<COMPILE_LANGUAGE:C>:-std=c11>      # see CMAKE_CXX_STANDARD
    -g3 -ggdb
    )

target_compile_options(${EXECUTABLE} PRIVATE
    ${COMMON_FLAGS}
    -Wall -Wextra
    -ffunction-sections -fdata-sections
    )
# Another way is to set CMAKE_C_FLAGS, CMAKE_CXX_FLAGS, CMAKE_ASM_FLAGS
# CMAKE_ASM_FLAGS is a bit special: SET(CMAKE_ASM_FLAGS "-x,assembler-with-cpp -O0 -g3 -ggdb -mthumb -mcpu=${MCU_CORE}"

target_link_options(${EXECUTABLE} PRIVATE
    ${COMMON_FLAGS}
    # If it seems like linker ignores -nostdlib options, remove from linker script:  /DISCARD/:{libc.a ( * ) libm.a ( * ) libgcc.a ( * )}, as it lead to linker to include those
    -nostdlib # -nostartfiles -nodefaultlibs -nolibc nostdlib++
    --specs=nosys.specs
    --specs=nano.specs
    -T${CMAKE_SOURCE_DIR}/STM32F401RETx_FLASH.ld
    -Wl,-Map=${CMAKE_BINARY_DIR}/${PROJECT_NAME}.map
    -Wl,--print-memory-usage
    -Wl,--gc-sections
    )
# Another way is to set CMAKE_LINKER_FLAGS

#-- Project linking ------------------------------------------------------------
## TARGET_LINK_LIBRARIES(${PROJECT_NAME}.elf)


#-- Custom targets and commands ------------------------------------------------------------
ADD_CUSTOM_TARGET(${PROJECT_NAME}.hex  ALL DEPENDS ${PROJECT_NAME}.elf COMMAND ${CMAKE_OBJCOPY} -Oihex   ${PROJECT_NAME}.elf   ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.hex)
## ADD_CUSTOM_TARGET(${PROJECT_NAME}.bin  ALL DEPENDS ${PROJECT_NAME}.elf COMMAND ${CMAKE_OBJCOPY} -Obinary ${PROJECT_NAME}.elf   ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.bin)
ADD_CUSTOM_TARGET(${PROJECT_NAME}.dasm ALL DEPENDS ${PROJECT_NAME}.elf COMMAND ${CMAKE_OBJDUMP} "-DS"    ${PROJECT_NAME}.elf > ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.dasm)
ADD_CUSTOM_TARGET(PRINT_SIZES ALL DEPENDS ${PROJECT_NAME}.elf          COMMAND ${CMAKE_SIZE} ${PROJECT_NAME}.elf)
## #ADD_CUSTOM_COMMAND(TARGET ${PROJECT_NAME}.elf POST_BUILD              COMMAND ${CMAKE_SIZE} ${PROJECT_NAME}.elf)
