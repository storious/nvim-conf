-- lua/core/keymaps.lua
require "core.autopairs".setup()

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- window naviagttion
keymap('n', '<M-h>', '<C-w>h', opts)
keymap('n', '<M-j>', '<C-w>j', opts)
keymap('n', '<M-k>', '<C-w>k', opts)
keymap('n', '<M-l>', '<C-w>l', opts)

-- buffer navigation
vim.keymap.set('n', ']b', ':bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '[b', ':bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>x', ':bdelete!<CR>', { desc = 'Close buffer' })

-- tab management
vim.keymap.set('n', '<Tab>', ':tabnext<CR>', { desc = 'Next tab' })
vim.keymap.set('n', '<S-Tab>', ':tabprevious<CR>', { desc = 'Previous tab' })
vim.keymap.set('n', '<leader>tn', ':tabnew<CR>', { desc = 'New tab' })
vim.keymap.set('n', '<leader>tc', ':tabclose<CR>', { desc = 'Close tab' })
vim.keymap.set('n', '<leader>to', ':tabonly<CR>', { desc = 'Close other tabs' })
vim.keymap.set('n', '<leader>tmp', ':-tabmove<CR>', { desc = 'Move tab left' })
vim.keymap.set('n', '<leader>tmn', ':+tabmove<CR>', { desc = 'Move tab right' })

-- file save
keymap('n', '<leader>w', ':w<CR>', opts)

-- terminal
keymap('t', '<Esc><Esc>', '<C-\\><C-n>', opts)
vim.keymap.set('n', '<leader>tt', ':tabnew | terminal<CR>', { desc = 'Open terminal' })
vim.keymap.set('n', '<leader>tv', ':vsplit | terminal<CR>', { desc = 'Open terminal in vertical split' })

-- file tree
vim.keymap.set('n', '<leader>e', ':Lexplore<CR>', { desc = 'Open file explorer' })

-- file format
vim.keymap.set('n', '<leader>fm', function()
  vim.lsp.buf.format()
end, { desc = 'Format' })

-- LSP
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP code action' })

-- diagnostic
vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { desc = 'Diagnostic messages' })
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ wrap = true, count = -1 })
end, { desc = 'Prev diagnostic' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ wrap = true, count = 1 })
end, { desc = 'Next diagnostic' })


-- system clipboard
vim.keymap.set({ 'n', 'v' }, '<C-c>', '"+y', { desc = 'Copy to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<C-x>', '"+d', { desc = 'Cut to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<C-p>', '"+p', { desc = 'Paste to system clipboard' })

-- code complete
vim.keymap.set("i", "<C-n>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  else
    return "<C-x><C-o>"
  end
end, { expr = true })
