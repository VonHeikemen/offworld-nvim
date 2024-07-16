local M = {}
local s = {}

local augroup = vim.api.nvim_create_augroup('offworld_lsp', {clear = true})
local extra_setup = vim.api.nvim_parse_cmd == nil
local all_clients = {}

local function lsp_format(input)
  require('offworld.lsp-format').format_command(input)
end

local function compat_setup(settings, client, bufnr)
  local lsp_omnifunc = vim.tbl_get(settings, 'completion', 'lsp_omnifunc')
  local capabilities = client.server_capabilities

  if capabilities.completionProvider then
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
  end

  if capabilities.definitionProvider then
    vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
  end

  if lsp_omnifunc then
    require('offworld.completion').set_omnifunc(bufnr)
  end
end

function M.attached(client, bufnr)
  local settings = require('offworld.settings')

  if extra_setup then
    compat_setup(settings, client, bufnr)
  end

  if settings.lsp_attach then
    settings.lsp_attach(client, bufnr)
  end

  vim.api.nvim_buf_create_user_command(
    bufnr,
    'LspFormat',
    lsp_format,
    {nargs = '?', bang = true, range = true}
  )
end

function M.new_client(opts)
  if opts.filetypes == nil then
    local msg = '[lsp] Must provide a list of filetypes for the LSP client instance'
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end

  if opts.name == nil then
    local msg = '[lsp] Must provide a name for the LSP client instance'
    vim.notify(msg, vim.log.levels.ERROR)
    return
  end

  local setup_id
  local defaults = {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    on_exit = vim.schedule_wrap(function()
      if setup_id then
        pcall(vim.api.nvim_del_autocmd, setup_id)
      end
    end),
  }

  local config = vim.tbl_deep_extend('force', defaults, opts)

  local get_root = nil
  if type(opts.root_dir) == 'function' then
    get_root = opts.root_dir
    config.root_dir = nil
  end

  if opts.on_exit then
    local cb = opts.on_exit
    local cleanup = defaults.on_exit
    config.on_exit = function(...)
      cleanup()
      cb(...)
    end
  end

  if extra_setup then
    if opts.on_attach == nil then
      config.on_attach = M.attached
    else
      local attached = M.attached
      local on_attach = opts.on_attach
      config.on_attach = function(...)
        attached(...)
        on_attach(...)
      end
    end
  end

  local desc = string.format('Attach LSP: %s', config.name)
  local start_client = s.start_client

  setup_id = vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = config.filetypes,
    desc = desc,
    callback = function(event)
      start_client(event.buf, config, get_root)
    end
  })
end

function s.start_client(bufnr, config, root_dir)
  local current_dir = nil

  if root_dir then
    current_dir = root_dir(bufnr)
  elseif type(config.root_dir) == 'string' then
    current_dir = config.root_dir
  end

  if current_dir == nil then
    return
  end

  local client_started = false
  local get = vim.lsp.get_client_by_id

  ---
  -- reuse client instance
  ---
  for _, id in pairs(all_clients) do
    local client = get(id)
    if client
      and config.name == client.name
      and vim.tbl_contains(client.workspace_folders or {}, current_dir)
    then
      local ok = vim.lsp.buf_attach_client(bufnr, client.id)

      if ok then
        client_started = true
      end
    end
  end

  if client_started then
    return
  end

  ---
  -- create new instance
  ---
  config.root_dir = current_dir
  local client_id, err = vim.lsp.start_client(config)

  if err then
    vim.notify(err, vim.log.levels.WARN)
    return nil
  end

  if client_id then
    client_started = vim.lsp.buf_attach_client(bufnr, client_id)
  end

  if client_started == false then
    return
  end

  all_clients[#all_clients + 1] = {client_id}
end

return M

