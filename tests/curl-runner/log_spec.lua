local log = require("curl-runner.log")

describe("curl-runner.log", function()
  -- Helper: get all lines from the log buffer
  local function log_lines()
    local buf = vim.fn.bufnr("curl-runner-log")
    if buf == -1 then return {} end
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  end

  before_each(function()
    -- Wipe the log buffer between tests by forcing a fresh one
    local buf = vim.fn.bufnr("curl-runner-log")
    if buf ~= -1 then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    -- Clear the cached buf_id inside the module by reloading it
    package.loaded["curl-runner.log"] = nil
    log = require("curl-runner.log")
  end)

  it("creates the log buffer on first record", function()
    log.record("curl https://example.com", "HTTP/1.1 200 OK\n\nOK")
    local buf = vim.fn.bufnr("curl-runner-log")
    assert.is_true(buf ~= -1)
  end)

  it("appends a timestamped entry", function()
    log.record("curl https://example.com", "HTTP/1.1 200 OK\n\nhello")
    local lines = log_lines()
    -- First line should contain the URL
    assert.is_true(lines[1]:match("https://example%.com") ~= nil)
    -- Second line should be the command
    assert.equals("> curl https://example.com", lines[2])
  end)

  it("appends a divider after each entry", function()
    log.record("curl https://a.com", "HTTP/1.1 200 OK\n\nbody")
    local lines = log_lines()
    local divider = require("curl-runner.log").DIVIDER
    local found = false
    for _, l in ipairs(lines) do
      if l == divider then found = true; break end
    end
    assert.is_true(found)
  end)

  it("accumulates multiple records", function()
    log.record("curl https://a.com", "HTTP/1.1 200 OK\n\na")
    log.record("curl https://b.com", "HTTP/1.1 404 Not Found\n\nb")
    local lines = log_lines()
    local a_found, b_found = false, false
    for _, l in ipairs(lines) do
      if l:match("https://a%.com") then a_found = true end
      if l:match("https://b%.com") then b_found = true end
    end
    assert.is_true(a_found)
    assert.is_true(b_found)
  end)

  it("log buffer is not listed", function()
    log.record("curl https://example.com", "HTTP/1.1 200 OK\n\nok")
    local buf = vim.fn.bufnr("curl-runner-log")
    assert.is_false(vim.bo[buf].buflisted)
  end)
end)
