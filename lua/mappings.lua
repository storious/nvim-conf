require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")--
-- NOTE: nvim-dap mappings
map("n", "<leader>dr", function()
  require("dap").repl.open()
end, { desc = "Debug open dap reply window" })

map("n", "<leader>sb", function()
  require("dap").set_breakpoint()
end, { desc = "Debug set breakpoint" })

map("n", "<leader>tb", function()
  require("dap").toggle_breakpoint()
end, { desc = "Debug toggle breakpoint" })

map("n", "<leader>dl", function()
  require("dap").run_last()
end, { desc = "Test run last test" })

-- NOTE: nvim-dap-go debug mappings
map("n", "<leader>dt", function()
  require("dap-go").debug_test()
end, { desc = "Debug golang test function" })

-- NOTE: nvim-dap-python mappings
map("n", "<leader>pm", function()
  require("dap-python").test_method()
end, { desc = "Test python method" })

map("n", "<leader>pc", function()
  require("dap-python").test_class()
end, { desc = "Test python class" })

map(
  "v",
  "<leader>ps",
  '<ESC>lua: require("dap-python").debug_selection()<CR>',
  { desc = "Debug python test selection" }
)
