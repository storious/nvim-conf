-- set <leader> as space
vim.g.mapleader = ' '
vim.cmd('colorscheme unokai')

-- load core module
require "core.options"
require "core.keymaps"
require "core.autocmds"


-- load plugins module
require "plugins"
