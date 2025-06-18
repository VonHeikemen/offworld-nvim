local M = {}
local s = {}
local uv = vim.loop or vim.uv
local sep = uv.os_uname().version:match('Windows') and '\\' or '/'

local config = {
  root_dir = table.concat({vim.fn.stdpath('data'), 'site', 'pack'}, sep),
  log = table.concat({vim.fn.stdpath('data'), 'git-plugin.log'}, sep),
  package = 'gitplugins',
  url_pattern = 'https://github.com/%s.git',
  events = {
    install_done = 'PluginInstallDone',
    update_done = 'PluginUpdateDone',
  },
}


---
-- API
---

function M.settings(opts)
  if opts == nil then
    return config
  end

  if type(opts) ~= 'table' then
    return
  end

  config = vim.tbl_deep_extend('force', config, opts)
end

function M.install(opts)
  opts = opts or {}
  local repo = opts[1]

  if repo == nil then
    s.info('Must provide a git repository')
    return
  end

  local pkg = {
    repo,
    name = repo,
    url = s.pkg_url(repo),
    dir = s.pkg_dir(repo, opts),
    rev = {}
  }

  if vim.fn.isdirectory(pkg.dir) == 1 then
    s.warn("A plugin already exists in this path:\n%s", pkg.dir)
    return
  end

  if type(opts.branch) == 'string' then
    pkg.rev.kind = 'branch'
    pkg.rev.value = opts.branch
  end

  local cb = function()
    if type(opts.build) == 'function' then
      opts.build()
    end

    local msg = '"%s" was installed successfully'
    s.info(msg:format(repo))
  end

  s.git_clone(pkg, s.pkg_install_done(pkg, cb))
end

function M.update(opts)
  opts = opts or {}
  local repo = opts[1]

  if repo == nil then
    s.warn('Must provide a git repository')
    return
  end

  local pkg = {
    repo,
    name = repo,
    url = s.pkg_url(repo),
    rev = {}
  }

  if type(opts.dirname) == 'string' then
    local path, is_opt = s.pkg_find_dir(opts.dirname)
    if path == '' then
      s.warn('Could not find directory "%s"', opts.dirname)
      return
    end

    pkg.dir = path
    pkg.opt = is_opt
  else
    pkg.dir = s.pkg_dir(repo, opts)
  end

  local cb = function()
    if type(opts.build) == 'function' then
      opts.build()
    end

    local msg = '"%s" was updated successfully'
    s.info(msg:format(repo))
  end

  s.git_pull(pkg, s.pkg_update_done(pkg, cb))
end

function M.remove(opts)
  local dirname = opts[1]
  if dirname == nil then
    s.warn("Must provide the plugin's directory name")
    return
  end

  local path = s.pkg_find_dir(dirname)

  if path == '' then
    s.warn('Could not find directory "%s"', dirname)
    return
  end

  if vim.fn.delete(path, 'rf') ~= 0 then
    s.warn('Failed to delete:\n%s', path)
    return
  else
    local msg = '"%s" was removed successfully'
    s.info(msg)
  end
end

function M.open_dir(opts)
  local dirname = opts[1]
  if dirname == nil then
    s.warn("Must provide the plugin's directory name")
    return
  end

  local sh = vim.env.SHELL
  if sh == nil then
    s.warn("The environment variable SHELL is empty")
    return
  end

  local path = s.pkg_find_dir(dirname)
  if path == '' then
    s.warn('Could not find path to %s', dirname)
    return
  end

  vim.cmd('vertical new')
  vim.fn.termopen(sh, {cwd = path})
  vim.cmd('startinsert')
end


---
-- Package helpers
---

function s.pkg_url(repo)
  return config.url_pattern:format(repo)
end

function s.pkg_dir(repo, opts)
  opts = opts or {}
  local name

  if type(opts.dirname) == 'string' then
    name = opts.dirname
  else
    local parts = vim.split(repo, '/')
    name = parts[2]
  end

  local pkg_name = opts.package or config.package
  local path = {config.root_dir, pkg_name, 'start', name}

  if opts.opt == true then
    path[3] = 'opt'
  end

  return table.concat(path, sep)
end

function s.pkg_find_dir(name)
  local path = {config.root_dir, config.package, 'start', name}
  local start = table.concat(path, sep)

  if vim.fn.isdirectory(start) == 1 then
    return start, false
  end

  path[3] = 'opt'
  local opt = table.concat(path, sep)
  if vim.fn.isdirectory(opt) == 1 then
    return opt, true
  end

  return '', false
end

function s.pkg_install_done(pkg, callback)
  return function(ok)
    if not ok then
      s.warn('git clone failed for plugin "%s"', pkg.name)
      return
    end

    vim.cmd('packloadall! | silent! helptags ALL')

    if config.events.install_done then
      local emit = config.events.install_done
      vim.api.nvim_exec_autocmds('User', {pattern = emit})
    end

    if callback then
      pcall(callback)
    end
  end
end

function s.pkg_update_done(pkg, callback)
  return function(ok)
    if not ok then
      s.warn('git pull failed for plugin "%s"', pkg.name)
      return
    end

    vim.cmd('packloadall! | silent! helptags ALL')

    if config.events.install_done then
      local emit = config.events.update_done
      vim.api.nvim_exec_autocmds('User', {pattern = emit})
    end

    if callback then
      pcall(callback)
    end
  end
end


---
-- Git operations
---

function s.git_clone(pkg, callback)
  local git_args = {
    'clone',
    pkg.url,
    '--recurse-submodules',
    '--shallow-submodules'
  }

  local kind = pkg.rev.kind

  if kind == 'branch' then
    vim.list_extend(git_args, {'--depth=1', '-b', pkg.rev.value})
  end

  vim.list_extend(git_args, {pkg.dir})

  local msg = 'Installing "%s"'
  s.info(msg:format(pkg[1]))

  s.spawn({cmd = 'git', args = git_args, callback = callback})
end


function s.git_pull(pkg, callback)
  local git_args = {'pull', '--recurse-submodules', '--update-shallow', pkg.dir}

  local msg = 'Updating "%s"'
  s.info(msg:format(pkg[1]))
  s.spawn({cmd = 'git', args = git_args, cwd = pkg.dir, callback = callback})
end


---
-- Messages
---

function s.warn(msg, ...)
  local res = '[git-plugin] %s'
  local text = msg:format(...)
  vim.notify(res:format(text), vim.log.levels.WARN)
end

function s.info(msg)
  local res = '[git-plugin] %s'
  vim.notify(res:format(msg))
end


---
-- External process functions
---

function s.spawn(opts)
  local log = uv.fs_open(config.log, 'a+', 0x1A4)
  local stderr = uv.new_pipe(false)
  stderr:open(log)

  local handle, pid
  local stdio = {nil, opts.stdout and stderr, stderr}
  local env = s.make_env()

  local callback = opts.callback
  local on_exit = function(code)
    uv.fs_close(log)
    stderr:close()
    handle:close()
    if callback then
      callback(code == 0)
    end
  end

  handle, pid = uv.spawn(
    opts.cmd,
    {
      args = opts.args,
      cwd = opts.cwd,
      stdio = stdio,
      env = env
    },
    vim.schedule_wrap(on_exit)
  )

  if not handle then
    s.warn('Failed to spawn %s (%s)', opts.cmd, pid)
  end
end

function s.make_env()
  if s.process_env then
    return s.process_env
  end

  local str = '%s=%s'
  s.process_env = {}
  for name, val in pairs(uv.os_environ()) do
    table.insert(s.process_env, str:format(name, val))
  end

  table.insert(s.process_env, 'GIT_TERMINAL_PROMPT=0')
end

return M

