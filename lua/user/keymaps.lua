-- Space as leader key
vim.g.mapleader = ' '

-- ========================================================================== --
-- ==                               BUILT-IN                               == --
-- ========================================================================== --

-- Basic clipboard interaction
vim.keymap.set({'n', 'x', 'o'}, 'gy', '"+y') -- copy
vim.keymap.set({'n', 'x', 'o'}, 'gp', '"+p') -- paste

-- Go to first character in line
vim.keymap.set('', '<Leader>h', '^')

-- Go to last character in line
vim.keymap.set('', '<Leader>l', 'g_')

-- Whatever you delete, make it go away
vim.keymap.set({'n', 'x'}, 'c', '"_c')
vim.keymap.set({'n', 'x'}, 'x', '"_x')
vim.keymap.set({'n', 'x'}, 'X', '"_d')

-- Select all text
vim.keymap.set('n', '<leader>a', '<cmd>keepjumps normal! ggVG<cr>')

-- Write file
vim.keymap.set('n', '<Leader>w', '<cmd>write<cr>')

-- Safe quit
vim.keymap.set('n', '<Leader>qq', '<cmd>quitall<cr>')

-- Force quit
vim.keymap.set('n', '<Leader>Q', '<cmd>quitall!<cr>')

-- Search open buffers
vim.keymap.set('n', '<Leader><space>', '<cmd>ls<cr>:buffer ')

-- Close buffer
vim.keymap.set('n', '<Leader>bc', '<cmd>bdelete<cr>')

-- Close window
vim.keymap.set('n', '<Leader>bq', '<cmd>q<cr>')

-- Move to last active buffer
vim.keymap.set('n', '<Leader>bl', '<cmd>buffer #<cr>')

-- Show diagnostic message
vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

-- Go to previous diagnostic
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

-- Go to next diagnostic
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')

-- Open file explorer
vim.keymap.set('n', '<leader>e', '<cmd>Lexplore<CR>')
vim.keymap.set('n', '<leader>E', '<cmd>Lexplore %:p:h<CR>')

-- Switch to the directory of the open buffer
vim.keymap.set('n', '<leader>cd', '<cmd>lcd %:p:h<cr>:pwd<cr>')

-- ========================================================================== --
-- ==                                PLUGIN                                == --
-- ========================================================================== --

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

local offworld = require('offworld.settings')

offworld.completion = {
  lsp_omnifunc = true,
  tab_complete = true,
  toggle_menu = '<C-e>',
}

offworld.lsp_keymaps = function(bufnr)
  local opts = {buffer = bufnr}

  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
  vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
  vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
  vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
  vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
  vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>LspFormat!<cr>', opts)
  vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
end

