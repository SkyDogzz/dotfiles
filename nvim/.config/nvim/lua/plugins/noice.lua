return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function(_, opts)
      local ok, noice = pcall(require, "noice")
      if not ok then
        return
      end

      noice.setup(opts or {
        lsp = {
          progress = { enabled = true },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = true,
        },
      })
    end,
  },
}
