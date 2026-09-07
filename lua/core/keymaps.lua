-- lua/core/keymaps.lua

-- The bundled matchit plugin costs several milliseconds during startup.
-- Preserve its extended %, g%, [% and ]% behavior, but pay that cost only on
-- the first use.
local function lazy_matchit(lhs)
  return function()
    vim.g.loaded_matchit = nil
    vim.cmd.packadd("matchit")
    vim.api.nvim_feedkeys(vim.keycode(lhs), "m", false)
  end
end

for _, lhs in ipairs({ "%", "g%", "[%", "]%" }) do
  vim.keymap.set({ "n", "x", "o" }, lhs, lazy_matchit(lhs), {
    desc = "Extended matching (lazy)",
    silent = true,
  })
end
vim.keymap.set("x", "a%", lazy_matchit("a%"), {
  desc = "Around matching block (lazy)",
  silent = true,
})

-- window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window', silent = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to below window', silent = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to above window', silent = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window', silent = true })

vim.keymap.set("n", "<M-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<M-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- buffer navigation
vim.keymap.set('n', ']b', ':bnext<CR>', { desc = 'Next buffer', silent = true })
vim.keymap.set('n', '[b', ':bprevious<CR>', { desc = 'Previous buffer', silent = true })
vim.keymap.set('n', '<leader>r', ':checktime<CR>', { desc = 'Check for external file changes', silent = true })

-- Keep the selection available for repeated indentation adjustments.
vim.keymap.set('x', '<', '<gv', { desc = 'Indent left and keep selection', silent = true })
vim.keymap.set('x', '>', '>gv', { desc = 'Indent right and keep selection', silent = true })

-- Display toggles affect only the current window or buffer.
vim.keymap.set('n', '<leader>uw', function()
  vim.wo.wrap = not vim.wo.wrap
end, { desc = 'Toggle line wrap', silent = true })
vim.keymap.set('n', '<leader>ul', function()
  vim.wo.list = not vim.wo.list
end, { desc = 'Toggle whitespace characters', silent = true })
vim.keymap.set('n', '<leader>uh', function()
  local filter = { bufnr = vim.api.nvim_get_current_buf() }
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
end, { desc = 'Toggle LSP inlay hints', silent = true })

-- buffer close
vim.keymap.set('n', '<leader>x', function()
  if vim.bo.buftype == 'terminal' then
    vim.cmd('bdelete!')
  else
    vim.cmd('bdelete')
  end
end, { desc = 'Close buffer (force for terminal)', silent = true })

-- tab management
vim.keymap.set('n', '<leader>tn', ':tabnext<CR>', { desc = 'Next tab', silent = true })
vim.keymap.set('n', '<leader>tp', ':tabprevious<CR>', { desc = 'Previous tab', silent = true })
vim.keymap.set('n', '<leader>tb', ':tabnew<CR>', { desc = 'New tab', silent = true })
vim.keymap.set('n', '<leader>tc', ':tabclose<CR>', { desc = 'Close tab', silent = true })
vim.keymap.set('n', '<leader>to', ':tabonly<CR>', { desc = 'Close other tabs', silent = true })
vim.keymap.set('n', '<leader>tmp', ':-tabmove<CR>', { desc = 'Move tab left', silent = true })
vim.keymap.set('n', '<leader>tmn', ':+tabmove<CR>', { desc = 'Move tab right', silent = true })

-- tab jump: <leader>1~9 to tab 1~9，<leader>0 to tab 10
for i = 1, 9 do
  vim.keymap.set('n', '<leader>' .. i, i .. 'gt', { desc = 'Jump to tab ' .. i, silent = true })
end
vim.keymap.set('n', '<leader>0', '10gt', { desc = 'Jump to tab 10', silent = true })

-- file save
vim.keymap.set('n', '<leader>w', ':w<CR>', { desc = 'Save file', silent = true })

-- terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode', silent = true })
vim.keymap.set('n', '<leader>tt', ':tabnew | terminal<CR>', { desc = 'Open terminal in new tab', silent = true })
vim.keymap.set('n', '<leader>tv', ':vsplit | terminal<CR>', { desc = 'Open terminal in vertical split', silent = true })

vim.keymap.set({ "n", "t" }, "<M-i>", function()
  require("plugins.terminal").toggle()
end, { desc = "Toggle Float Terminal" })

-- file tree
vim.keymap.set("n", "<leader>e", function()
  require("plugins").toggle_tree()
end, { desc = "Toggle NvimTree" })

-- file format
vim.keymap.set('n', '<leader>fm', function()
  require("core.lsp").format()
end, { desc = 'Format file', silent = true })

-- LSP
vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, { desc = 'Go to definition', silent = true })
vim.keymap.set('n', 'gD', function() vim.lsp.buf.declaration() end, { desc = 'Go to declaration', silent = true })
vim.keymap.set('n', 'gi', function() vim.lsp.buf.implementation() end, { desc = 'Go to implementation', silent = true })
vim.keymap.set('n', 'gr', function() vim.lsp.buf.references() end, { desc = 'Find references', silent = true })
vim.keymap.set('n', '<leader>rn', function() vim.lsp.buf.rename() end, { desc = 'Rename symbol', silent = true })
vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, { desc = 'LSP code action', silent = true })

-- diagnostic
vim.keymap.set('n', '<leader>dd', function() vim.diagnostic.open_float() end,
  { desc = 'Show diagnostic messages', silent = true })

vim.keymap.set("n", "<leader>q", function()
  vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })

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
