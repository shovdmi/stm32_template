1. `git clone https://github.com/shovdmi/stm32f4_template.git`
2. ```
    git submodule update --init stm32h
    cd stm32h
    git submodule update --init STM32F4xx
    cd ..
    ```
3. `git submodule update --init CMSIS_5`
4. In `compile_commands.json` : 
    * change `-DSTM32F4`, `-DSTM32F401xE`, `-Istm32/STM32F4`, `-mcpu=cortex-m4` accoring to your cpu
    * change `"directory": "C:/Path/to/your/project"`
5.  `make all`
 or `make -f Makefile_simple all`


# for Cmake

4. In CMakeLists.txt
    * change `PROJECT(STM32F407)`, `ADD_DEFINITIONS(-DSTM32F407xx)`, `ADD_DEFINITIONS(-DSTM32F4)`
    * change `stm32h/STM32F4xx/Source`, `stm32h/STM32F4xx/Include`
    * change `startup_stm32f207xx.s`, `system_stm32f2xx.c`

5. `mkdir build && cd build`
   `cmake .. -G "Unix Makefiles"`
   `cmake --build .`
  
