#!/usr/bin/env bash
# Run the test suite via plenary.nvim's headless mode.
# Requires plenary.nvim to be available (e.g. via lazy.nvim or a local clone).
#
# Usage:
#   ./scripts/test.sh
#   PLENARY_PATH=/path/to/plenary.nvim ./scripts/test.sh

set -e

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLENARY_PATH="${PLENARY_PATH:-${HOME}/.local/share/nvim/lazy/plenary.nvim}"

if [ ! -d "$PLENARY_PATH" ]; then
  echo "plenary.nvim not found at: $PLENARY_PATH"
  echo "Set PLENARY_PATH env var to the correct location."
  exit 1
fi

nvim --headless \
  -u NONE \
  -c "set rtp+=${PLUGIN_ROOT}" \
  -c "set rtp+=${PLENARY_PATH}" \
  -c "runtime plugin/plenary.vim" \
  -c "lua require('plenary.test_harness').test_directory('${PLUGIN_ROOT}/tests', { minimal_init = '${PLUGIN_ROOT}/tests/minimal_init.lua' })" \
  -c "qa!"
