-- Space as leader key
vim.g.mapleader = ' '

-- ========================================================================== --
-- ==                               BUILT-IN                               == --
-- ========================================================================== --

-- Basic clipboard interaction
vim.keymap.set({'n', 'x'}, 'gy', '"+y') -- copy
vim.keymap.set({'n', 'x'}, 'gp', '"+p') -- paste

-- Go to first character in line
vim.keymap.set('', '<leader>h', '^')

-- Go to last character in line
vim.keymap.set('', '<leader>l', 'g_')

-- Re-do
vim.keymap.set('n', 'U', '<C-r>')

-- Whatever you delete, make it go away
vim.keymap.set({'n', 'x'}, 'c', '"_c')
vim.keymap.set({'n', 'x'}, 'x', '"_x')
vim.keymap.set({'n', 'x'}, 'X', '"_d')

-- Moving lines and preserving indentation
vim.keymap.set('n', '<C-j>', "<cmd>move .+1<cr>==")
vim.keymap.set('n', '<C-k>', "<cmd>move .-2<cr>==")
vim.keymap.set('x', '<C-j>', "<esc><cmd>'<,'>move '>+1<cr>gv=gv")
vim.keymap.set('x', '<C-k>', "<esc><cmd>'<,'>move '<-2<cr>gv=gv")

-- Select all text
vim.keymap.set('n', '<leader>a', '<cmd>keepjumps normal! ggVG<cr>')

-- Write file
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>')

-- Safe quit
vim.keymap.set('n', '<leader>qq', '<cmd>quitall<cr>')

-- Force quit
vim.keymap.set('n', '<leader>Q', '<cmd>quitall!<cr>')

-- Search open buffers
vim.keymap.set('n', '<leader><space>', '<cmd>ls<cr>:buffer ')

-- Close buffer
vim.keymap.set('n', '<leader>bc', '<cmd>bdelete<cr>')

-- Close window
vim.keymap.set('n', '<leader>bq', '<cmd>close<cr>')

-- Move to last active buffer
vim.keymap.set('n', '<leader>bl', '<cmd>buffer #<cr>')

-- Show diagnostic message
vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

-- Go to previous diagnostic
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

-- Go to next diagnostic
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

-- Toggle file explorer
vim.keymap.set('n', '<leader>e', function()
  if vim.bo.filetype == 'netrw' then
    return '<cmd>close<cr>'
  end

  if vim.t.netrw_lexbufnr then
    return '<cmd>Lexplore<cr>'
  end

  return '<cmd>Lexplore %:p:h<cr>'
end, {expr = true})

-- Open file explorer
vim.keymap.set('n', '<leader>E', '<cmd>Explore<cr>')

-- Disable s keymap. We'll use this as prefix
vim.keymap.set('n', 's', '<nop>')

-- Very nomagic search
vim.keymap.set('n', 'S', [[/\V]])

-- Add word to search then replace
vim.keymap.set('n', 'sx', [[<cmd>let @/='\<'.expand('<cword>').'\>'<cr>"_ciw]])

-- Add selection to search then replace
vim.keymap.set('x', 'sx', [[y<cmd>let @/=substitute(escape(@", '/'), '\n', '\\n', 'g')<cr>"_cgn]])

-- Record macro on word
vim.keymap.set('n', 'siq', [[<cmd>let @/=expand('<cword>')<cr>viwo<Esc>qi]])

-- Begin search and replace with a macro
vim.keymap.set('x', 'siq', [[y<cmd>let @/=substitute(escape(@", '/'), '\n', '\\n', 'g')<cr>gvqi]])

-- Apply macro in the next instance of the search
vim.keymap.set('n', '<F8>', 'gn@i')

-- Repeat recently used macro or use @i
vim.keymap.set('n', 'Q', function()
  local cmd = vim.api.nvim_command
  if not pcall(cmd, 'normal! @@') then
    cmd('normal! @i')
  end
end)

-- Undo break points
local break_points = {'<space>', '-', '_', ':', '.', '/'}
for _, char in ipairs(break_points) do
  vim.keymap.set('i', char, char .. '<C-g>u')
end

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP keymaps',
  callback = function(event)
    local opts = {buffer = event.buf}

    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

    vim.keymap.set({'n', 'x'}, 'gq', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set({'n', 'i'}, '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  end
})

-- ========================================================================== --
-- ==                                PLUGIN                                == --
-- ========================================================================== --

vim.g.offworld_completion = {
  lsp_omnifunc = true,
  tab_complete = true,
  toggle_menu = '<C-e>',
}

vim.keymap.set('n', 'M', '<cmd>BufferNavMenu<cr>')
vim.keymap.set('n', '<leader>m', '<cmd>BufferNavMark<cr>')
vim.keymap.set('n', '<leader>M', '<cmd>BufferNavMark!<cr>')
vim.keymap.set('n', '<M-1>', '<cmd>BufferNav 1<cr>')
vim.keymap.set('n', '<M-2>', '<cmd>BufferNav 2<cr>')
vim.keymap.set('n', '<M-3>', '<cmd>BufferNav 3<cr>')
vim.keymap.set('n', '<M-4>', '<cmd>BufferNav 4<cr>')

vim.keymap.set({'', 't', 'i'}, '<F5>', function()
  local direction = 'bottom'
  local size
  if vim.o.lines < 19 then
    direction = 'right'
    size = 0.4
  end

  require('offworld.terminal').toggle({direction = direction, size = size})
end)

