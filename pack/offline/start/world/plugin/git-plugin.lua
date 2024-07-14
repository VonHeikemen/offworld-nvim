local function warn(msg, ...)
  local text = '[git-plugin] %s'
  local res = msg:format(...)
  vim.notify(text:format(res), vim.log.levels.WARN)
end

local function parse_opts(pkg, arg)
  local str = arg or ''
  if str == '' then
    return
  elseif vim.startswith(str, 'branch=') then
    pkg.branch = str:sub(8)
  elseif vim.startswith(str, 'package=') then
    pkg.package = str:sub(9)
  elseif vim.startswith(str, 'opt=') then
    local bool = {['true'] = true, ['1'] = true}
    pkg.opt = bool[str:sub(5)] or false
  end
end

local function cmd(input)
  local args = input.fargs

  local allowed_cmd = {'install', 'update', 'remove', 'open_dir'}
  if not vim.tbl_contains(allowed_cmd, args[1]) then
    warn('Invalid command "%s".', args[1])
    return
  end

  local fn = args[1]
  local pkg = {args[2]}

  for i = 3, #args, 1 do
    parse_opts(pkg, args[i])
  end

  require('user.git-plugin')[fn](pkg)
end

vim.api.nvim_create_user_command('GitPlugin', cmd, {nargs = '+', bang = true})

