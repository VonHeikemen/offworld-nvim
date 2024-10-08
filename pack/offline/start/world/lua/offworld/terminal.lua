local M = {}
local s = {}

M.state = {
  buffer = nil,
  opened = false,
}

local defaults = {
  direction = 'bottom',
  size = 0.25,
}

function M.toggle(opts)
  opts = opts or {}
  if M.state.buffer == nil then
    s.create_terminal(opts)
  elseif M.state.opened then
    M.hide_terminal()
  else
    M.show_terminal(opts)
  end
end

function s.create_terminal(opts)
  opts = opts or {}
  local direction = opts.direction or defaults.direction
  local size = opts.size or defaults.size

  s.make_split({direction = direction, size = size})
  vim.cmd('terminal')
end

function M.show_terminal(opts)
  opts = opts or {}
  local direction = opts.direction or defaults.direction
  local size = opts.size or defaults.size

  if type(M.state.buffer) ~= 'number' then
    s.create_terminal(opts)
    return
  end

  s.make_split({direction = direction, size = size})
  vim.api.nvim_win_set_buf(0, M.state.buffer)
  M.state.opened = true
end

function M.hide_terminal()
  local win_term = vim.fn.bufwinid(M.state.buffer)
  if win_term == -1 then
    return
  end

  pcall(vim.api.nvim_win_close, win_term, 0)
  M.state.opened = false
end

function s.make_split(opts)
  opts = opts or {}
  local size = opts.size or 0.25

  local exec = {
    range = {},
    cmd = 'split',
    mods = {
      silent = true,
      keepalt = true,
      vertical = false,
    }
  }

  if opts.direction == 'bottom' then
    exec.mods.vertical = false
    exec.mods.split = 'botright'
  elseif opts.direction == 'right' then
    exec.mods.vertical = true
    exec.mods.split = 'botright'
  elseif opts.direction == 'top' then
    exec.mods.vertical = false
    exec.mods.split = 'topleft'
  elseif opts.direction == 'left' then
    exec.mods.vertical = true
    exec.mods.split = 'topleft'
  end

  if exec.mods.vertical then
    exec.range[1] = vim.fn.float2nr(size * math.floor(vim.o.columns - 2))
  else
    exec.range[1] = vim.fn.float2nr(size * math.floor(vim.o.lines - 2))
  end

  s.split_cmd(exec)
end

function s.split_cmd(args)
  local str = 'silent keepalt %s %s%s%s'

  vim.cmd(str:format(
    args.mods.split,
    args.range[1] or '',
    args.mods.vertical and 'v' or '',
    'split'
  ))
end

return M

