return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "clangd" },
      automatic_installation = true,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "clang-format" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    event = { "BufReadPre", "BufNewFile" },
    cmd = "Format",
    keys = {
      { "K", vim.lsp.buf.hover, mode = "n", desc = "LSP hover" },
      { "gd", vim.lsp.buf.definition, mode = "n", desc = "Go to definition" },
      { "gr", vim.lsp.buf.references, mode = "n", desc = "References" },
      { "gD", vim.lsp.buf.declaration, mode = "n", desc = "Go to declaration" },
      { "gi", vim.lsp.buf.implementation, mode = "n", desc = "Go to implementation" },
      { "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "v" }, desc = "Code action" },
      { "<leader>rn", vim.lsp.buf.rename, mode = "n", desc = "Rename" },
      { "[d", vim.diagnostic.goto_prev, mode = "n", desc = "Previous diagnostic" },
      { "]d", vim.diagnostic.goto_next, mode = "n", desc = "Next diagnostic" },
      { "<leader>xd", vim.diagnostic.open_float, mode = "n", desc = "Diagnostic float" },
    },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_cmp, cmp_capabilities = pcall(require, "cmp_nvim_lsp")
      if has_cmp then
        capabilities = cmp_capabilities.default_capabilities(capabilities)
      end

      vim.api.nvim_create_user_command("Format", function()
        vim.lsp.buf.format()
      end, { desc = "Format buffer", range = true })

      vim.lsp.config.clangd = {
        capabilities = capabilities,
      }
      vim.lsp.enable("clangd")
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    },
  },
}
