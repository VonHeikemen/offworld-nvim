if vim.fn.exists('##LspAttach') == 1 then
  local lsp_attach = function(event)
    local id = vim.tbl_get(event, 'data', 'client_id')
    local client = id and vim.lsp.get_client_by_id(id)

    if client == nil then
      client = {id = -1}
    end

    require('offworld.lsp-client').attached(client, event.buf)
  end

  vim.api.nvim_create_autocmd('LspAttach', {callback = lsp_attach})
end

