# Claude Code

[Claude Code](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview) is Anthropic's official CLI tool for working with Claude directly from the terminal. It provides an agentic coding experience with file editing, command execution, and project-aware context.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview) CLI
- An Anthropic API key or active subscription

## Overview

### Settings (`modify_settings.json`)

A chezmoi [modify_ script](https://www.chezmoi.io/reference/source-state-attributes/#modify_-prefix) that deep-merges chezmoi-managed keys into the existing `settings.json` without clobbering user-added settings (plugins, preferences, etc.).

**Managed keys:**
- `statusLine` — custom bash status line (see below)
- `hooks.PreToolUse` — [RTK](https://github.com/rtk-ai/rtk) command rewrite hook (see below)

### Status Line (`status-line.sh`)

A custom bash script that renders a rich status line showing:

- Current model name
- Output style (if not default)
- Current directory
- Git branch with dirty/clean indicator
- PR number and link (cached with a 60-second TTL)
- Context window usage percentage (color-coded: green < 60%, yellow 60-80%, red > 80%)

All colors use the Catppuccin Mocha palette.

### RTK Hook (`hooks/rtk-rewrite.sh`)

A [PreToolUse hook](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/hooks) that transparently rewrites Bash commands through [RTK (Rust Token Killer)](https://github.com/rtk-ai/rtk) to compress CLI output before it enters the context window. Requires `rtk` to be installed (`brew install rtk`).
