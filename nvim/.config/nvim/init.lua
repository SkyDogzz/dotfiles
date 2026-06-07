require("config.options")

vim.treesitter = vim.treesitter or {}
vim.treesitter.language = vim.treesitter.language or {}

if not vim.treesitter.language.ft_to_lang then
  vim.treesitter.language.ft_to_lang = function(ft)
    if vim.treesitter.language.get_lang then
      return vim.treesitter.language.get_lang(ft) or ft
    end

    return ft
  end
end

require("config.lazy")
