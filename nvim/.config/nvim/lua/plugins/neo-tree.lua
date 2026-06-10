local function toggle_filtered_item(state, key)
  state.filtered_items = state.filtered_items or {}
  state.filtered_items[key] = not state.filtered_items[key]

  require("neo-tree.sources.manager").refresh(state.name)
end

local function neotree_open_position()
  local tab_wins = vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage())

  for _, winid in ipairs(tab_wins) do
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local ok_source = pcall(vim.api.nvim_buf_get_var, bufnr, "neo_tree_source")
    if ok_source then
      local ok_position, current_position = pcall(vim.api.nvim_buf_get_var, bufnr, "neo_tree_position")
      return ok_position and current_position or nil
    end
  end

  return nil
end

local function toggle_neotree(position)
  local manager = require("neo-tree.sources.manager")
  local open_position = neotree_open_position()

  if open_position == position then
    manager.close_all()
    return
  end

  if open_position then
    manager.close_all()
  end

  vim.cmd(position == "current" and "Neotree position=current" or "Neotree")
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
    {
      "<leader>e",
      function()
        toggle_neotree("left")
      end,
      desc = "Neo-tree",
    },
    {
      "<leader>E",
      function()
        toggle_neotree("current")
      end,
      desc = "Neo-tree current folder",
    },
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
