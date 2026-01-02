cmake_minimum_required(VERSION 3.8.0)

if(NOT CMAKE_GENERATOR STREQUAL "Unix Makefiles")
    message(FATAL_ERROR "generator is \"${CMAKE_GENERATOR}\"! You need to run \ncmake .. -G \"Unix Makefiles\"")
endif()
message("generator is ${CMAKE_GENERATOR}")

if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    MESSAGE(FATAL_ERROR "In-source builds not allowed. Please make a new directory (called a build directory) and run CMake from there. You may need to remove CMakeCache.txt." )
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#-- Toolchain ------------------------------------------------------------------
include(${CMAKE_CURRENT_LIST_DIR}/arm-none-eabi-toolchain.cmake)
message("CMAKE_SYSTEM_NAME: ${CMAKE_SYSTEM_NAME}")

#-- Project config -------------------------------------------------------------
PROJECT(firmware)                 # Project name
set(EXECUTABLE ${PROJECT_NAME}.elf)
set(APP_SRC main.c)
add_executable(${EXECUTABLE} ${APP_SRC})

#-- Project paths --------------------------------------------------------------
target_sources(${EXECUTABLE} PRIVATE # Repeated calls of 'target_sources' for the same <target> append items
    )
target_include_directories(${EXECUTABLE} PRIVATE
    )
target_compile_definitions(${EXECUTABLE} PRIVATE
    # -D${MCU_NAME} -D${MCU_SERIES   # provided by stm32f4.cmake
    )

#-- Libraries ------------------------------------------------------------------
# all libs expect COMMON_COMPILE_FLAGS to be set
set(COMMON_COMPILE_FLAGS
    -Wall -Wextra
    -ffunction-sections -fdata-sections
    -Os
    -g3 -ggdb
    )
# Provides TARGET_COMMON_FLAGS, TARGET_DEFAULT_LD_SCRIPT
include(lpc111x.cmake) # system_stm32f4xx, startup_stm32f401xe 

set(COMMON_COMPILE_FLAGS
    ${COMMON_COMPILE_FLAGS}
    ${TARGET_COMPILE_FLAGS}
    )
message("COMMON_COMPILE_FLAGS ${COMMON_COMPILE_FLAGS}")

# include(tsrb.cmake)
include(printf.cmake)

target_link_libraries(${EXECUTABLE} PUBLIC
    lpc111x
    #tsrb
    printf
    )

target_compile_options(${EXECUTABLE} PRIVATE
    ${COMMON_COMPILE_FLAGS}
    )
# Another way is to set CMAKE_C_FLAGS, CMAKE_CXX_FLAGS, CMAKE_ASM_FLAGS
# CMAKE_ASM_FLAGS is a bit special: SET(CMAKE_ASM_FLAGS "-x,assembler-with-cpp -O0 -g3 -ggdb -mthumb -mcpu=${MCU_CORE}"

target_link_options(${EXECUTABLE} PRIVATE
    ${COMMON_COMPILE_FLAGS}
    # If it seems like linker ignores -nostdlib options, remove from linker script:  /DISCARD/:{libc.a ( * ) libm.a ( * ) libgcc.a ( * )}, as it lead to linker to include those
    -nostdlib # -nostartfiles -nodefaultlibs -nolibc nostdlib++
    --specs=nosys.specs
    --specs=nano.specs
    -T${TARGET_DEFAULT_LD_SCRIPT}
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
ADD_CUSTOM_TARGET(${PROJECT_NAME}.dasm ALL DEPENDS ${PROJECT_NAME}.elf COMMAND ${CMAKE_OBJDUMP} "-DSl"    ${PROJECT_NAME}.elf > ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.dasm)
ADD_CUSTOM_TARGET(PRINT_SIZES ALL DEPENDS ${PROJECT_NAME}.elf          COMMAND ${CMAKE_SIZE} ${PROJECT_NAME}.elf)
## #ADD_CUSTOM_COMMAND(TARGET ${PROJECT_NAME}.elf POST_BUILD              COMMAND ${CMAKE_SIZE} ${PROJECT_NAME}.elf)
