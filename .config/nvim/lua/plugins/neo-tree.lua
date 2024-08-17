return {
  "nvim-neo-tree/neo-tree.nvim",
  lazy = false,
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    vim.keymap.set("n", "<leader>ee", ":Neotree filesystem reveal left<CR>",
      { noremap = true, silent = true, desc = "File Explorer" })
    vim.keymap.set("n", "<leader>eb", ":Neotree buffers reveal float<CR>",
      { noremap = true, silent = true, desc = "Buffer Explorer" })
  end,
}
