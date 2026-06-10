return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
      },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      {
        "<leader>fs",
        function()
          require("telescope.builtin").live_grep({
            additional_args = function()
              return { "--hidden", "--no-ignore", "--fixed-strings" }
            end,
          })
        end,
        desc = "Grep string",
      },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Search keymaps" },
    },
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        file_ignore_patterns = { "node_modules", ".git", "build", "dist" },
      },
      pickers = {
        find_files = { hidden = true },
        live_grep = { additional_args = { "--hidden", "--no-ignore" } },
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("fzf")
    end,
  },
}
