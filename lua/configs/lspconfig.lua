require("nvchad.configs.lspconfig").defaults()

local servers = { "gopls", "pylsp", "protols" }
vim.lsp.enable(servers)

-- pyright config
vim.lsp.config("pyright", {})

-- read :h vim.lsp.config for changing options of lsp servers
vim.lsp.config("lua_ls", {
  hint = { enable = true },
})
