#!/usr/bin/env bash
set -euo pipefail

COMMAND_DIR="${HOME}/.claude/commands"
COMMAND_FILE="$(dirname "$0")/.claude/commands/iterate.md"

# ── 1. Install the package and determine the run command ─────────────────────

# Find Python 3.10+
find_python() {
    for cmd in python3.13 python3.12 python3.11 python3.10 python3 python; do
        if command -v "$cmd" &>/dev/null; then
            version=$("$cmd" -c "import sys; print(sys.version_info >= (3,10))" 2>/dev/null)
            if [[ "$version" == "True" ]]; then
                echo "$cmd"
                return 0
            fi
        fi
    done
    return 1
}

if command -v uvx &>/dev/null; then
    echo "→ Using uvx (no install needed)"
    RUN_CMD="uvx mcp-review"

elif command -v pipx &>/dev/null; then
    echo "→ Installing via pipx..."
    pipx install mcp-review 2>/dev/null || pipx upgrade mcp-review
    RUN_CMD="mcp-review"

else
    REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
    PYTHON=$(find_python || true)
    if [[ -z "$PYTHON" ]]; then
        echo "Error: Python 3.10+ not found. Install it first (e.g. brew install python@3.12)."
        exit 1
    fi
    VENV_DIR="${HOME}/.local/share/mcp-review/venv"
    echo "→ Creating venv at $VENV_DIR..."
    "$PYTHON" -m venv "$VENV_DIR"
    echo "→ Installing into venv..."
    "$VENV_DIR/bin/pip" install --upgrade "$REPO_DIR"
    RUN_CMD="$VENV_DIR/bin/mcp-review"
fi

# ── 2. Register the MCP server with Claude Code (user scope = global) ─────────

echo "→ Registering MCP server with Claude Code..."
# Remove existing registration if present, then re-add
claude mcp remove mcp-review -s user 2>/dev/null || true
# shellcheck disable=SC2086
claude mcp add -s user mcp-review -- $RUN_CMD

# ── 3. Install the /iterate slash command globally ────────────────────────────

echo "→ Installing /iterate slash command..."
mkdir -p "$COMMAND_DIR"
cp "$COMMAND_FILE" "$COMMAND_DIR/iterate.md"

echo ""
echo "Done. Open a new Claude Code session and try /iterate."
echo "Make sure \$GUI_EDITOR is set (e.g. export GUI_EDITOR=\"code --wait\")."
