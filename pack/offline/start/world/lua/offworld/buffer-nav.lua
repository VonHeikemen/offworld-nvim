local M = {}
local s = {}

local uv = vim.loop or vim.uv
local buf_name = 'buffer-nav.ui-menu'
local parse_cmd = vim.api.nvim_parse_cmd ~= nil

M.window = nil

function M.show_menu()
  if M.window == nil then
    M.window = s.create_window()
  end

  M.window.mount()
end

function M.add_file(opts)
  local name = vim.fn.bufname('%')
  local should_mount = M.window == nil

  if should_mount then
    M.window = s.create_window()
  end

  local get_lines = vim.api.nvim_buf_get_lines
  local start_row = vim.api.nvim_buf_line_count(M.window.bufnr)
  local end_row = start_row

  local is_empty = start_row == 1
    and #vim.trim(get_lines(M.window.bufnr, 0, 1, false)[1]) == 0

  if is_empty then
    start_row = 0
    end_row = 1
  end

  vim.api.nvim_buf_set_lines(
    M.window.bufnr,
    start_row,
    end_row,
    false,
    {vim.fn.fnamemodify(name, ':.')}
  )

  M.window.modified(false)

  if opts.show_menu == false then
    return
  end

  M.window.mount()
end

function M.go_to_file(index)
  if M.window == nil then
    return
  end

  local count = vim.api.nvim_buf_line_count(M.window.bufnr)

  if index > count then
    return
  end

  local path = vim.api.nvim_buf_get_lines(
    M.window.bufnr,
    index - 1,
    index,
    false
  )[1]

  if path == nil then
    return
  end

  if vim.fn.bufloaded(path) == 1 then
    s.cmd('buffer', path)
    return
  end

  if uv.fs_stat(path) then
    s.cmd('edit', path)
  end
end

function M.load_content(path)
  if vim.tbl_get(M, 'window', 'winid') then
    M.window.unmount()
    s.filepath = nil
  end

  local window = s.create_window()
  vim.api.nvim_buf_call(window.bufnr, function()
    s.cmd('read', path)
    vim.api.nvim_buf_set_lines(window.bufnr, 0, 1, false, {})
    s.filepath = path
    window.modified(false)
  end)

  M.window = window
end

function s.create_window()
  local buf_id = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_name(buf_id, buf_name)
  vim.api.nvim_buf_set_option(buf_id, 'filetype', 'BufferNav')
  vim.api.nvim_buf_set_option(buf_id, 'buftype', 'acwrite')
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, {''})
  vim.api.nvim_buf_set_option(buf_id, 'modified', false)

  local close = M.close_window
  local opts = {noremap = true, buffer = buf_id}

  vim.keymap.set('n', '<esc>', close, opts)
  vim.keymap.set('n', 'q', close, opts)
  vim.keymap.set('n', '<C-c>', close, opts)

  vim.keymap.set('n', '<cr>', function()
    local index = vim.fn.line('.')
    close()
    M.go_to_file(index)
  end, opts)

  local autocmd = vim.api.nvim_create_autocmd

  autocmd('BufLeave', {buffer = buf_id, once = true, callback = close})
  autocmd('WinLeave', {buffer = buf_id, callback = close})

  autocmd('VimResized', {buffer = buf_id , callback = close})

  autocmd('BufWriteCmd', {buffer = buf_id, callback = s.write_file})

  local mount = function()
    local cursorline = vim.o.cursorline
    local id = s.open_float(buf_id)

    M.window.winid = id
    vim.api.nvim_buf_call(buf_id, function()
      vim.api.nvim_win_set_option(id, 'number', true)
      vim.api.nvim_win_set_option(id, 'cursorline', cursorline)
    end)
  end

  local unmount = function()
    close()
    if vim.api.nvim_buf_is_valid(buf_id) then
      vim.api.nvim_buf_delete(buf_id, {force = true})
    end
  end

  local modified = function(arg)
    vim.api.nvim_buf_set_option(buf_id, 'modified', arg)
  end

  return {
    bufnr = buf_id,
    mount = mount,
    hide = close,
    unmount = unmount,
    modified = modified,
  }
end

function s.open_float(bufnr)
  local config = {
    anchor = 'NW',
    border = 'rounded',
    focusable = true,
    relative = 'editor',
    style = 'minimal',
    zindex = 50,
  }

  if parse_cmd then
    config.title = '[Buffers]'
    config.title_pos = 'center'
  end

  local width = vim.api.nvim_get_option('columns')
  local height = vim.api.nvim_get_option('lines')

  config.height = math.ceil(height * 0.35)
  config.width = math.ceil(width * 0.5)

  config.row = math.ceil((height - config.height) / 6)
  config.col = math.ceil((width - config.width) / 2)

  return vim.api.nvim_open_win(bufnr, true, config)
end

function s.write_file(ev)
  if M.window then
    M.window.modified(false)
  end

  local same_name = ev.file == buf_name
  if not same_name then
    s.filepath = ev.file
  end

  if s.filepath == nil then
    if same_name then
      local msg = 'Must provide a file path'
      vim.notify(msg, vim.log.levels.WARN)
      return
    end

    s.filepath = ev.file
  end

  if parse_cmd then
    vim.cmd.write({
      args = {s.filepath},
      bang = true,
      mods = {
        noautocmd = true
      }
    })
  else
    local exec = 'noautocmd write! %s'
    vim.cmd(exec:format(vim.fn.fnameescape(s.filepath)))
  end
end

function M.close_window()
  if M.window == nil then
    return
  end

  local id = M.window.winid

  if id == nil or not vim.api.nvim_win_is_valid(id) then
    return
  end

  if vim.api.nvim_buf_get_option(M.window.bufnr, 'modified') then
    M.window.modified(false)
  end

  vim.api.nvim_win_close(id, true)
  M.window.winid = nil
end

function s.read_content(input)
  local path = input.args
  if path == nil then
    return
  end

  s.load_content(path)
end

function s.cmd_new(name, opts)
  vim.cmd({cmd = name, args = {opts}})
end

function s.cmd(name, opts)
  local exec = '%s %s'
  vim.cmd(exec:format(name, vim.fn.fnameescape(opts)))
end

if parse_cmd then
  s.cmd = s.cmd_new
end

return M

