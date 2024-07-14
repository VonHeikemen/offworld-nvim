require('user.settings')
require('user.commands')
require('user.keymaps')

-- Theming
pcall(vim.cmd, 'colorscheme sigil')
require('user.statusline')
require('user.tabline')
