local M = {}

local DIVIDER = string.rep("─", 60)

local buf_id = nil

local function get_or_create_buf()
  if buf_id and vim.api.nvim_buf_is_valid(buf_id) then
    return buf_id
  end
  buf_id = vim.api.nvim_create_buf(false, true)
  vim.bo[buf_id].buftype = "nofile"
  vim.bo[buf_id].buflisted = false
  vim.bo[buf_id].swapfile = false
  vim.api.nvim_buf_set_name(buf_id, "curl-runner-log")
  return buf_id
end

local function append(lines)
  local buf = get_or_create_buf()
  vim.bo[buf].modifiable = true
  local existing = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if #existing == 1 and existing[1] == "" then
    -- Replace the initial empty line rather than appending after it
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  else
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  end
  vim.bo[buf].modifiable = false
end

function M.record(cmd_str, response)
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  -- Try to extract method + URL from cmd for the header line
  local url = cmd_str:match("https?://[^%s'\"]+") or cmd_str
  local entry = {
    string.format("[%s] %s", timestamp, url),
    "> " .. cmd_str,
    "",
  }
  for _, line in ipairs(vim.split(response, "\n")) do
    table.insert(entry, line)
  end
  table.insert(entry, DIVIDER)
  table.insert(entry, "")
  append(entry)
end

function M.open(open_with)
  local buf = get_or_create_buf()
  local cmd = open_with or "split"
  vim.cmd(cmd)
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  -- Scroll to bottom
  local line_count = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_win_set_cursor(win, { line_count, 0 })
end

M.DIVIDER = DIVIDER

return M
