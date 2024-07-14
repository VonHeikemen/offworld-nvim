local concat  = '%s%s'
local separator_active = ''

local function tabpage(opts)
  local highlight = '%#TabLine#'
  local separator = '%#TabLine#▏'
  local label = '[No Name]'

  if opts.selected then
    highlight = '%#TabLineSel#'
    separator = string.format('%%#%s#▍', 'Function')
  end

  if opts.bufname ~= '' then
    label = vim.fn.pathshorten(vim.fn.fnamemodify(opts.bufname, ':p:~:t'))
  end

  return string.format('%s%s%s ', separator, highlight, label)
end

function _G._user_tabline()
  local line = ''
  local fn = vim.fn
  local tabs = fn.tabpagenr('$')

  for index = 1, tabs, 1 do
    local buflist = fn.tabpagebuflist(index)
    local winnr = fn.tabpagewinnr(index)
    local bufname = fn.bufname(buflist[winnr])

    line = concat:format(
      line,
      tabpage({
        selected = fn.tabpagenr() == index,
        bufname = bufname,
      })
    )
  end

  line = concat:format(line, '%#TabLineFill#%=')

  if tabs > 1 then
    line = concat:format(line, '%#TabLine#%999XX')
  end

  return line
end

vim.o.tabline = '%!v:lua._user_tabline()'

