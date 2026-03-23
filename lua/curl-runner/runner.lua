local window = require("curl-runner.window")
local log = require("curl-runner.log")

local M = {}

-- Join a multi-line curl block starting at `start_lnum` (1-indexed).
-- Lines ending with \ are joined with the next.
local function collect_block(bufnr, start_lnum)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_lnum - 1, -1, false)
  local parts = {}
  for _, line in ipairs(lines) do
    table.insert(parts, (line:gsub("\\%s*$", "")))
    if not line:match("\\%s*$") then break end
  end
  return table.concat(parts, " ")
end

-- Walk upward to find the first line of the curl block at `lnum`.
local function find_block_start(bufnr, lnum)
  local start = lnum
  while start > 1 do
    local prev = vim.api.nvim_buf_get_lines(bufnr, start - 2, start - 1, false)[1] or ""
    if prev:match("\\%s*$") then
      start = start - 1
    else
      break
    end
  end
  local cmd = collect_block(bufnr, start)
  if not cmd:match("curl") then return nil end
  return start
end

local function maybe_format_json(body)
  local jq = vim.fn.exepath("jq")
  if jq ~= "" then
    local result = vim.fn.system({ jq, "." }, body)
    if vim.v.shell_error == 0 then return result end
  end
  local ok, decoded = pcall(vim.fn.json_decode, body)
  if ok and decoded then return vim.fn.json_encode(decoded) end
  return body
end

-- Execute `cmd_str` and display the result.
function M.run(cmd_str, config)
  config = config or {}

  -- Ensure headers are included
  if not cmd_str:match("%-[a-zA-Z]*i[a-zA-Z]*%s") and not cmd_str:match("%-%-%include") then
    cmd_str = cmd_str:gsub("^(curl%s)", "%1-i ")
  end

  local win_opts = config.window or {}
  local loading_buf, loading_win = window.loading(win_opts)

  local function close_loading()
    if vim.api.nvim_win_is_valid(loading_win) then
      vim.api.nvim_win_close(loading_win, true)
    end
  end

  vim.fn.jobstart(cmd_str, {
    stdout_buffered = true,
    stderr_buffered = true,

    on_stdout = function(_, data)
      vim.schedule(function()
        close_loading()

        local raw_output = table.concat(data, "\n")

        -- Split on the first blank line separating headers from body
        local header_part, body_part = raw_output:match("^(.-)\r?\n\r?\n(.*)$")
        if not header_part then
          header_part, body_part = "", raw_output
        end

        -- Build display lines
        local display = {}
        if header_part ~= "" then
          for _, h in ipairs(vim.split(header_part, "\r?\n")) do
            table.insert(display, h)
          end
          table.insert(display, "")
          table.insert(display, string.rep("─", 60))
          table.insert(display, "")
        end

        local is_json = body_part:match("^%s*[{%[]") or
            (header_part:lower():match("content%-type:%s*application/json"))

        local formatted_body = (config.format_json ~= false and is_json)
            and maybe_format_json(body_part)
            or body_part

        for _, line in ipairs(vim.split(formatted_body, "\n")) do
          table.insert(display, line)
        end

        local status = header_part:match("HTTP/%S+ (%d+ [^\r\n]+)") or "Response"
        local buf, _ = window.open_float(display, "curl — " .. status, win_opts)

        if is_json then vim.bo[buf].filetype = "json" end

        -- Write to log buffer
        if config.log and config.log.enabled ~= false then
          log.record(cmd_str, raw_output)
        end
      end)
    end,

    on_stderr = function(_, data)
      vim.schedule(function()
        close_loading()
        local msg = table.concat(data, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
        if msg ~= "" then
          window.open_float(vim.split(msg, "\n"), "curl — error", win_opts)
          if config.log and config.log.enabled ~= false then
            log.record(cmd_str, "ERROR:\n" .. msg)
          end
        end
      end)
    end,
  })
end

-- Determine the curl command from the buffer and run it.
function M.run_from_buffer(config)
  local mode = vim.fn.mode()
  local cmd_str

  if mode == "v" or mode == "V" or mode == "\22" then
    local s = vim.fn.getpos("'<")
    local e = vim.fn.getpos("'>")
    local sel = vim.api.nvim_buf_get_lines(0, s[2] - 1, e[2], false)
    cmd_str = table.concat(sel, " "):gsub("\\%s+", " ")
  else
    local lnum = vim.fn.line(".")
    local start = find_block_start(0, lnum)
    if not start then
      vim.notify("[curl-runner] No curl command found at cursor", vim.log.levels.WARN)
      return
    end
    cmd_str = collect_block(0, start)
  end

  cmd_str = cmd_str:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

  if not cmd_str:match("^curl") then
    vim.notify("[curl-runner] Command does not start with 'curl'", vim.log.levels.WARN)
    return
  end

  M.run(cmd_str, config)
end

return M
