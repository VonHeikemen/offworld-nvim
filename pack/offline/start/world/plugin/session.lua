local augroup = vim.api.nvim_create_augroup('offworld_session', {clear = true})
local command = vim.api.nvim_create_user_command
local cmd = {}

function cmd.save()
  require('offworld.session').save_current()
end

function cmd.edit_config()
  require('offworld.session').session_config()
end

function cmd.create(input)
  local path = input.args
  if path == '' and vim.g.user_session_path then
    path = vim.g.user_session_path
  end

  if path == nil or path == '' then
    local msg = 'Must specify the path to a session file'
    vim.notify(msg, vim.log.levels.WARN)
    return
  end

  require('offworld.session').mksession(path)
end

function cmd.load(input)
  local path = input.args
  if path == '' and vim.g.user_session_path then
    path = vim.g.user_session_path
  end

  if path == nil or path == '' then
    local msg = 'Must specify the path to a session file'
    vim.notify(msg, vim.log.levels.WARN)
    return
  end

  require('offworld.session').load(path)
end

command('SessionSave', cmd.save, {})
command('SessionConfig', cmd.edit_config, {})
command('SessionNew', cmd.create, {nargs = '?', complete = 'file'})
command('SessionLoad', cmd.load, {nargs = '?', complete = 'file'})

vim.api.nvim_create_autocmd('VimLeavePre', {
  group = augroup,
  desc = 'Save active session on exit',
  callback = cmd.save
})

