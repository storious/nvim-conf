-- lua/core/keymaps.lua

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- window naviagttion
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

-- buffer naviagtion
keymap('n', '<Tab>', ':bnext<CR>', opts)
keymap('n', '<S-Tab>', ':bprevious<CR>', opts)
keymap('n', '<leader>x', ':bdelete!<CR>', opts)

-- file save
keymap('n', '<leader>w', ':w<CR>', opts)

-- terminal
keymap('t', '<Esc><Esc>', '<C-\\><C-n>', opts)
keymap('n', '<leader>t', ':terminal<CR>', opts)

-- file/plugin
vim.keymap.set('n', '<leader>e', ':lua MiniFiles.open()<CR>', { desc = 'open file explorer' })
vim.keymap.set('n', '<leader>f', ':Pick files<CR>', { desc = 'open file picker' })
vim.keymap.set('n', '<leader>h', ':Pick help<CR>', { desc = 'open help picker' })
vim.keymap.set('n', '<leader>b', ':Pick buffers<CR>', { desc = 'open buffer picker' })
vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { desc = 'diagnostic messages' })

-- file format
vim.keymap.set('n', '<leader>fm', function()
  vim.lsp.buf.format()
end, { desc = 'format' })

-- LSP
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP code action' })

-- diagnostic
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ wrap = true, count = -1 })
end, { desc = 'prev diagnostic' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ wrap = true, count = 1 })
end, { desc = 'next diagnostic' })


-- system parse board
vim.keymap.set({ 'n', 'v' }, '<C-c>', '"+y', { desc = 'copy to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<C-x>', '"+d', { desc = 'cut to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<C-p>', '"+p', { desc = 'paste to system clipboard' })

-- code complete
vim.keymap.set("i", "<C-n>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  else
    return "<C-x><C-o>"
  end
end, { expr = true })

-- auto pair
local function autopair(open, close)
  vim.keymap.set("i", open, function()
    return open .. close .. "<Left>"
  end, { expr = true })
end

local function close_pair(char)
  vim.keymap.set("i", char, function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()

    if line:sub(col + 1, col + 1) == char then
      return "<Right>"
    end

    return char
  end, { expr = true })
end

autopair("(", ")")
autopair("[", "]")
autopair("{", "}")
autopair('"', '"')
autopair("'", "'")

close_pair(")")
close_pair("]")
close_pair("}")
close_pair('"')
close_pair("'")
