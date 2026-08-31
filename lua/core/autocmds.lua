local augroup = vim.api.nvim_create_augroup("CoreAutocmds", { clear = true })
local lsp = require("core.lsp")

local large_file_bytes = 2 * 1024 * 1024
local large_file_lines = 50000

local function mark_large_file(buf)
  if vim.b[buf].large_file then return end

  vim.b[buf].large_file = true
  vim.b[buf].miniindentscope_disable = true
  vim.b[buf].minipairs_disable = true
  vim.b[buf].minitrailspace_disable = true
  vim.b[buf].matchparen_timeout = 10
  vim.b[buf].matchparen_insert_timeout = 10

  vim.bo[buf].swapfile = false
  vim.bo[buf].undofile = false
  vim.bo[buf].syntax = ""
end

-- Keep expensive decorations and background analysis away from unusually
-- large files. The buffer flag is also consumed by Treesitter, Gitsigns and
-- LSP setup in lua/plugins/init.lua.
vim.api.nvim_create_autocmd("BufReadPre", {
  group = augroup,
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    local stat = path ~= "" and vim.uv.fs_stat(path) or nil
    if stat and stat.type == "file" and stat.size >= large_file_bytes then
      mark_large_file(args.buf)
    end
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function(args)
    if vim.api.nvim_buf_line_count(args.buf) >= large_file_lines then
      mark_large_file(args.buf)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function(args)
    if not vim.b[args.buf].large_file then return end

    local buf = args.buf
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) or not vim.b[buf].large_file then return end
      pcall(vim.treesitter.stop, buf)
      vim.bo[buf].syntax = ""
    end)
  end,
})

-- Format on save only when this buffer has a capable LSP client.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function(args)
    lsp.format(args.buf, { timeout_ms = 1000 })
  end,
})

-- highlight hint in copy
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "highlight copying text",
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ timeout = 500 })
  end,
})

-- important!!!!
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("W", "w", {})
