# mcp-review

Human-in-the-loop review for Claude Code. Use `/review` after any Claude
response to open it in your editor, annotate with `# TODO:` comments, and
have Claude iterate until you're satisfied.

## Install

```bash
git clone https://github.com/olegs/mcp-review
cd mcp-review
./install.sh
```

Or with `uvx` (no clone needed):

```bash
# Install the slash command
mkdir -p ~/.claude/commands
curl -o ~/.claude/commands/review.md \
  https://raw.githubusercontent.com/olegs/mcp-review/main/.claude/commands/review.md

# Register the MCP server
claude mcp add -s user mcp-review -- uvx mcp-review
```

## Setup

Make sure `$EDITOR` is set in your shell:

```bash
export EDITOR="code --wait"   # VS Code
export EDITOR="emacsclient"   # Emacs
export EDITOR="vim"           # Vim
```

## Usage

1. Ask Claude anything — get a plan, analysis, code review, etc.
2. Type `/review`
3. Your editor opens with Claude's response
4. Add `# TODO: <comment>` on any line you want addressed
5. Save and close
6. Claude revises and reopens — repeat until no TODOs remain

## Uninstall

```bash
claude mcp remove mcp-review
rm ~/.claude/commands/review.md
```
