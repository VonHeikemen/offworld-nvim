if vim.fn.exists('##LspAttach') == 1 then
  local lsp_attach = function(event)
    local id = vim.tbl_get(event, 'data', 'client_id')
    local client = id and vim.lsp.get_client_by_id(id)

    if client == nil then
      client = {id = -1}
    end

    require('offworld.lsp-client').attached(client, event.buf)
  end

  vim.api.nvim_create_autocmd('LspAttach', {callback = lsp_attach})
end

local settings = require('offworld.settings')
local ui = settings.ui or {}

local diagnostic = {}
local border_style = ui.float_border

if border_style then
  vim.schedule(function()
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
      vim.lsp.handlers.hover,
      {border = border_style}
    )
    vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
      vim.lsp.handlers.signature_help,
      {border = border_style}
    )
  end)

  diagnostic.float = {border = border_style}
end

if type(ui.virtual_text) ~= 'nil' then
  diagnostic.virtual_text = ui.virtual_text
end

if vim.tbl_isempty(diagnostic) == false then
  vim.schedule(function() vim.diagnostic.config(diagnostic) end)
end

if type(ui.sign_text) == 'table' then
  local icons = ui.sign_text
  local sign = function(args)
    if icons[args.name] == nil then
      return
    end

    vim.fn.sign_define(args.hl, {
      texthl = args.hl,
      text = icons[args.name],
      numhl = ''
    })
  end

  sign({name = 'error', hl = 'DiagnosticSignError'})
  sign({name = 'warn', hl = 'DiagnosticSignWarn'})
  sign({name = 'hint', hl = 'DiagnosticSignHint'})
  sign({name = 'info', hl = 'DiagnosticSignInfo'})
end

local function lsp_setup(input)
  local lspconfig = require('offworld.settings').lspconfig or {}
  local lsp = require('offworld.lsp-client')

	local name = input.args
  local get_config = lspconfig[name]

	if get_config == nil then
		return
	end

  local config = get_config()
  config.name = name

  if input.bang then
    config.root_dir = function()
      return vim.fn.getcwd()
    end
  end

	lsp.new_client(config)

	if vim.bo.filetype ~= '' then
		pcall(function() vim.cmd('edit') end)
	end
end

vim.api.nvim_create_user_command(
  'LspSetup',
  lsp_setup,
  {nargs = 1, bang = true}
)

