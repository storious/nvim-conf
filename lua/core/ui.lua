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
end

-- Run setup
setup_colors()

-- Re-apply colors when colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = setup_colors,
})

-- 3. Statusline content
_G.StatusLine = function()
  local mode = vim.fn.mode()

  -- Mode mapping
  local mode_config = {
    ['n']   = { name = 'NORMAL', hl = 'SLModeNormal' },
    ['no']  = { name = 'O-PENDING', hl = 'SLModeNormal' },
    ['nov'] = { name = 'O-PENDING', hl = 'SLModeNormal' },
    ['noV'] = { name = 'O-PENDING', hl = 'SLModeNormal' },
    ['i']   = { name = 'INSERT', hl = 'SLModeInsert' },
    ['ic']  = { name = 'INSERT', hl = 'SLModeInsert' },
    ['ix']  = { name = 'INSERT', hl = 'SLModeInsert' },
    ['v']   = { name = 'VISUAL', hl = 'SLModeVisual' },
    ['V']   = { name = 'V-LINE', hl = 'SLModeVisual' },
    ['']    = { name = 'V-BLOCK', hl = 'SLModeVisual' },
    ['c']   = { name = 'COMMAND', hl = 'SLModeCommand' },
    ['R']   = { name = 'REPLACE', hl = 'SLModeReplace' },
    ['t']   = { name = 'TERMINAL', hl = 'SLModeTerminal' },
  }

  local current = mode_config[mode] or { name = mode, hl = 'SLModeNormal' }

  -- [Modified] Path logic: CWD_Name / Filename
  local cwd_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t") -- Get tail of CWD (Project folder name)
  local filename = vim.fn.expand("%:t")                      -- Get only filename (no path)

  -- Construct display string: "Project / file.lua"
  -- If filename is empty (e.g. in a terminal or start screen), just show cwd
  local path_display = cwd_name
  if filename ~= "" then
    path_display = cwd_name .. " / " .. filename
  end

  -- Build statusline string
  return table.concat {
    "%#", current.hl, "#",   -- Start custom highlight
    "  ", current.name, " ", -- Mode name
    "%#StatusLine#",         -- Reset highlight
    " ", path_display, " ",  -- [Replaced %f] Display new path format
    "%h%m%r",                -- Help, Modified, Read-only flags
    "%=",                    -- Right align
    "%#LineNr#",             -- Position highlight
    " %l:%c  ",              -- Line and column
  }
end

vim.o.statusline = "%{%v:lua.StatusLine()%}"

-- 4. Statusline background matching
-- Keep the main statusline background clean/transparent
local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
vim.api.nvim_set_hl(0, "StatusLine", { bg = normal_bg, fg = "#888888" })
-- Remove underline if you prefer a flat look
vim.api.nvim_set_hl(0, "StatusLine", { bg = normal_bg, fg = "#888888", underline = false })

-- 4. Custom Tabline
_G.TabLine = function()
  local s = ""
  local current_tab = vim.fn.tabpagenr()
  local total_tabs = vim.fn.tabpagenr('$')

  for i = 1, total_tabs do
    local winnr = vim.fn.tabpagewinnr(i)

    local buflist = vim.fn.tabpagebuflist(i)

    local bufnr = buflist[winnr]

    local file_name = ""
    if bufnr then
      file_name = vim.fn.bufname(bufnr)
      if file_name == "" then
        file_name = "[Empty]"
      else
        file_name = vim.fn.fnamemodify(file_name, ":t")
      end
    else
      file_name = "[No Buf]"
    end

    local hl = ""
    if i == current_tab then
      hl = "%#SLModeNormal#"
    else
      hl = "%#StatusLine#"
    end

    s = s .. hl .. "%" .. i .. "T" .. " " .. i .. ": " .. file_name .. " %T"
  end

  return s .. "%#StatusLine#"
end

vim.o.tabline = "%{%v:lua.TabLine()%}"
-- 5. auto hidden/show Tabline
vim.api.nvim_create_autocmd({ "TabEnter", "TabLeave", "TabNew", "TabClosed" }, {
  callback = function()
    if vim.fn.tabpagenr('$') > 1 then
      vim.o.showtabline = 2
    else
      vim.o.showtabline = 0
    end
  end,
})

if vim.fn.tabpagenr('$') > 1 then vim.o.showtabline = 2 else vim.o.showtabline = 0 end


local float_bg = "#1e1e1e"

-- 1. Float window
vim.api.nvim_set_hl(0, "NormalFloat", {
  bg = float_bg,
  fg = "#f8f8f2",
  blend = 0
})

-- 2. border
vim.api.nvim_set_hl(0, "FloatBorder", {
  bg = float_bg,
  fg = "#66d9ef",
  blend = 0
})
