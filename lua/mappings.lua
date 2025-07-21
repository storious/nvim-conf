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

-- nvim-dap-python map
map("n", "<leader>dn", function()
  require("dap-python").test_method()
end, { desc = "py test method" })

map("n", "<leader>df", function()
  require("dap-python").test_class()
end, { desc = "py test class" })

map("v", "<leader>ds", '<ESC>lua: require("dap-python").debug_selection()<CR>', { desc = "py debug test selection" })
