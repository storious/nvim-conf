-- lua/plugins/servers.lua
return {
  {
    name = "lua_ls",
    filetypes = { "lua" },
    cmd = { "lua-language-server" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".git", ".nvim.lua" },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME },
        },
        telemetry = { enable = false },
      },
    },
  },

  {
    name = "clangd",
    filetypes = { "c", "cpp", "cc", "cxx", "ccm", "cppm", "h", "hh", "hpp" },
    cmd = { "clangd" },
    root_markers = { ".clangd", "compile_commands.json", ".git" },
  },
}
