-- Auto-loaded by Neovim. Registers keymaps and commands on VimEnter,
-- using defaults if setup() has not been called explicitly.

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local config = require("curl-runner.config")
    -- Initialize with defaults if the user never called setup()
    if vim.tbl_isempty(config.options) then
      config.setup({})
    end

    local curl = require("curl-runner")
    local opts = config.options

    vim.keymap.set({ "n", "v" }, opts.keymap, function()
      curl.run_from_buffer()
    end, { desc = "curl-runner: run curl at cursor" })

    vim.api.nvim_create_user_command("CurlRun", function(o)
      if o.args ~= "" then
        curl.run(o.args)
      else
        curl.run_from_buffer()
      end
    end, { nargs = "?", desc = "Run curl command" })

    vim.api.nvim_create_user_command(opts.log.command, function()
      curl.open_log()
    end, { desc = "Open curl-runner log buffer" })
  end,
})
