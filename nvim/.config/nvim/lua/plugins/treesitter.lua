return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query" },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
