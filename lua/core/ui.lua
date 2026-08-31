-- lua/core/ui.lua

-- 1. global statusline
vim.o.laststatus = 3

-- 2. Define custom highlight groups for modes (Monokai Style)
local function setup_colors()
  -- Monokai Classic Color Palette
  local colors = {
    normal   = { bg = "#66d9ef", fg = "#272822" }, -- Cyan bg, Dark text
    insert   = { bg = "#a6e22e", fg = "#272822" }, -- Green bg, Dark text
    visual   = { bg = "#ae81ff", fg = "#272822" }, -- Purple bg, Dark text
    command  = { bg = "#fd971f", fg = "#272822" }, -- Orange bg, Dark text
    replace  = { bg = "#f92672", fg = "#272822" }, -- Red/Pink bg, Dark text
    terminal = { bg = "#75715e", fg = "#f8f8f2" }, -- Grey bg, Light text
    inactive = { bg = "NONE", fg = "#75715e" },
  }

  -- Set highlights
  vim.api.nvim_set_hl(0, "SLModeNormal", { bg = colors.normal.bg, fg = colors.normal.fg, bold = true })
  vim.api.nvim_set_hl(0, "SLModeInsert", { bg = colors.insert.bg, fg = colors.insert.fg, bold = true })
  vim.api.nvim_set_hl(0, "SLModeVisual", { bg = colors.visual.bg, fg = colors.visual.fg, bold = true })
  vim.api.nvim_set_hl(0, "SLModeCommand", { bg = colors.command.bg, fg = colors.command.fg, bold = true })
  vim.api.nvim_set_hl(0, "SLModeReplace", { bg = colors.replace.bg, fg = colors.replace.fg, bold = true })
  vim.api.nvim_set_hl(0, "SLModeTerminal", { bg = colors.terminal.bg, fg = colors.terminal.fg, bold = true })

  -- Git Status & Branch Highlights (Monokai Colors)
  vim.api.nvim_set_hl(0, "SLGitBranch", { fg = "#66d9ef", bg = "NONE" }) -- Cyan for branch name
  vim.api.nvim_set_hl(0, "SLGitAdd", { fg = "#a6e22e", bg = "NONE" })    -- Green
  vim.api.nvim_set_hl(0, "SLGitChange", { fg = "#e6db74", bg = "NONE" }) -- Yellow
  vim.api.nvim_set_hl(0, "SLGitDel", { fg = "#f92672", bg = "NONE" })    -- Red
end

-- Run setup
setup_colors()

-- Re-apply colors when colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = setup_colors,
})

-- Git branch status
local function get_git_info()
  local dict = vim.b.gitsigns_status_dict
  if not dict or not dict.head then return "" end

  local result = "%#SLGitBranch#" .. " \u{e725} " .. dict.head .. " "

  if dict.added and dict.added > 0 then
    result = result .. "%#SLGitAdd#" .. " +" .. dict.added
  end
  if dict.changed and dict.changed > 0 then
    result = result .. "%#SLGitChange#" .. " ~" .. dict.changed
  end
  if dict.removed and dict.removed > 0 then
    result = result .. "%#SLGitDel#" .. " -" .. dict.removed
  end

  result = result .. "%#StatusLine# "
  return result
end

-- 3. Statusline content
local mode_config = {
  n = { name = "NORMAL", hl = "SLModeNormal" },
  no = { name = "O-PENDING", hl = "SLModeNormal" },
  nov = { name = "O-PENDING", hl = "SLModeNormal" },
  noV = { name = "O-PENDING", hl = "SLModeNormal" },
  i = { name = "INSERT", hl = "SLModeInsert" },
  ic = { name = "INSERT", hl = "SLModeInsert" },
  ix = { name = "INSERT", hl = "SLModeInsert" },
  v = { name = "VISUAL", hl = "SLModeVisual" },
  V = { name = "V-LINE", hl = "SLModeVisual" },
  ["\22"] = { name = "V-BLOCK", hl = "SLModeVisual" },
  c = { name = "COMMAND", hl = "SLModeCommand" },
  R = { name = "REPLACE", hl = "SLModeReplace" },
  t = { name = "TERMINAL", hl = "SLModeTerminal" },
}

local function path_tail(path)
  return path:match("[^/\\]+$") or path
end

local cwd_name = path_tail(vim.uv.cwd() or "")
local path_display = cwd_name

local function update_path_display()
  local filename = path_tail(vim.api.nvim_buf_get_name(0))
  path_display = filename == "" and cwd_name or (cwd_name .. " / " .. filename)
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "DirChanged" }, {
  callback = function(event)
    if event.event == "DirChanged" then
      cwd_name = path_tail(vim.uv.cwd() or "")
    end
    update_path_display()
  end,
})
update_path_display()

_G.StatusLine = function()
  local mode = vim.fn.mode()
  local current = mode_config[mode]
  if not current then
    current = { name = mode, hl = "SLModeNormal" }
  end

  -- Build statusline string
  return table.concat {
    "%#", current.hl, "#",   -- Start custom highlight
    "  ", current.name, " ", -- Mode name
    "%#StatusLine#",         -- Reset highlight
    " ", path_display, " ",  -- [Replaced %f] Display new path format
    "%h%m%r",                -- Help, Modified, Read-only flags
    get_git_info(),          -- Add Git branch + status
    "%=",                    -- Right align
    "%#LineNr#",             -- Position highlight
    " %l:%c  ",              -- Line and column
  }
end

vim.o.statusline = "%{%v:lua.StatusLine()%}"

-- 4. Statusline background matching
-- Keep the main statusline background clean/transparent
local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
vim.api.nvim_set_hl(0, "StatusLine", { bg = normal_bg, fg = "#888888", underline = false })

-- 5. Cache the tabline instead of rebuilding it on every redraw.
local function update_tabline()
  local tabpages = vim.api.nvim_list_tabpages()
  local current_tabpage = vim.api.nvim_get_current_tabpage()
  local parts = {}

  for index, tabpage in ipairs(tabpages) do
    local window = vim.api.nvim_tabpage_get_win(tabpage)
    local buffer = vim.api.nvim_win_get_buf(window)
    local file_name = path_tail(vim.api.nvim_buf_get_name(buffer))
    if file_name == "" then file_name = "[Empty]" end

    local highlight = tabpage == current_tabpage and "%#SLModeNormal#" or "%#StatusLine#"
    parts[#parts + 1] = highlight .. "%" .. index .. "T " .. index .. ": " .. file_name .. " %T"
  end

  parts[#parts + 1] = "%#StatusLine#"
  vim.o.tabline = table.concat(parts)
  vim.o.showtabline = #tabpages > 1 and 2 or 0
end

vim.api.nvim_create_autocmd({ "BufDelete", "BufEnter", "BufFilePost", "TabEnter", "TabNew", "TabClosed", "WinEnter" }, {
  callback = update_tabline,
})
update_tabline()


local float_bg = "#1e1e1e"

-- 7. Float window
vim.api.nvim_set_hl(0, "NormalFloat", {
  bg = float_bg,
  fg = "#f8f8f2",
  blend = 0
})

-- 8. border
vim.api.nvim_set_hl(0, "FloatBorder", {
  bg = float_bg,
  fg = "#66d9ef",
  blend = 0
})
