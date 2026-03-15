-- set <leader> as space
vim.g.mapleader = ' '
vim.cmd('colorscheme unokai')

-- file tree
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.netrw_browse_split = 3
vim.g.netrw_altv = 1


-- load core module
require "core.options"
require "core.keymaps"
require "core.autocmds"
require "core.ui"


-- load plugins module
require "plugins"
