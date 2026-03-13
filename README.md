# mcp-review

Human-in-the-loop review for Claude Code. Use `/iterate` after any Claude
response to open it in your editor, annotate with `# TODO:` comments, and
have Claude iterate until you're satisfied.

## Install

```bash
git clone https://github.com/olegs/mcp-review
cd mcp-review
./install.sh                                 # defaults to VS Code
./install.sh --editor "zed --wait"           # or any other GUI editor
```

Or with `uvx` (no clone needed):

```bash
# Install the slash command
mkdir -p ~/.claude/commands
curl -o ~/.claude/commands/iterate.md \
  https://raw.githubusercontent.com/olegs/mcp-review/main/.claude/commands/iterate.md

# Register the MCP server (bakes your editor into the server config)
claude mcp add -s user -e "GUI_EDITOR=code --wait" mcp-review -- uvx mcp-review
```

## Setup

Make sure `$GUI_EDITOR` is set in your shell to a GUI editor that blocks until
the file is closed. Terminal editors (vim, nano) don't work because Claude Code's
TUI rendering conflicts with them.

```bash
export GUI_EDITOR="code --wait"      # VS Code
export GUI_EDITOR="emacsclient -c"   # Emacs (GUI frame)
export GUI_EDITOR="mvim --nofork"    # MacVim
export GUI_EDITOR="subl --wait"      # Sublime Text
export GUI_EDITOR="zed --wait"       # Zed
```

## Usage

1. Ask Claude anything — get a plan, analysis, code review, etc.
2. Type `/iterate`
3. Your editor opens with Claude's response
4. Add `# TODO: <comment>` on any line you want addressed
5. Save and close
6. Claude revises and reopens — repeat until no TODOs remain

## Uninstall

```bash
claude mcp remove mcp-review
rm ~/.claude/commands/iterate.md
```
