-- lua/core/keymaps.lua

-- window navigation
vim.keymap.set('n', '<M-h>', '<C-w>h', { desc = 'Move to left window', silent = true })
vim.keymap.set('n', '<M-j>', '<C-w>j', { desc = 'Move to below window', silent = true })
vim.keymap.set('n', '<M-k>', '<C-w>k', { desc = 'Move to above window', silent = true })
vim.keymap.set('n', '<M-l>', '<C-w>l', { desc = 'Move to right window', silent = true })

-- buffer navigation
vim.keymap.set('n', ']b', ':bnext<CR>', { desc = 'Next buffer', silent = true })
vim.keymap.set('n', '[b', ':bprevious<CR>', { desc = 'Previous buffer', silent = true })

-- buffer close
vim.keymap.set('n', '<leader>x', function()
  if vim.bo.buftype == 'terminal' then
    vim.cmd('bdelete!')
  else
    vim.cmd('bdelete')
  end
end, { desc = 'Close buffer (force for terminal)', silent = true })

-- tab management
vim.keymap.set('n', '<Tab>', ':tabnext<CR>', { desc = 'Next tab', silent = true })
vim.keymap.set('n', '<S-Tab>', ':tabprevious<CR>', { desc = 'Previous tab', silent = true })
vim.keymap.set('n', '<leader>tn', ':tabnew<CR>', { desc = 'New tab', silent = true })
vim.keymap.set('n', '<leader>tc', ':tabclose<CR>', { desc = 'Close tab', silent = true })
vim.keymap.set('n', '<leader>to', ':tabonly<CR>', { desc = 'Close other tabs', silent = true })
vim.keymap.set('n', '<leader>tmp', ':-tabmove<CR>', { desc = 'Move tab left', silent = true })
vim.keymap.set('n', '<leader>tmn', ':+tabmove<CR>', { desc = 'Move tab right', silent = true })

-- file save
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file', silent = true })

-- terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode', silent = true })
vim.keymap.set('n', '<leader>tt', ':tabnew | terminal<CR>', { desc = 'Open terminal in new tab', silent = true })
vim.keymap.set('n', '<leader>tv', ':vsplit | terminal<CR>', { desc = 'Open terminal in vertical split', silent = true })

-- file tree
vim.keymap.set('n', '<leader>e', ':Lexplore<CR>', { desc = 'Open file explorer', silent = true })

-- file format
vim.keymap.set('n', '<leader>fm', function()
  vim.lsp.buf.format()
end, { desc = 'Format file', silent = true })

-- LSP
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition', silent = true })
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration', silent = true })
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation', silent = true })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Find references', silent = true })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol', silent = true })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP code action', silent = true })

-- diagnostic
vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { desc = 'Show diagnostic messages', silent = true })
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ wrap = true, count = -1 })
end, { desc = 'Previous diagnostic', silent = true })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ wrap = true, count = 1 })
end, { desc = 'Next diagnostic', silent = true })

-- system clipboard
vim.keymap.set({ 'n', 'v' }, '<C-c>', '"+y', { desc = 'Copy to system clipboard', silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-x>', '"+d', { desc = 'Cut to system clipboard', silent = true })
vim.keymap.set({ 'n', 'v' }, '<C-p>', '"+p', { desc = 'Paste from system clipboard', silent = true })

-- code complete
vim.keymap.set("i", "<C-n>", function()
  if vim.fn.pumvisible() == 1 then
    return "<C-n>"
  else
    return "<C-x><C-o>"
  end
end, { expr = true, silent = true })
