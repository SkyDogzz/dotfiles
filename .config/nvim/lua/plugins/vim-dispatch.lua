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

        if not executable_name then
          print("Executable name not found in Makefile")
          return nil
        end

        return executable_name
      end

      vim.keymap.set("n", "<leader>dm", ":Dispatch make<CR>", { noremap = true, silent = true, desc = "Run Make" })
      vim.keymap.set("n", "<leader>dr", function()
        local executable_name = get_executable_name()
        if executable_name then
          vim.cmd('Dispatch ./' .. executable_name)
        end
      end, { noremap = true, silent = true, desc = "Run Executable" })
    end
  },
}
