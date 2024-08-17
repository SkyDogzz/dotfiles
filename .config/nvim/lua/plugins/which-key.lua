return {
  "folke/which-key.nvim",
  lazy = true,
  event = "VeryLazy",
  opts = {},
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },{
      "<leader>l",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "LSP",
    },{
      "<leader>d",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Dispatch",
    },{
      "<leader>e",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Explorer",
    },{
      "<leader>f",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Fuzzy",
    },
  },
}
