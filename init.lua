-- Cache Lua modules between sessions and keep optional plugins out of startup.
vim.loader.enable()
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
local remote_manifest = vim.env.NVIM_RPLUGIN_MANIFEST or (vim.fn.stdpath("data") .. "/rplugin.vim")
if not vim.uv.fs_stat(remote_manifest) then
  vim.g.loaded_remote_plugins = 1
end
vim.g.loaded_matchit = 1 -- load extended % matching only when it is first used
vim.g.matchparen_timeout = 50
vim.g.matchparen_insert_timeout = 20

-- set <leader> as space
vim.g.mapleader = ' '
vim.cmd('colorscheme unokai')
require "core.ui"

-- load core module
require "core.options"
require "core.keymaps"
require "core.autocmds"


-- load plugins module
require "plugins"
