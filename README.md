# curl-runner.nvim

Run `curl` commands directly from Neovim. Place your cursor on a curl command (or a multi-line block using `\` continuation), hit a keymap, and see the response in a floating window. All requests and responses are logged to an in-memory buffer for the duration of the Neovim session.

## Features

- **Run curl from buffer** — detects the curl block under the cursor (including `\`-continued lines)
- **Floating response window** — shows HTTP headers + body, close with `q` or `<Esc>`
- **JSON auto-formatting** — pretty-prints JSON responses via `jq` (falls back to built-in encoder)
- **In-session log buffer** — all requests/responses accumulated in `:CurlLog` for the lifetime of the process

## Requirements

- Neovim ≥ 0.9
- `curl` in `$PATH`
- `jq` in `$PATH` *(optional, for JSON pretty-printing)*

## Installation

### lazy.nvim

```lua
{
  "yoshixi/curl-runnner.nvim",
  opts = {},
}
```

### Manual setup

```lua
require("curl-runner").setup()
```

## Configuration

All options with their defaults:

```lua
require("curl-runner").setup({
  -- Keymap to run the curl block at cursor (normal + visual mode)
  keymap = "<leader>rc",

  -- Floating window size as a fraction of the editor
  window = { width = 0.85, height = 0.75 },

  -- Auto-detect and pretty-print JSON responses
  format_json = true,

  -- In-session log buffer
  log = {
    enabled = true,
    command = "CurlLog",       -- user command to open the log
    open_with = "split",       -- "split" | "vsplit" | "tabnew"
  },
})
```

## Usage

### Keymap

Place the cursor anywhere in a curl command and press `<leader>rc`:

```sh
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{"name": "Alice"}'
```

### Commands

| Command | Description |
|---|---|
| `:CurlRun` | Run the curl block at the cursor |
| `:CurlRun curl https://example.com` | Run an arbitrary curl command |
| `:CurlLog` | Open the in-session request/response log |

## Log buffer

`:CurlLog` opens a read-only split showing all requests made since Neovim started:

```
[2026-03-23 14:05:32] https://api.example.com/users
> curl -i -X POST https://api.example.com/users ...

HTTP/2 201 Created
Content-Type: application/json

{ "id": 42, "name": "Alice" }

────────────────────────────────────────────────────────────
```

The log is **not** persisted to disk — it resets when Neovim exits.

## License

MIT
