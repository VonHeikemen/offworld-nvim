-- File explorer window size
vim.g.netrw_winsize = 30

-- Hide banner
vim.g.netrw_banner = 0

-- Hide dotfiles
vim.g.netrw_list_hide = [[\(^\|\s\s\)\zs\.\S\+]]

-- A better copy command (for unix-like systems)
vim.g.netrw_localcopydircmd = 'cp -r'

local function mappings(event)
  local map = function(mode, lhs, rhs, opts)
    opts = opts or {remap = true}
    opts.buffer = event.buf
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- Close netrw window
  map('n', 'q', '<cmd>close<cr>', {nowait = true})

  -- Go to file and close Netrw window
  map('n', 'L', function()
    if vim.t.netrw_lexbufnr then
      return '<Plug>NetrwLocalBrowseCheck<cmd>Lexplore<cr>'
    end

    return '<Plug>NetrwLocalBrowseCheck'
  end, {expr = true})

  -- Go back in history
  map('n', 'H', 'u')

  -- Go up a directory
  map('n', 'h', '-^')

  -- Go down a directory / open file
  map('n', 'l', '<cr>')

  -- Toggle dotfiles
  map('n', 'za', 'gh')

  -- Close the preview window
  map('n', 'P', '<C-w>z')
end

local group = vim.api.nvim_create_augroup('netrw_cmds', {clear = true})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = {'netrw'},
  desc = 'Setup mappings for netrw',
  callback = mappings,
})

