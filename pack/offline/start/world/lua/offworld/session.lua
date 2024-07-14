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
  local exec = 'edit %s'

  vim.cmd(exec:format(file))
end

function M.mksession(path, bang)
  local exec = 'mksession%s %s'
  local file = vim.fn.fnameescape(path)
  vim.cmd(exec:format(bang and '!' or '', file))
end

function M.load(path)
  local file = vim.v.this_session
  if #file > 0 then
    -- save current session
    M.mksession(file, true)
  end

  file = vim.fn.fnameescape(path)
  local exec = 'source %s'
  vim.cmd(exec:format(file))
end

return M

