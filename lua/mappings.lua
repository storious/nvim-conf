require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")--

-- nvim-dap debug map
map("n", "<leader>td", function()
  require("dap-go").debug_test()
end, { desc = "debug test go test function" })
