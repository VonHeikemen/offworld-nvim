-- enable "global" statusline
vim.opt.laststatus = 3

--- highlight pattern
-- This has three parts:
-- 1. the highlight group
-- 2. text content
-- 3. special sequence to restore highlight: %*
-- Example pattern: %#SomeHighlight#some-text%*
local hi_pattern = '%%#%s#%s%%* '
local hi_group = 'Visual'

local ok = string.format(hi_pattern, hi_group, ' λ ')

local diagnostic_count = function(bufnr, severity)
  return #vim.diagnostic.get(bufnr, {severity = severity})
end

if vim.fn.has('nvim-0.10') == 1 then
  diagnostic_count = function(bufnr, severity)
    return #vim.diagnostic.count(bufnr, {severity = severity})
  end
end

local diagnostic_icon = function(bufnr)
  local errors = diagnostic_count(bufnr, 1)
  if errors > 0 then
    return string.format(hi_pattern, hi_group, ' ✘ ')
  end

  local warnings = diagnostic_count(bufnr, 2)
  if warnings > 0 then
    return string.format(hi_pattern, hi_group, ' ▲ ')
  end

  return ok
end

local change_icon = function()
  local bufnr = vim.api.nvim_get_current_buf()

  if vim.b[bufnr].stl_show_icon then
    vim.g.stl_icon = diagnostic_icon(bufnr)
    vim.cmd('redrawstatus')
    return
  end

  if vim.g.stl_icon ~= ' ' then
    vim.g.stl_icon = ' '
    vim.cmd('redrawstatus')
  end
end

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup('statusline_cmds', {clear = true})

vim.api.nvim_create_user_command(
  'StlIcon',
  function(input)
    if input.bang then
      vim.b.stl_show_icon = 1
    end

    change_icon()
  end,
  {bang = true}
)

autocmd({'BufEnter', 'DiagnosticChanged'}, {
  group = augroup,
  callback = change_icon,
})

autocmd('ModeChanged', {
  group = augroup,
  pattern = {'i:n', 'v:n', 'c:n'},
  callback = change_icon,
})

autocmd('ModeChanged', {
  group = augroup,
  pattern = {'n:i', 'v:s', 'n:c'},
  callback = function(event)
    if vim.b[event.buf].stl_show_icon then
      vim.g.stl_icon = ok
      vim.cmd('redrawstatus')
    end
  end,
})

autocmd('LspAttach', {
  group = augroup,
  desc = 'Show diagnostic sign in statusline',
  callback = function(event)
    local id = vim.tbl_get(event, 'data', 'client_id')
    local client = id and vim.lsp.get_client_by_id(id)
    if client == nil then
      return
    end

    if client.supports_method('textDocument/diagnostics') then
      vim.b.stl_show_icon = 1
      change_icon()
    end
  end
})

local statusline = {
  '%{%g:stl_icon%}',
  '%t',
  '%r',
  '%m',
  '%=',
  '%{&filetype} ',
  ' %2p%% ',
  string.format(vim.trim(hi_pattern), hi_group, ' %3l:%-2c '),
}

vim.g.stl_icon = ' '
vim.o.statusline = table.concat(statusline, '')

