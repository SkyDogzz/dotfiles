return {
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    event = "VimEnter",
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        integrations = {
          neotree = {
            enabled = true,
            transparent_panel = true,
          },
        },
      })
      vim.cmd("colorscheme catppuccin-frappe")
    end,
  },
}
