local M = {}
local s = {}
local block_comment = '%s%s%s%s'
local line_comment = '%s%s%s'

s.with_range = { 'v', 'V', '\22', '\22s', 's', 'S' }
s.not_supported = { 'o', 'c', 'cv', 'ce', '!', 't' }

if _G._user_comment_line == nil then _G._user_comment_line = function() M.toggle() end end

-- Make toggle() dot-repeatable
function M.toggle_op()
  -- for more details, see:
  -- https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
  vim.o.operatorfunc = 'v:lua._user_comment_line'
  return 'g@l'
end

function M.toggle()
  local cs = vim.bo.commentstring
  if cs == '' or cs == nil then
    local msg = '[comment-line] Option "commentstring" is empty for the current buffer'
    vim.notify(msg, vim.log.levels.WARN)
    return
  end

  local range
  local mode = vim.api.nvim_get_mode().mode

  if vim.tbl_contains(s.with_range, mode) then
    local b = vim.fn.getpos('v')
    local e = vim.fn.getpos('.')
    if b[2] > e[2] then
      local temp = b
      b = e
      e = temp
    end
    range = { start = b[2], ends = e[2] }
  elseif vim.tbl_contains(s.not_supported, mode) then
    vim.notify('[comment-line] Current mode is not supported', vim.log.levels.WARN)
    return
  else
    local lnum = vim.fn.line('.')
    range = { start = lnum, ends = lnum }
  end

  local l, r = cs:match('^%s*(.*)%%s(.-)%s*$')
  local input = { left = l, right = vim.trim(r) == '' and '' or r }

  local new = {}
  local uncomment
  local first_indent

  local lines = vim.api.nvim_buf_get_lines(0, range.start - 1, range.ends, true)

  for _, line in ipairs(lines) do
    if #vim.trim(line) >= 1 then
      uncomment = s.is_comment(input, line)
      first_indent = { line:find('^(%s*)') }
      break
    end
  end

  if uncomment == nil then return end

  input.default_indent = first_indent
  local transform = uncomment and s.uncomment_line or s.comment_line

  for _, line in ipairs(lines) do
    new[#new + 1] = transform(input, line)
  end

  vim.api.nvim_buf_set_lines(0, range.start - 1, range.ends, false, new)
end

function s.is_comment(opts, text)
  local _, indent = text:find('^(%s*)')
  local code = text:sub(indent + 1)

  return vim.startswith(code, opts.left)
end

function s.comment_line(opts, text)
  if text == '' then return text end

  local di = opts.default_indent
  local _, indent, pad = text:find('^(%s*)')
  local use_default = indent > di[2]

  if use_default then
    indent = di[2]
    pad = di[3]
  end

  local code = text:sub(indent + 1)
  local new_text

  if opts.right == '' then
    new_text = line_comment:format(pad, opts.left, code)
  else
    new_text = block_comment:format(pad, opts.left, code, opts.right)
  end

  return new_text
end

function s.uncomment_line(opts, text)
  if text == '' then return text end

  local start = text:find(opts.left:sub(1, 1))
  local index = start + #opts.left

  if opts.right == '' then
    ends = #text
  else
    ends = #text - #opts.right
  end

  local code = text:sub(index, ends)
  if start == 1 then return code end

  local indent = text:sub(1, start - 1)
  return string.format('%s%s', indent, code)
end

return M
