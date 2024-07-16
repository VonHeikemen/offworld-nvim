vim.opt.signcolumn = 'yes'

local offworld = require('offworld.settings')

offworld.lsp_attach = function(_, bufnr)
  -- keymaps defined in lua/user/keymaps.lua
  offworld.lsp_keymaps(bufnr)

  -- enable diagnostic icon in statusline
  vim.b.user_diagnostic_status = 1
end

local lspconfig = {}

lspconfig.lua_ls = {
  cmd = {'lua-language-server'},
  filetypes = {'lua'}
}

-- I like to start LSP servers manually
-- so I create a command
local function lsp_start(input)
  local lsp = require('offworld.lsp-client')
  local name = input.args

  local config = lspconfig[name]
  if config == nil or config.root_dir then
    return
  end

  config.name = name
  config.root_dir = function()
    return vim.fn.getcwd()
  end

  lsp.new_client(config)

  if vim.bo.filetype ~= '' then
    pcall(function() vim.cmd('edit') end)
  end
end

vim.api.nvim_create_user_command('LspStart', lsp_start, {nargs = 1})

