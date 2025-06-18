local M = {}
local s = {}

s.tab_complete = false
s.trigger = false

local pumvisible = vim.fn.pumvisible

local function is_whitespace()
  local col = vim.fn.col('.') - 1
  if col == 0 then
    return true
  end

  local char = vim.fn.getline('.'):sub(col, col)
  return type(char:match('%s')) == 'string'
end

function M.tab_complete()
  s.tab_complete = true

  vim.keymap.set('i', '<Tab>', s.tab_expr, {expr = true})
  vim.keymap.set('i', '<S-Tab>', s.tab_prev_expr, {expr = true})
end

function M.set_trigger(key)
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

  if is_whitespace() then
    return '<Tab>'
  end

  return '<C-x><C-n>'
end

function s.tab_omnifunc()
  if pumvisible() == 1 then
    return '<Down>'
  end

  if is_whitespace() then
    return '<Tab>'
  end

  return '<C-x><C-o>'
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

return M

