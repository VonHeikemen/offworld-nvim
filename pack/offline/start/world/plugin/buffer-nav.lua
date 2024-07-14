local command = vim.api.nvim_create_user_command
local cmd = {}

function cmd.buffer_nav(input)
  local index = tonumber(input.args)
  if index == nil then
    return
  end

  require('offworld.buffer-nav').go_to_file(index)
end

function cmd.show_menu()
  require('offworld.buffer-nav').show_menu()
end

function cmd.add_file(input)
  require('offworld.buffer-nav').add_file({show_menu = input.bang})
end

function cmd.close_window(input)
  require('offworld.buffer-nav').close_window()
end

function cmd.read_content(input)
  local path = input.args
  if path == nil then
    return
  end

  require('offworld.buffer-nav').load_content(path)
end

command('BufferNav', cmd.buffer_nav, {nargs = 1})
command('BufferNavMenu', cmd.show_menu, {})
command('BufferNavMark', cmd.add_file, {bang = true})
command('BufferNavClose', cmd.close_window, {})
command('BufferNavRead', cmd.read_content, {nargs = 1, complete = 'file'})

