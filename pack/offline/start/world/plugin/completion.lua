local settings = vim.g.offworld_completion

if type(settings) ~= 'table' then
  return
end

vim.opt.shortmess:append('c')

local completion = require('offworld.completion')

if settings.tab_complete then
  completion.tab_complete()
end

if settings.toggle_menu then
  completion.set_trigger(settings.toggle_menu)
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    require('offworld.completion').set_omnifunc(event.buf)
  end
})

