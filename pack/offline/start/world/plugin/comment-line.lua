if vim.fn.has('nvim-0.10') == 0 then
  -- Toggle comment in current line
  vim.keymap.set('n', 'gc', function()
    return require('offworld.comment-line').toggle_op()
  end, {expr = true})

  -- Toggle comment in current selection
  vim.keymap.set('x', 'gc', function()
    require('offworld.comment-line').toggle()
  end)
end

