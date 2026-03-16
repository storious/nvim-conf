-- lua/core/terminal.lua

local M = {}
local float_buf = nil
local float_win = nil

M.toggle = function()
  if float_win and vim.api.nvim_win_is_valid(float_win) then
    vim.api.nvim_win_close(float_win, true)
    float_win = nil
    return
  end

  if not float_buf or not vim.api.nvim_buf_is_valid(float_buf) then
    float_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[float_buf].bufhidden = "hide"
    vim.bo[float_buf].filetype = "terminal"

    vim.api.nvim_buf_call(float_buf, function()
      vim.fn.jobstart(vim.o.shell, {
        term = true,
        on_exit = function(_, exit_code)
          vim.schedule(function()
            if exit_code == 0 then
              -- if terminal exited, clean the window and buffer
              if float_win and vim.api.nvim_win_is_valid(float_win) then
                vim.api.nvim_win_close(float_win, true)
              end
              float_win = nil
              float_buf = nil
            end
          end)
        end,
      })
    end)
  end

  -- 3. Compute window size
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- 4. Open float window
  float_win = vim.api.nvim_open_win(float_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
  })

  -- 5. Setting window option
  vim.wo[float_win].number = false
  vim.wo[float_win].relativenumber = false
  vim.wo[float_win].signcolumn = "no"

  vim.cmd("startinsert")
end

return M
