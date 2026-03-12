local M = {}

local pair_map = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ['"'] = '"',
  ["'"] = "'",
}

-- get char after cursor
local function next_char()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  return line:sub(col + 1, col + 1)
end

-- treesitter check
local function in_ts_node(types)
  local ok, _ = pcall(vim.treesitter.get_parser, 0)
  if not ok then
    return false
  end

  local node = vim.treesitter.get_node()
  while node do
    if vim.tbl_contains(types, node:type()) then
      return true
    end
    node = node:parent()
  end

  return false
end

-- section
local function wrap_selection(open, close)
  local mode = vim.fn.mode()

  if mode ~= "v" and mode ~= "V" then
    return nil
  end

  local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)

  return esc .. "`<i" .. open .. esc .. "`>a" .. close
end

function M.setup()
  for open, close in pairs(pair_map) do
    -- open
    vim.keymap.set({ "i", "v" }, open, function()
      local wrapped = wrap_selection(open, close)
      if wrapped then
        return wrapped
      end

      -- no comment
      if in_ts_node({ "comment" }) then
        return open
      end

      local after = next_char()

      -- quotes process
      if open == close then
        if in_ts_node({ "string" }) then
          return open
        end

        if after:match("[%w]") then
          return open
        end
      end

      return open .. close .. "<Left>"
    end, { expr = true })

    -- close
    vim.keymap.set("i", close, function()
      if next_char() == close then
        return "<Right>"
      end

      return close
    end, { expr = true })
  end
end

return M
