return {
  "nvim-lualine/lualine.nvim",
  lazy = true,
  event = "VeryLazy",
  config = function()
    require("lualine").setup({
      options = {
        theme = "catppuccin-mocha",
      }
    })
  end,
}
