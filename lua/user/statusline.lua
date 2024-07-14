-- enable "global" statusline
vim.opt.laststatus = 3

local cmp = {} -- statusline components

--- highlight pattern
-- This has three parts: 
-- 1. the highlight group
-- 2. text content
-- 3. special sequence to restore highlight: %*
-- Example pattern: %#SomeHighlight#some-text%*
local hi_pattern = '%%#%s#%s%%* '
local hi_group = 'Visual'

function _G._statusline_component(name)
  return cmp[name]()
end

local diagnostic_count = function(bufnr, severity)
	return #vim.diagnostic.get(bufnr, {severity = severity})
end

if vim.fn.has('nvim-0.10') == 1 then
	diagnostic_count = function(bufnr, severity)
		return #vim.diagnostic.count(bufnr, {severity = severity})
	end
end

function cmp.diagnostic_status()
	local bufnr = vim.api.nvim_get_current_buf()

	if vim.b[bufnr].user_diagnostic_status == nil then
		return ' '
	end

  local ok = ' λ '
  local ignore = {
    ['c'] = true, -- command mode
    ['t'] = true,  -- terminal mode
    ['i'] = true  -- insert mode
  }

  local mode = vim.api.nvim_get_mode().mode

  if ignore[mode] then
    return string.format(hi_pattern, hi_group, ok)
  end

  local levels = vim.diagnostic.severity

  local errors = diagnostic_count(bufnr, levels.ERROR)
  if errors > 0 then
    return string.format(hi_pattern, hi_group, ' ✘ ')
  end

  local warnings = diagnostic_count(bufnr, levels.WARN)
  if warnings > 0 then
    return string.format(hi_pattern, hi_group, ' ▲ ')
  end

  return string.format(hi_pattern, hi_group, ok)
end

local statusline = {
  '%{%v:lua._statusline_component("diagnostic_status")%}',
  '%t',
  '%r',
  '%m',
  '%=',
  '%{&filetype} ',
  ' %2p%% ',
  '%#Visual# %3l:%-2c %*',
}

vim.o.statusline = table.concat(statusline, '')

