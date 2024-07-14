local M = {}
local s = {}

s.tab_complete = false
s.trigger = false

local pumvisible = vim.fn.pumvisible

local function has_words_before()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local col = cursor[2]

  if col == 0 then
    return false
  end

  local line = cursor[1]
  local str = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]

  return str:sub(col, col):match('%s') == nil
end

function M.tab_complete()
  s.settings()
  s.tab_complete = true

  vim.keymap.set('i', '<Tab>', s.tab_expr, {expr = true})
  vim.keymap.set('i', '<S-Tab>', s.tab_prev_expr, {expr = true})
end

function M.set_trigger(key)
  s.settings()
  s.trigger = key

  vim.keymap.set('i', key, s.toggle_expr, {expr = true})
end

function M.set_omnifunc(bufnr)
  local opts = {expr = true, buffer = bufnr}

  if s.tab_complete then
    vim.keymap.set('i', '<Tab>', s.tab_omnifunc, opts)
  end

  if s.trigger then
    vim.keymap.set('i', s.trigger, s.toggle_omnifunc, opts)
  end
  
  s.backspace()
end

function s.tab_expr()
  if pumvisible() == 1 then
    return '<Down>'
  end

  if has_words_before() then
    return '<C-x><C-n>'
  end

  return '<Tab>'
end

function s.tab_omnifunc()
  if pumvisible() == 1 then
    return '<Down>'
  end

  if has_words_before() then
    return '<C-x><C-o>'
  end

  return '<Tab>'
end

function s.tab_prev_expr()
  if pumvisible() == 1 then
    return '<Up>'
  end

  return '<Tab>'
end

function s.toggle_expr()
  if pumvisible() == 1 then
    return '<C-e>'
  end

  return '<C-x><C-n>'
end

function s.toggle_omnifunc()
  if pumvisible() == 1 then
    return '<C-e>'
  end

  return '<C-x><C-o>'
end

function s.backspace(buffer)
  local rhs = function()
    if pumvisible() == 1 then
      return '<bs><c-x><c-o>'
    end

    return '<bs>'
  end

  vim.keymap.set('i', '<bs>', rhs, {expr = true, buffer = buffer})
end

function s.settings()
  if s.done then
    return
  end

  s.done = true
  vim.opt.completeopt = {'menu', 'menuone', 'noselect', 'noinsert'}
  vim.opt.shortmess:append('c')
end


return M

