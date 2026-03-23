local config = require("curl-runner.config")
local runner = require("curl-runner.runner")
local log = require("curl-runner.log")

local M = {}

function M.setup(opts)
  config.setup(opts)
end

function M.run(cmd_str)
  runner.run(cmd_str, config.options)
end

function M.run_from_buffer()
  runner.run_from_buffer(config.options)
end

function M.open_log()
  log.open(config.options.log and config.options.log.open_with)
end

return M
