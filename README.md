# devpod-template
Template for DevPod working in the project

# How to build docker images

```bash
docker buildx build -t devpod-template:alpine -f Dockerfile-alpine .
```

```bash
devpod up --devcontainer-path .devcontainer/devcontainer.json --ide vscode --dotfiles https://github.com/dewwripper/dotfiles --dotfiles-script .setup-no-install.sh .
```

# code-review-graph

[code-review-graph](https://github.com/tirth8205/code-review-graph) is baked into `Dockerfile-custom` and exposed to Claude Code as an MCP server. It is set up so that **client repositories are never modified**:

- The CLI is installed with `uv` into `/opt/code-review-graph` (pinned via `ARG CRG_VERSION`), because `~/.local` is bind-mounted from the host.
- `/usr/local/bin/code-review-graph` is a wrapper (`scripts/code-review-graph`) that stores each repo's graph in `$CRG_HOME/graphs/<repo>-<hash>` (`CRG_HOME=~/.local/share/code-review-graph`, persisted on the host) instead of `<repo>/.code-review-graph/`.
- `code-review-graph install` / `init` are blocked, since they write `.mcp.json`, `CLAUDE.md`, skills, hooks and `.gitignore` into the repo. Set `CRG_ALLOW_REPO_WRITES=1` to bypass.
- `postCreateCommand` registers the MCP server once at Claude Code **user** scope (`~/.claude.json`), not per repo.

Usage inside the devcontainer:

```bash
cd ~/workspace/<client-repo>
code-review-graph build     # first time
code-review-graph update    # incremental refresh after changes (or: code-review-graph watch)
claude                      # code-review-graph MCP tools are available
```

Verify the setup:

```bash
code-review-graph --version
claude mcp get code-review-graph
```

> Note: `~/.claude.json` is shared with the host, so Claude Code on the host lists `code-review-graph` as a failed MCP server unless it is installed there too. This is harmless.
