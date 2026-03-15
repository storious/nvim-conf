-- lua/core/ui.lua

-- 1. global statusline
vim.o.laststatus = 3

-- 2. statusline content
_G.StatusLine = function()
  local mode = vim.fn.mode()
  local mode_map = {
    ['n']   = 'NORMAL',
    ['no']  = 'O-PENDING',
    ['nov'] = 'O-PENDING',
    ['noV'] = 'O-PENDING',
    ['i']   = 'INSERT',
    ['ic']  = 'INSERT',
    ['ix']  = 'INSERT',
    ['v']   = 'VISUAL',
    ['V']   = 'V-LINE',
    ['']    = 'V-BLOCK',
    ['c']   = 'COMMAND',
    ['R']   = 'REPLACE',
  }
  local current_mode = mode_map[mode] or mode

  -- custom highlight group
  local mode_hl = "StatusLine"
  if mode == "n" then
    mode_hl = "String"
  elseif mode == "i" then
    mode_hl = "Function"
  elseif mode == "v" or mode == "V" then
    mode_hl = "Number"
  elseif mode == "c" then
    mode_hl = "Keyword"
  end

  -- contact character
  return table.concat {
    "%#", mode_hl, "#",
    "  ", current_mode, " ",
    "%#StatusLine#",
    " %f ",
    "%h%m%r",
    "%=",
    "%#LineNr#",
    " %l:%c  ",
  }
end

vim.o.statusline = "%{%v:lua.StatusLine()%}"

-- auto match backgroud color
local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg

vim.api.nvim_set_hl(0, "StatusLine", { bg = normal_bg, fg = "#888888" })
