add_library(printf STATIC EXCLUDE_FROM_ALL
    printf/printf.c
)
target_include_directories(printf PUBLIC
    printf
)
target_compile_definitions(printf PRIVATE
    PRINTF_DISABLE_SUPPORT_FLOAT      
    PRINTF_DISABLE_SUPPORT_EXPONENTIAL    
    PRINTF_DISABLE_SUPPORT_LONG_LONG  
    PRINTF_DISABLE_SUPPORT_PTRDIFF_T  
)
target_compile_options(printf PRIVATE
    ${COMMON_COMPILE_FLAGS}
)
