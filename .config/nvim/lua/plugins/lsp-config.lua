return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
      })
      lspconfig.clangd.setup({
        capabilities = capabilities,
      })
      vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { noremap = true, silent = true, desc = "Go to Definition" })
      vim.keymap.set("n", "<leader>lh", vim.lsp.buf.hover, { noremap = true, silent = true, desc = "Hover Documentation" })
      vim.keymap.set("n", "<leader>lf", vim.lsp.buf.references, { noremap = true, silent = true, desc = "Find References" })
      vim.keymap.set("n", "<leader>ls", vim.lsp.buf.signature_help, { noremap = true, silent = true, desc = "Signature Help" })
      vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { noremap = true, silent = true, desc = "Rename Symbol" })
      vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { noremap = true, silent = true, desc = "Code Action" })
      vim.keymap.set("n", "<leader>lF", vim.lsp.buf.format, { noremap = true, silent = true, desc = "Format Document" })
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    lazy = false,
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<C-space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    lazy = false,
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  {
    "saadparwaiz1/cmp_luasnip",
    lazy = false,
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    lazy = false,
  },
  {
    "hrsh7th/cmp-buffer",
    lazy = false,
  },
  {
    "hrsh7th/cmp-path",
    lazy = false,
  },
}
