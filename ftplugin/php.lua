-- Note: lsp will be disabled by default.
-- `vim.g.lsp` must be defined before executing this.
-- See lua/user/lsp.lua

local root_markers = {'composer.json'}
local lsp_enable = vim.g.lsp.intelephense == true
local root_dir = nil

if lsp_enable then
  root_dir = _G.lsp_workspace(0, root_markers)
end

if lsp_enable and root_dir then
  vim.lsp.start({
    cmd = {'intelephense', '--stdio'},
    root_dir = root_dir,
  })
end

