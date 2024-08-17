return {
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { noremap = true, silent = true, desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { noremap = true, silent = true, desc = "Live Grep" })
      vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { noremap = true, silent = true, desc = "Find Old Files" })
      require("telescope").load_extension("ui-select")
    end,
  },
}
