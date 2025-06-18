-- Note: lsp will be disabled by default.
-- `vim.g.lsp` must be defined before executing this.
-- See lua/user/lsp.lua

local root_markers = {'.luarc.json', '.luarc.jsonc'}
local lsp_enable = vim.g.lsp.lua_ls == true
local root_dir = nil

if lsp_enable then
  root_dir = _G.lsp_workspace(0, root_markers)
end

if lsp_enable and root_dir then
  vim.lsp.start({
    cmd = {'lua-language-server'},
    root_dir = root_dir,
  })
end

