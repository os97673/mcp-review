#!/usr/bin/env bash
set -euo pipefail

COMMAND_DIR="${HOME}/.claude/commands"
COMMAND_FILE="$(dirname "$0")/.claude/commands/review.md"

# ── 1. Install the package and determine the run command ─────────────────────

if command -v uvx &>/dev/null; then
    echo "→ Using uvx (no install needed)"
    RUN_CMD="uvx mcp-review"

elif command -v pipx &>/dev/null; then
    echo "→ Installing via pipx..."
    pipx install mcp-review
    RUN_CMD="mcp-review"

else
    echo "→ Installing via pip..."
    pip install --user mcp-review
    RUN_CMD="mcp-review"
fi

# ── 2. Register the MCP server with Claude Code (user scope = global) ─────────

echo "→ Registering MCP server with Claude Code..."
# shellcheck disable=SC2086
claude mcp add -s user mcp-review -- $RUN_CMD

# ── 3. Install the /review slash command globally ─────────────────────────────

echo "→ Installing /review slash command..."
mkdir -p "$COMMAND_DIR"
cp "$COMMAND_FILE" "$COMMAND_DIR/review.md"

echo ""
echo "Done. Open a new Claude Code session and try /review."
echo "Make sure \$EDITOR is set (e.g. export EDITOR=\"code --wait\")."
