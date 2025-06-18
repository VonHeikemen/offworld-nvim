---
-- I like to start language servers manually.
-- So I will use a command :LspEnable {server_name}
-- Where {server_name} is a property in vim.g.lsp
-- Server configurations are in the `ftplugin` folder
---
vim.g.lsp = {
  lua_ls = false,
  intelephense = false,
}

vim.api.nvim_create_user_command('LspEnable', function(input)
  local names = input.fargs
  local config = vim.g.lsp
  for _, server in ipairs(names) do
    config[server] = true
  end

  vim.g.lsp = config
  local has_filetype = vim.bo.filetype ~= ''

  if has_filetype then
    vim.schedule(function() pcall(vim.api.nvim_command, 'edit') end)
  end
end, {nargs = '*'})

if vim.fn.has('nvim-0.10') == 1 then
  _G.lsp_workspace = vim.fs.root
else
  _G.lsp_workspace = function(bufnr, markers)
    local buffer = vim.api.nvim_buf_get_name(bufnr)
    local paths = vim.fs.find(markers, {
      upward = true,
      path = vim.fn.fnamemodify(buffer, ':p:h'),
    })

    return vim.fs.dirname(paths[1])
  end
end

