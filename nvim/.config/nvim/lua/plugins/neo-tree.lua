local function toggle_filtered_item(state, key)
  state.filtered_items = state.filtered_items or {}
  state.filtered_items[key] = not state.filtered_items[key]

  require("neo-tree.sources.manager").refresh(state.name)
end

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Neo-tree" },
  },
  opts = {
    close_if_last_window = true,
    popup_border_style = "rounded",
    filesystem = {
      filtered_items = {
        hide_dotfiles = true,
        hide_gitignored = true,
      },
      follow_current_file = { enabled = true },
      hijack_netrw_behavior = "open_default",
      use_libuv_file_watcher = true,
    },
    window = {
      position = "left",
      width = 30,
      mappings = {
        ["H"] = {
          command = function(state)
            toggle_filtered_item(state, "hide_dotfiles")
          end,
          desc = "Toggle hidden files",
        },
        ["I"] = {
          command = function(state)
            toggle_filtered_item(state, "hide_gitignored")
          end,
          desc = "Toggle gitignored files",
        },
      },
    },
  },
}
