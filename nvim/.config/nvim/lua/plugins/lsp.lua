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
      ensure_installed = {
        "bashls",
        "csharp_ls",
        "clangd",
        "cssls",
        "gopls",
        "html",
        "jsonls",
        "lemminx",
        "marksman",
        "prismals",
        "rust_analyzer",
        "sqls",
        "taplo",
        "ts_ls",
        "yamlls",
      },
      automatic_installation = true,
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "clang-format",
        "csharpier",
        "goimports",
        "prettier",
        "shfmt",
        "sqlfluff",
        "taplo",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "stevearc/conform.nvim",
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

      vim.diagnostic.config({
        virtual_text = {
          spacing = 2,
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      vim.filetype.add({
        extension = {
          csproj = "xml",
          slnx = "xml",
        },
      })

      vim.api.nvim_create_user_command("Format", function(args)
        local has_conform, conform = pcall(require, "conform")
        if has_conform then
          conform.format({
            async = true,
            lsp_format = "fallback",
            range = args.range > 0
              and {
                start = { args.line1, 0 },
                ["end"] = { args.line2, 0 },
              }
              or nil,
          })
          return
        end

        vim.lsp.buf.format({
          async = true,
        })
      end, { desc = "Format buffer", range = true })

      vim.lsp.config.clangd = {
        capabilities = capabilities,
      }
      vim.lsp.config.bashls = {
        capabilities = capabilities,
      }
      vim.lsp.config.csharp_ls = {
        capabilities = capabilities,
      }
      vim.lsp.config.cssls = {
        capabilities = capabilities,
      }
      vim.lsp.config.gopls = {
        capabilities = capabilities,
      }
      vim.lsp.config.html = {
        capabilities = capabilities,
      }
      vim.lsp.config.jsonls = {
        capabilities = capabilities,
      }
      vim.lsp.config.lemminx = {
        capabilities = capabilities,
      }
      vim.lsp.config.marksman = {
        capabilities = capabilities,
      }
      vim.lsp.config.prismals = {
        capabilities = capabilities,
      }
      vim.lsp.config.rust_analyzer = {
        capabilities = capabilities,
      }
      vim.lsp.config.sqls = {
        capabilities = capabilities,
      }
      vim.lsp.config.taplo = {
        capabilities = capabilities,
      }
      vim.lsp.config.yamlls = {
        capabilities = capabilities,
      }
      vim.lsp.config.ts_ls = {
        capabilities = capabilities,
      }
      vim.lsp.enable("clangd")
      vim.lsp.enable("bashls")
      vim.lsp.enable("csharp_ls")
      vim.lsp.enable("cssls")
      vim.lsp.enable("gopls")
      vim.lsp.enable("html")
      vim.lsp.enable("jsonls")
      vim.lsp.enable("lemminx")
      vim.lsp.enable("marksman")
      vim.lsp.enable("prismals")
      vim.lsp.enable("rust_analyzer")
      vim.lsp.enable("sqls")
      vim.lsp.enable("taplo")
      vim.lsp.enable("yamlls")
      vim.lsp.enable("ts_ls")
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        cs = { "csharpier" },
        css = { "prettier" },
        go = { "goimports", "gofmt" },
        html = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        markdown = { "prettier" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        sql = { "sqlfluff" },
        xml = { "xmllint" },
        toml = { "taplo" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        yaml = { "prettier" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        c = { "clangtidy", "cppcheck" },
        cpp = { "clangtidy", "cppcheck" },
      },
    },
    config = function(_, opts)
      local lint = require("lint")

      lint.linters_by_ft = opts.linters_by_ft

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
