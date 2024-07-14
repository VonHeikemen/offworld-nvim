local M = {}
local s = {}
local uv = vim.uv or vim.loop
local timeout_ms = 10000
local old_api = vim.api.nvim_parse_cmd == nil

function M.buffer_autoformat(client, bufnr, opts)
  local augroup = vim.api.nvim_create_augroup
  local format_id = augroup(M.format_cmds, {clear = false})

  client = client or {}
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local format_opts = opts or {}

  vim.api.nvim_clear_autocmds({group = M.format_cmds, buffer = bufnr})

  local config = {
    async = false,
    name = client.name,
    verbose = false,
    timeout_ms = format_opts.timeout_ms or timeout_ms,
    formatting_options = format_opts.formatting_options or {},
  }

  local apply_format = function(ev)
    if old_api == false then
      vim.lsp.buf.format(config)
      return
    end

    if config.name then
      s.format_sync(ev.buf, config)
    else
      vim.lsp.buf.formatting_sync(config.formatting_options)
    end
  end

  local desc = 'Format current buffer'

  if client.name then
    desc = string.format('Format buffer with %s', client.name)
  end

  vim.api.nvim_create_autocmd('BufWritePre', {
    group = format_id,
    buffer = bufnr,
    desc = desc,
    callback = apply_format
  })
end

function M.format_command(input)
  local name
  local async = input.bang
  local has_range = input.line2 == input.count

  if #input.args > 0 then
    name = input.args
  end

  if old_api == false then
    vim.lsp.buf.format({
      async = async,
      name = name,
      timeout_ms = timeout_ms
    })
    return
  end

  if name == nil then
    if has_range then
      vim.lsp.buf.range_formatting()
      return
    end

    if async then
      vim.lsp.buf.formatting()
    else
      vim.lsp.buf.formatting_sync()
    end
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local config = {
    name = name,
    verbose = true,
    timeout_ms = timeout_ms,
  }

  if has_range then
    if async then
      s.async_range(bufnr, config)
    else
      s.sync_range(bufnr, config)
    end
  else
    if async then
      s.format_async(bufnr, config)
    else
      s.format_sync(bufnr, config)
    end
  end
end

function s.format_sync(bufnr, opts)
  local get_clients = old_api and vim.lsp.get_active_clients or vim.lsp.get_clients
  local client = vim.tbl_filter(
    function(c) return c.name == opts.name end,
    get_clients()
  )[1]

  if (
    client == nil or
    vim.lsp.buf_is_attached(bufnr, client.id) == false
  ) then
    local msg = 'Format request failed, no matching language servers'
    if opts.verbose then
      vim.notify(msg)
    end
    return
  end

  local params = vim.lsp.util.make_formatting_params(opts.formatting_options)
  local result = client.request_sync(
    'textDocument/formatting',
    params,
    opts.timeout_ms,
    bufnr
  )

  if result and result.result then
    vim.lsp.util.apply_text_edits(result.result, bufnr, client.offset_encoding)
  end
end

function s.format_async(bufnr, opts)
  local get_clients = old_api and vim.lsp.get_active_clients or vim.lsp.get_clients
  local client = vim.tbl_filter(
    function(c) return c.name == opts.name end,
    get_clients()
  )[1]

  if (
    client == nil or
    vim.lsp.buf_is_attached(bufnr, client.id) == false
  ) then
    local msg = 'Format request failed, no matching language servers'
    if opts.verbose then
      vim.notify(msg)
    end
    return
  end

  local params = vim.lsp.util.make_formatting_params(opts.formatting_options)
  local timer = uv.new_timer()

  local cleanup = function()
    timer:stop()
    timer:close()
    timer = nil
  end

  local timeout = opts.timeout_ms
  if timeout <= 0 then
    timeout = timeout_ms
  end

  timer:start(timeout, 0, cleanup)

  local encoding = client.offset_encoding
  local handler = function(err, result, ctx)
    if timer == nil or err ~= nil or result == nil  then
      return
    end

    timer:stop()
    timer:close()
    timer = nil

    if not vim.api.nvim_buf_is_loaded(ctx.bufnr) then
      vim.fn.bufload(ctx.bufnr)
    end

    vim.lsp.util.apply_text_edits(result, ctx.bufnr, encoding)
  end

  client.request('textDocument/formatting', params, handler, bufnr)
end

function s.sync_range(bufnr, opts)
  local get_clients = old_api and vim.lsp.get_active_clients or vim.lsp.get_clients
  local client = vim.tbl_filter(
    function(c) return c.name == opts.name end,
    get_clients()
  )[1]

  if (
    client == nil or
    vim.lsp.buf_is_attached(bufnr, client.id) == false
  ) then
    local msg = 'Format request failed, no matching language servers'
    if opts.verbose then vim.notify(msg) end
    return
  end

  local config = opts.formatting_options

  local params = vim.lsp.util.make_given_range_params()

  params.options = vim.lsp.util.make_formatting_params(config).options

  local resp = client.request_sync(
    'textDocument/rangeFormatting',
    params,
    opts.timeout_ms,
    bufnr
  )

  if resp and resp.result then
    vim.lsp.util.apply_text_edits(resp.result, bufnr, client.offset_encoding)
  end
end

function s.async_range(bufnr, opts)
  local get_clients = old_api and vim.lsp.get_active_clients or vim.lsp.get_clients
  local client = vim.tbl_filter(
    function(c) return c.name == opts.name end,
    get_clients()
  )[1]

  if (
    client == nil or
    vim.lsp.buf_is_attached(bufnr, client.id) == false
  ) then
    local msg = 'Format request failed, no matching language servers'
    if opts.verbose then vim.notify(msg) end
    return
  end

  local params = vim.lsp.util.make_given_range_params()

  local config = opts.formatting_options
  params.options = vim.lsp.util.make_formatting_params(config).options

  local timer = uv.new_timer()

  local cleanup = function()
    timer:stop()
    timer:close()
    timer = nil
  end

  local timeout = opts.timeout_ms
  if timeout <= 0 then
    timeout = timeout_ms
  end

  timer:start(timeout, 0, cleanup)

  local encoding = client.offset_encoding
  local handler = function(err, result, ctx)
    if timer == nil or err ~= nil or result == nil  then
      return
    end

    timer:stop()
    timer:close()
    timer = nil

    if not vim.api.nvim_buf_is_loaded(ctx.bufnr) then
      vim.fn.bufload(ctx.bufnr)
    end

    vim.lsp.util.apply_text_edits(result, ctx.bufnr, encoding)
  end

  client.request('textDocument/rangeFormatting', params, handler, bufnr)
end

return M

