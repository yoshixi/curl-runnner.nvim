-- Auto-loaded by Neovim. Registers keymaps and commands after setup() is called.
-- Users must call require("curl-runner").setup() for this to activate.

vim.api.nvim_create_autocmd("User", {
  pattern = "CurlRunnerSetup",
  once = true,
  callback = function()
    local curl = require("curl-runner")
    local opts = require("curl-runner.config").options

    -- Keymap
    local keymap = opts.keymap or "<leader>rc"
    vim.keymap.set({ "n", "v" }, keymap, function()
      curl.run_from_buffer()
    end, { desc = "curl-runner: run curl at cursor" })

    -- :CurlRun [cmd]
    vim.api.nvim_create_user_command("CurlRun", function(o)
      if o.args ~= "" then
        curl.run(o.args)
      else
        curl.run_from_buffer()
      end
    end, { nargs = "?", desc = "Run curl command" })

    -- :CurlLog
    local log_cmd = (opts.log and opts.log.command) or "CurlLog"
    vim.api.nvim_create_user_command(log_cmd, function()
      curl.open_log()
    end, { desc = "Open curl-runner log buffer" })
  end,
})

-- Fire the event after the plugin files are sourced so setup() can trigger it.
-- setup() fires this event itself; the autocmd above responds to it.
