-- autocmd --
-- auto format on saved
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    vim.lsp.buf.format()
  end,
  pattern = '*',
})

-- highlight hint in copy
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'highlight copying text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 500 })
  end,
})

-- lsp complete
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
  end,
})

vim.api.nvim_create_autocmd("InsertCharPre", {
  callback = function()
    local char = vim.v.char
    if char == '"' then
      vim.v.char = '""'
    elseif char == "'" then
      vim.v.char = "''"
    end
  end,
})
