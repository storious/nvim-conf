require("nvchad.configs.lspconfig").defaults()

local servers = { "gopls", "pylsp" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
vim.lsp.config("lua_ls", {
  hint = { enable = true },
})
