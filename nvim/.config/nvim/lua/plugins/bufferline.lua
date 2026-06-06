return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
  },
  opts = {
    options = {
      mode = "buffers",
      numbers = "ordinal",
      show_buffer_close_icons = true,
      show_close_icon = false,
      separator_style = "thin",
    },
  },
}
