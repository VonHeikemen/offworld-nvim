local border_style = 'rounded'
local levels = vim.diagnostic.severity

local opts = {
  virtual_text = false,
  float = {
    border = border_style,
  },
  signs = {
    text = {
      [levels.ERROR] = '✘',
      [levels.WARN] = '▲',
      [levels.HINT] = '⚑',
      [levels.INFO] = '»',
    },
  },
}

local function sign_define(name, text)
  local hl = 'DiagnosticSign' .. name
  vim.fn.sign_define(hl, {
    texthl = hl,
    text = text,
    numhl = ''
  })
end

if vim.fn.has('nvim-0.10') == 0 then
  sign_define('Error', opts.signs.text[levels.ERROR])
  sign_define('Warn', opts.signs.text[levels.WARN])
  sign_define('Hint', opts.signs.text[levels.HINT])
  sign_define('Info', opts.signs.text[levels.INFO])
end

vim.schedule(function()
  vim.diagnostic.config(opts)

  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover,
    {border = border_style}
  )
  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {border = border_style}
  )
end)

