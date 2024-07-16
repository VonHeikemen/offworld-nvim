local offworld = require('offworld.settings')

if type(offworld.completion) ~= 'table' then
  return
end

vim.opt.completeopt = {'menu', 'menuone', 'noinsert'}
vim.opt.shortmess:append('c')

local settings = offworld.completion
local completion = require('offworld.completion')

if settings.tab_complete then
  completion.tab_complete()
end

if settings.toggle_menu then
  completion.set_trigger(settings.toggle_menu)
end

if settings.lsp_omnifunc and vim.fn.exists('##LspAttach') == 1 then
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
      require('offworld.completion').set_omnifunc(event.buf)
    end
  })
end

