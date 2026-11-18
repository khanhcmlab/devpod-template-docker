#!/bin/bash
# Registers the code-review-graph MCP server for Antigravity (agy) at user scope (idempotent).
# Kept out of devcontainer.json because single quotes in postCreateCommand break DevPod's image metadata JSON.
set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v agy >/dev/null 2>&1; then
  echo "agy CLI not found on PATH; cannot register code-review-graph MCP server." >&2
  exit 1
fi

if agy mcp list 2>/dev/null | grep -qE '(^|[[:space:]])code-review-graph([[:space:]:]|$)'; then
  echo "code-review-graph MCP server is already registered."
else
  agy mcp add code-review-graph -- code-review-graph serve
fi
