local config = require("curl-runner.config")

describe("curl-runner.config", function()
  before_each(function()
    -- Reset to defaults before each test
    config.setup({})
  end)

  it("has correct defaults", function()
    assert.equals("<leader>rc", config.options.keymap)
    assert.equals(0.85, config.options.window.width)
    assert.equals(0.75, config.options.window.height)
    assert.is_true(config.options.format_json)
    assert.is_true(config.options.log.enabled)
    assert.equals("CurlLog", config.options.log.command)
    assert.equals("split", config.options.log.open_with)
  end)

  it("merges user options with defaults", function()
    config.setup({ keymap = "<leader>rr", format_json = false })
    assert.equals("<leader>rr", config.options.keymap)
    assert.is_false(config.options.format_json)
    -- Unspecified values keep defaults
    assert.equals(0.85, config.options.window.width)
    assert.is_true(config.options.log.enabled)
  end)

  it("allows partial log override", function()
    config.setup({ log = { open_with = "vsplit" } })
    assert.equals("vsplit", config.options.log.open_with)
    assert.equals("CurlLog", config.options.log.command)
  end)
end)
