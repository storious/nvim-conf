local M = {}

local pair_map = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ['"'] = '"',
  ["'"] = "'",
  ["`"] = "`",
}

-- get char after cursor
local function next_char()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  -- col 是 0-indexed，sub 是 1-indexed
  -- col + 1 是光标所在字符，col + 2 是光标后一个字符
  return line:sub(col + 2, col + 2)
end

-- treesitter check
local function in_ts_node(types)
  local ok, _ = pcall(vim.treesitter.get_parser, 0)
  if not ok then return false end

  local node = vim.treesitter.get_node()
  while node do
    if vim.tbl_contains(types, node:type()) then
      return true
    end
    node = node:parent()
  end
  return false
end

-- Visual Mode Wrap Logic
local function wrap_selection(o, c)
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" then
    return nil
  end

  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
  return esc .. "`>a" .. c .. esc .. "`<i" .. o
end

function M.setup()
  for open, close in pairs(pair_map) do
    local o = open
    local c = close

    -- open
    vim.keymap.set({ "i", "v" }, o, function()
      if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
        local wrapped = wrap_selection(o, c)
        if wrapped then return wrapped end
      end

      -- Insert Mode

      -- 1. direct output in comment
      if in_ts_node({ "comment" }) then
        return o
      end

      local after = next_char()

      -- 2. quote (o == c)
      if o == c then
        -- A. inside a string
        if in_ts_node({ "string", "string_literal" }) then
          -- if trail quote, skip string
          if after == o then return "<Right>" end
          return o
        end

        -- B. not in string and trail non-nil char
        if after:match("[%w]") then
          return o
        end

        -- C. not in string
        return o .. c .. "<Left>"
      end

      if after == c then
        return "<Right>"
      end

      return o .. c .. "<Left>"
    end, { expr = true })
  end
end

return M
