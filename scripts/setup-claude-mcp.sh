#!/bin/bash
# Registers the code-review-graph MCP server for Claude Code at user scope (idempotent).
# Kept out of devcontainer.json because single quotes in postCreateCommand break DevPod's image metadata JSON.
# claude is installed through nvm, which is not on PATH in non-interactive shells.
# Sourced before strict mode because nvm.sh trips over set -eu.
. "${HOME}/.nvm/nvm.sh"
set -euo pipefail

if claude mcp get code-review-graph >/dev/null 2>&1; then
  echo "code-review-graph MCP server is already registered."
else
  claude mcp add --scope user code-review-graph -- code-review-graph serve
fi
