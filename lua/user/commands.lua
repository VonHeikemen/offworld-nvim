-- Augroup for user created autocommands
vim.api.nvim_create_augroup('user_cmds', {clear = true})

vim.api.nvim_create_user_command(
  'TrailspaceTrim',
  function()
    -- Save cursor position to later restore
    local curpos = vim.api.nvim_win_get_cursor(0)

    -- Search and replace trailing whitespace
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, curpos)
  end,
  {desc = 'Delete extra whitespace'}
)

vim.api.nvim_create_user_command(
  'SyntaxQuery',
  function()
    local f = vim.fn
    local stack = f.synstack(f.line('.'), f.col('.'))

    if stack[1] == nil then
      print('No id found')
      return
    end

    for _, id in pairs(stack) do
      print(f.synIDattr(id, 'name'))
    end
  end,
  {desc = 'Show highlight group'}
)

vim.api.nvim_create_autocmd('TextYankPost', {
  group = 'user_cmds',
  desc = 'Highlight text after is copied',
  callback = function()
    vim.highlight.on_yank({higroup = 'Visual', timeout = 80})
  end
})

vim.api.nvim_create_autocmd('FileType', {
  group = 'user_cmds',
  pattern = {'qf', 'help', 'man'},
  command = 'nnoremap <buffer> q <cmd>quit<cr>'
})

