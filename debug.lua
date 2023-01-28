require('dap-cortex-debug').setup {
    debug = false,  -- log debug messages
    --extension_path = '${env:USERPROFILE}/.vscode/extensions/marus25.cortex-debug-*/', -- path to cortex-debug extension, supports vim.fn.glob
    extension_path = 'C:/Users/User/.vscode/extensions/marus25.cortex-debug-1.6.10', -- path to cortex-debug extension, supports vim.fn.glob
    --extension_path = 'C:\\Users\\User\\.vscode\\extensions\\marus25.cortex-debug-1.6.10\\',
    lib_extension = nil, -- tries auto-detecting, e.g. 'so' on unix
    showDevDebugOutput = 'raw',
}

local dap_cortex_debug = require('dap-cortex-debug')
require('dap').configurations.c = {
    dap_cortex_debug.openocd_config {
        name = 'Example debugging with OpenOCD',
        --cwd = '${workspaceFolder}',
        cwd = 'C:/github_repositories/stm32_template/',
        --executable = '${workspaceFolder}/build/app',
        --configFiles = { '${workspaceFolder}/build/openocd/connect.cfg' },
        executable = 'C:/github_repositories/stm32_template/main.elf',
        configFiles = { 'C:/openocd/scripts/board/st_nucleo_f4.cfg' },
        gdbTarget = 'localhost:3333',
    },
}
require('dap').set_log_level('TRACE')
require('dap').configurations.asm = require('dap').configurations.c


vim.keymap.set('n', '<F5>', require('dap').continue)
vim.keymap.set('i', '<F5>', require('dap').continue)
vim.keymap.set('n', '<F9>', require('dap').toggle_breakpoint)
vim.keymap.set('i', '<F9>', require('dap').toggle_breakpoint)
vim.keymap.set('n', '<F10>', require('dap').step_over)
vim.keymap.set('i', '<F10>', require('dap').step_over)
vim.keymap.set('n', '<F11>', require('dap').step_into)
vim.keymap.set('i', '<F11:>', require('dap').step_into)
vim.keymap.set('n', '<S-F12>', require('dap').step_out)
vim.keymap.set('i', '<S-F12>', require('dap').step_out)
