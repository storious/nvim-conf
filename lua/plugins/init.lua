require "plugins.setting"

local servers = { "lua_ls", "ruff" }
vim.lsp.enable(servers)


vim.lsp.inlay_hint.enable(true)

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  severity_sort = true,
})
