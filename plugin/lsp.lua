vim.opt.signcolumn = 'yes'

local offworld = require('offworld.settings')

offworld.ui = {
  virtual_text = false,
  float_border = 'rounded',
  sign_text = {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»',
  }
}

offworld.lsp_attach = function(_, bufnr)
  -- keymaps defined in lua/user/keymaps.lua
  offworld.lsp_keymaps(bufnr)

  -- enable diagnostic icon in statusline
  vim.b.user_diagnostic_status = 1
end

offworld.lspconfig.lua_ls = function()
  local dir = require('offworld.dir')

  return {
    cmd = {'lua-language-server'},
    filetypes = {'lua'},
    root_dir = function(bufnr)
      return dir.find_first(bufnr, {'.luarc.json'})
    end,
  }
end

