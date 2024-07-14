local M = {}
local uv = vim.uv or vim.loop

local function dir_parents(start)
  return function(_, dir)
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      return
    end

    return parent
  end,
    nil,
    start
end

function M.find_first(bufnr, list)
  local dir = nil
  if bufnr == nil then
    bufnr = 0
  end

  local ok, name = pcall(vim.api.nvim_buf_get_name, bufnr)
  dir = ok and vim.fn.fnamemodify(name, ':h') or dir

  if dir == nil then
    return
  end

  local dirs = {dir}
  local stop = list.stop or vim.env.HOME
  for path in dir_parents(dir) do
    if path == stop then
      break
    end

    table.insert(dirs, path)
  end

  local str = '%s/%s'
  for _, path in ipairs(dirs) do
    for _, file in ipairs(list) do
      if uv.fs_stat(str:format(path, file)) then
        return path
      end
    end
  end
end

return M

