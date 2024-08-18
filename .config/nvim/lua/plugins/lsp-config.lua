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

      local servers = { "lua_ls", "clangd" }

      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities,
        })
      end

      local mappings = {
        ld = { cmd = vim.lsp.buf.definition, desc = "Go to Definition" },
        lh = { cmd = vim.lsp.buf.hover, desc = "Hover Documentation" },
        lf = { cmd = vim.lsp.buf.references, desc = "Find References" },
        ls = { cmd = vim.lsp.buf.signature_help, desc = "Signature Help" },
        lr = { cmd = vim.lsp.buf.rename, desc = "Rename Symbol" },
        la = { cmd = vim.lsp.buf.code_action, desc = "Code Action" },
        ll = { cmd = vim.lsp.buf.format, desc = "Format Document" },
      }

      for key, map in pairs(mappings) do
        vim.keymap.set("n", "<leader>" .. key, map.cmd, { noremap = true, silent = true, desc = map.desc })
      end
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
