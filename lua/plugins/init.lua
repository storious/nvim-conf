-- require "plugins.setting"
local servers = require("plugins.servers")
local M = {}

vim.lsp.inlay_hint.enable(true)

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  severity_sort = true,
})

local function register_server_configs()
  for _, s in ipairs(servers) do
    local ok, cfg = pcall(function()
      return vim.lsp.config[s.name]
    end)

    if ok and cfg then
      vim.lsp.config(s.name, vim.tbl_deep_extend("force", cfg, s))
    else
      vim.lsp.config(s.name, s)
    end
  end
end

local function is_server_available(name)
  local s = vim.tbl_filter(function(x)
    return x.name == name
  end, servers)[1]

  if not s or not s.cmd or #s.cmd == 0 then
    return false
  end
  return vim.fn.executable(s.cmd[1]) == 1
end

function M.setup_lazy()
  register_server_configs()

  local enabled = {}

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
      local ft = vim.bo[args.buf].filetype
      if ft == "" then
        return
      end

      for _, s in ipairs(servers) do
        if enabled[s.name] then
          goto continue
        end

        if not s.filetypes or not vim.tbl_contains(s.filetypes, ft) then
          goto continue
        end

        if not is_server_available(s.name) then
          goto continue
        end

        vim.lsp.enable(s.name)
        enabled[s.name] = true

        ::continue::
      end
    end,
  })
end

return M
