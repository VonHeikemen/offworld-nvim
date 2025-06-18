local M = {}

function M.save_current()
  local file = vim.v.this_session
  if file == '' then
    return
  end

  M.mksession(file, true)
end

function M.session_config()
  local file = vim.v.this_session
  if file == '' then
    return
  end

  local path = vim.fn.fnamemodify(file, ':r')
  file = vim.fn.fnameescape(path .. 'x.vim')

  vim.cmd({cmd = 'edit', args = {file}})
end

function M.mksession(path, bang)
  local file = vim.fn.fnameescape(path)
  vim.cmd({cmd = 'mksession', bang = bang, args = {file}})
end

function M.load(path)
  local file = vim.v.this_session
  if #file > 0 then
    -- save current session
    M.mksession(file, true)
  end

  file = vim.fn.fnameescape(path)
  vim.cmd({cmd = 'source', args = {file}})
end

return M

