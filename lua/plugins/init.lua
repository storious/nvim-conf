local M = {}
local augroup = vim.api.nvim_create_augroup("PluginConfigs", { clear = true })
local loaded = {}
local configured = {}
local registered = false

local plugin_specs = {
  "https://www.github.com/lewis6991/gitsigns.nvim",
  "https://www.github.com/echasnovski/mini.nvim",
  "https://www.github.com/ibhagwan/fzf-lua",
  "https://www.github.com/nvim-tree/nvim-tree.lua",
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
  },
  "https://www.github.com/neovim/nvim-lspconfig",
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("1.*"),
  },
}

local plugin_names = {
  "gitsigns.nvim",
  "mini.nvim",
  "fzf-lua",
  "nvim-tree.lua",
  "nvim-treesitter",
  "nvim-lspconfig",
  "blink.cmp",
}

local function ensure_registered()
  if registered then return end

  -- A custom no-op loader installs and registers plugins without adding them
  -- to runtimepath. The first feature used pays the package-manager cost.
  vim.pack.add(plugin_specs, { load = function() end })
  registered = true
end

local function packadd(name)
  if loaded[name] then return end
  ensure_registered()
  if name == "gitsigns.nvim" then
    -- Its plugin file calls setup() with defaults. Add only the runtime path
    -- so the custom setup below does not initialize Gitsigns twice.
    vim.cmd.packadd({ args = { name }, bang = true })
  else
    vim.cmd.packadd(name)
  end
  loaded[name] = true
end

local function setup_once(key, plugin, setup)
  if configured[key] then return end
  configured[key] = true

  local ok, result = xpcall(function()
    packadd(plugin)
    return setup()
  end, debug.traceback)

  if not ok then
    configured[key] = nil
    error(result)
  end

  return result
end

vim.api.nvim_create_user_command("PackUpdate", function()
  ensure_registered()
  vim.pack.update(plugin_names)
end, { desc = "Update configured plugins" })

local function setup_icons()
  setup_once("mini.icons", "mini.nvim", function()
    local icons = require("mini.icons")
    icons.setup({})
    icons.mock_nvim_web_devicons()
  end)
end

local function setup_mini_ai()
  setup_once("mini.ai", "mini.nvim", function()
    require("mini.ai").setup({})
  end)
end

local function setup_mini_surround()
  setup_once("mini.surround", "mini.nvim", function()
    require("mini.surround").setup({})
  end)
end

local function setup_mini_extras()
  setup_once("mini.extras", "mini.nvim", function()
    local indentscope = require("mini.indentscope")
    indentscope.setup({
      draw = {
        animation = indentscope.gen_animation.none(),
        delay = 120,
      },
      options = { n_lines = 500 },
    })
    require("mini.trailspace").setup({})
    require("mini.notify").setup({})
  end)
end

local function setup_mini_pairs()
  setup_once("mini.pairs", "mini.nvim", function()
    require("mini.pairs").setup({})
  end)
end

local function setup_gitsigns()
  setup_once("gitsigns", "gitsigns.nvim", function()
    require("gitsigns").setup({
      signs = {
        add = { text = "▏" },
        change = { text = "▐" },
        delete = { text = "▏" },
        topdelete = { text = "◦" },
        changedelete = { text = "●" },
        untracked = { text = "○" },
      },
      signcolumn = true,
      current_line_blame = false,
      auto_attach = false,
      on_attach = function(bufnr)
        return not vim.b[bufnr].large_file
      end,
    })
  end)
end

local function setup_fzf()
  setup_icons()
  setup_once("fzf-lua", "fzf-lua", function()
    require("fzf-lua").setup({})
  end)
  return require("fzf-lua")
end

function M.fzf(action, opts)
  return setup_fzf()[action](opts)
end

function M.toggle_tree()
  setup_icons()
  setup_once("nvim-tree", "nvim-tree.lua", function()
    local function on_attach(bufnr)
      local api = require("nvim-tree.api")
      api.map.on_attach.default(bufnr)
      vim.keymap.set("n", "<leader>e", api.tree.close, {
        buffer = bufnr,
        desc = "Close file tree",
        nowait = true,
        silent = true,
      })
    end

    require("nvim-tree").setup({
      on_attach = on_attach,
      -- Windows can flood watchers with events after deleting expanded folders.
      -- Use native operation/write refreshes and refresh when re-entering the tree.
      filesystem_watchers = { enable = vim.fn.has("win32") ~= 1 },
      reload_on_bufenter = vim.fn.has("win32") == 1,
      view = { width = 35 },
      filters = { dotfiles = false },
      renderer = { group_empty = true },
    })

  end)
  require("nvim-tree.api").tree.toggle()
end

local function gitsigns(action, ...)
  setup_gitsigns()
  return require("gitsigns")[action](...)
end

vim.keymap.set("n", "]h", function() gitsigns("next_hunk") end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function() gitsigns("prev_hunk") end, { desc = "Previous git hunk" })
vim.keymap.set("n", "<leader>hs", function() gitsigns("stage_hunk") end, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", function() gitsigns("reset_hunk") end, { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hp", function() gitsigns("preview_hunk") end, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hb", function() gitsigns("blame_line", { full = true }) end, { desc = "Blame line" })
vim.keymap.set("n", "<leader>hB", function() gitsigns("toggle_current_line_blame") end,
  { desc = "Toggle inline blame" })
vim.keymap.set("n", "<leader>hd", function() gitsigns("diffthis") end, { desc = "Diff this" })

vim.keymap.set("n", "<leader>ff", function() M.fzf("files") end, { desc = "FZF Files" })
vim.keymap.set("n", "<leader>fg", function() M.fzf("live_grep") end, { desc = "FZF Live Grep" })
vim.keymap.set("n", "<leader>fb", function() M.fzf("buffers") end, { desc = "FZF Buffers" })
vim.keymap.set("n", "<leader>fh", function() M.fzf("help_tags") end, { desc = "FZF Help Tags" })
vim.keymap.set("n", "<leader>fx", function() M.fzf("diagnostics_document") end,
  { desc = "FZF Diagnostics Document" })
vim.keymap.set("n", "<leader>fX", function() M.fzf("diagnostics_workspace") end,
  { desc = "FZF Diagnostics Workspace" })

local parser_by_filetype = {
  bash = "bash",
  c = "c",
  cpp = "cpp",
  css = "css",
  go = "go",
  help = "vimdoc",
  html = "html",
  javascript = "javascript",
  javascriptreact = "javascript",
  json = "json",
  jsonc = "json",
  lua = "lua",
  markdown = "markdown",
  python = "python",
  rust = "rust",
  sh = "bash",
  typescript = "typescript",
  vim = "vim",
  zsh = "bash",
}

local parser_installing = {}
local parser_waiting = {}

local function try_start_treesitter(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf)
      or vim.b[buf].large_file
      or parser_by_filetype[vim.bo[buf].filetype] ~= lang
      or vim.treesitter.highlighter.active[buf] then
    return true
  end

  local ok, available = pcall(vim.treesitter.language.add, lang)
  if not ok or not available then return false end

  pcall(vim.treesitter.start, buf, lang)
  return true
end

local function install_parser(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].large_file then return end

  parser_waiting[lang] = parser_waiting[lang] or {}
  parser_waiting[lang][buf] = true
  if parser_installing[lang] then return end

  local ok, task = pcall(function()
    setup_once("treesitter.install", "nvim-treesitter", function()
      require("nvim-treesitter").setup({})
    end)
    return require("nvim-treesitter").install({ lang })
  end)

  if not ok or type(task) ~= "table" or type(task.await) ~= "function" then
    parser_waiting[lang] = nil
    return
  end

  parser_installing[lang] = task
  task:await(function(err, installed)
    local waiting = parser_waiting[lang] or {}
    parser_installing[lang] = nil
    parser_waiting[lang] = nil
    if err or not installed then return end

    vim.schedule(function()
      for waiting_buf in pairs(waiting) do
        try_start_treesitter(waiting_buf, lang)
      end
    end)
  end)
end

local function start_treesitter(buf, lang)
  if try_start_treesitter(buf, lang) then return end
  vim.defer_fn(function() install_parser(buf, lang) end, 200)
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function(args)
    local lang = parser_by_filetype[args.match]
    if not lang then return end

    local buf = args.buf
    local filetype = args.match
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf)
          and not vim.b[buf].large_file
          and vim.bo[buf].filetype == filetype then
        start_treesitter(buf, lang)
      end
    end)
  end,
})

local function setup_completion()
  setup_once("blink.cmp", "blink.cmp", function()
    require("blink.cmp").setup({
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        menu = {
          auto_show = true,
          border = "rounded",
          winhighlight = "Normal:Pmenu,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
        },
        documentation = {
          window = {
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,EndOfBuffer:NormalFloat",
          },
        },
      },
      sources = { default = { "lsp", "path", "buffer", "snippets" } },
      fuzzy = { implementation = "prefer_rust", prebuilt_binaries = { download = true } },
    })
  end)
  return require("blink.cmp")
end

local function lsp_on_attach(ev)
  vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })

  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not client then return end
  local bufnr = ev.buf
  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>fd", function()
    M.fzf("lsp_definitions", { jump_to_single_result = true })
  end, opts)
  vim.keymap.set("n", "<leader>fr", function() M.fzf("lsp_references") end, opts)
  vim.keymap.set("n", "<leader>ft", function() M.fzf("lsp_typedefs") end, opts)
  vim.keymap.set("n", "<leader>fs", function() M.fzf("lsp_document_symbols") end, opts)
  vim.keymap.set("n", "<leader>fw", function() M.fzf("lsp_workspace_symbols") end, opts)
  vim.keymap.set("n", "<leader>fi", function() M.fzf("lsp_implementations") end, opts)

  if client:supports_method("textDocument/codeAction", bufnr) then
    vim.keymap.set("n", "<leader>oi", function()
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" }, diagnostics = {} },
        apply = true,
        bufnr = bufnr,
      })
      vim.defer_fn(function() require("core.lsp").format(bufnr) end, 50)
    end, opts)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = lsp_on_attach,
})

local function setup_lsp()
  setup_once("lsp", "nvim-lspconfig", function()
    local blink = setup_completion()
    local diagnostic_signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }

    vim.diagnostic.config({
      virtual_text = { prefix = "●", spacing = 4 },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
          [vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
          [vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
          [vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
        focusable = false,
        style = "minimal",
      },
    })

    vim.lsp.config["*"] = { capabilities = blink.get_lsp_capabilities() }
    vim.lsp.config("lua_ls", {
      settings = { Lua = { diagnostics = { globals = { "vim" } }, telemetry = { enable = false } } },
    })
  end)
end

local lsp_by_filetype = {
  lua = { name = "lua_ls", executable = "lua-language-server" },
  c = { name = "clangd", executable = "clangd" },
  cpp = { name = "clangd", executable = "clangd" },
  objc = { name = "clangd", executable = "clangd" },
  objcpp = { name = "clangd", executable = "clangd" },
  cuda = { name = "clangd", executable = "clangd" },
}

local function start_lsp(buf, filetype)
  local server = lsp_by_filetype[filetype]
  if vim.b[buf].large_file
      or not server
      or vim.fn.executable(server.executable) ~= 1 then
    return
  end

  setup_lsp()
  local config = vim.lsp.config[server.name]
  if not config then return end

  local function launch(root_dir)
    if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].large_file then return end

    local resolved = vim.deepcopy(config)
    resolved.root_dir = root_dir
    vim.lsp.start(resolved, {
      bufnr = buf,
      reuse_client = config.reuse_client,
    })
  end

  if type(config.root_dir) == "function" then
    config.root_dir(buf, launch)
  else
    local root_dir = config.root_dir
    if not root_dir and config.root_markers then
      root_dir = vim.fs.root(buf, config.root_markers)
    end
    launch(root_dir)
  end
end

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "lua", "c", "cpp", "objc", "objcpp", "cuda" },
  callback = function(args)
    local buf = args.buf
    local filetype = args.match

    local function start()
      if not vim.api.nvim_buf_is_valid(buf)
          or vim.b[buf].large_file
          or vim.bo[buf].filetype ~= filetype then
        return
      end
      start_lsp(buf, filetype)
    end

    if vim.v.vim_did_enter == 1 then
      vim.schedule(start)
    else
      vim.api.nvim_create_autocmd("VimEnter", {
        group = augroup,
        once = true,
        callback = function()
          vim.schedule(start)
        end,
      })
    end
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup,
  callback = function(args)
    if vim.b[args.buf].large_file then return end
    setup_completion()
    pcall(vim.api.nvim_del_autocmd, args.id)
  end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufFilePost", "BufWritePost" }, {
  group = augroup,
  callback = function(args)
    if vim.b[args.buf].large_file then return end

    local buf = args.buf
    local event = args.event
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(buf) and not vim.b[buf].large_file then
        setup_gitsigns()
        require("gitsigns").attach(buf, nil, event)
      end
    end, 80)
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  once = true,
  callback = function()
    vim.schedule(setup_mini_ai)
    vim.defer_fn(setup_mini_surround, 40)
    vim.defer_fn(setup_mini_extras, 120)
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup,
  callback = function(args)
    if vim.b[args.buf].large_file then return end
    setup_mini_pairs()
    pcall(vim.api.nvim_del_autocmd, args.id)
  end,
})

return M
