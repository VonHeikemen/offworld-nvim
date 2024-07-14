vim.opt.signcolumn = 'yes'

local function lsp_attach(_, bufnr)
  local opts = {buffer = bufnr}

  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
  vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
  vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>LspFormat!<cr>', opts)
  vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

  -- enable lsp code completion
  require('offworld.completion').set_omnifunc(bufnr)

  -- enable diagnostic icon in statusline
	vim.b.user_diagnostic_status = 1
end

local lspconfig = {}

lspconfig.lua_ls = {
	name = 'lua_ls',
	cmd = {'lua-language-server'},
	filetypes = {'lua'}
}

-- I like to start LSP servers manually
-- so I create a command
local function lsp_start(input)
	local name = input.args
	local config = lspconfig[name]
	if config == nil or config.root_dir then
		return
	end

	local lsp = require('offworld.lsp-client')

	config.on_attach = lsp_attach
	config.root_dir = function()
		return vim.fn.getcwd()
	end

	lsp.new_client(config)
	config.started = true

	if vim.bo.filetype ~= '' then
		vim.cmd('edit')
	end
end

vim.api.nvim_create_user_command('LspStart', lsp_start, {nargs = 1})

