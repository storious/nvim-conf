local M = {}

local formatting_method = "textDocument/formatting"

function M.has_formatter(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return #vim.lsp.get_clients({
    bufnr = bufnr,
    method = formatting_method,
  }) > 0
end

function M.format(bufnr, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not M.has_formatter(bufnr) then return false end

  vim.lsp.buf.format(vim.tbl_extend("force", opts or {}, { bufnr = bufnr }))
  return true
end

return M
