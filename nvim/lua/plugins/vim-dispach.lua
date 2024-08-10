return {
    {
        'tpope/vim-dispatch',
        config = function()
            local function get_executable_name()
                local makefile = io.open("Makefile", "r")
                if not makefile then
                    print("Makefile not found")
                    return nil
                end

                local executable_name = nil
                for line in makefile:lines() do
                    executable_name = string.match(line, "^%s*%w+%s*:%s*(.-)%s*$")
                    if executable_name then
                        break
                    end
                end
                makefile:close()

                if executable_name then
                    return executable_name
                else
                    print("Executable name not found in Makefile")
                    return nil
                end
            end

            vim.api.nvim_set_keymap('n', '<leader>dm', ':Dispatch make<CR>', { noremap = true, silent = true })
            vim.api.nvim_set_keymap('n', '<leader>dr', '', {
                noremap = true,
                silent = true,
                callback = function()
                    local executable_name = get_executable_name()
                    if executable_name then
                        vim.cmd('Dispatch ./' .. executable_name)
                    end
                end
            })
        end
    },
}
