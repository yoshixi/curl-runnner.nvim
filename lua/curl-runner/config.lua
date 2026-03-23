local M = {}

M.defaults = {
  keymap = "<leader>rc",
  window = { width = 0.85, height = 0.75 },
  format_json = true,
  log = {
    enabled = true,
    command = "CurlLog",
    open_with = "split",
  },
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
