# Claude Code

[Claude Code](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview) is Anthropic's official CLI tool for working with Claude directly from the terminal. It provides an agentic coding experience with file editing, command execution, and project-aware context.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview) CLI
- An Anthropic API key or active subscription

## Overview

### Settings (`settings.json`)

- **Model:** Opus
- **Status line:** Custom bash script (see below)
- **Plugins:** 30+ official plugins enabled, including code review, language-specific LSPs (TypeScript, Python, Go, Swift, Lua, Kotlin), security guidance, and service integrations (Figma, Notion, Stripe, Sentry)

### Status Line (`status-line.sh`)

A custom bash script that renders a rich status line showing:

- Current model name
- Output style (if not default)
- Current directory
- Git branch with dirty/clean indicator
- PR number and link (cached with a 60-second TTL)
- Context window usage percentage (color-coded: green < 60%, yellow 60-80%, red > 80%)

All colors use the Catppuccin Mocha palette.

### Notification Hook (`hooks/executable_notify.sh`)

Kitty-native desktop notification using the OSC 99 protocol. Clicking the
notification focuses the exact originating tab, split, and OS window automatically.

OpenCode plugin notifications also route through this script (`NOTIFY_SOURCE=opencode`)
so Claude and OpenCode share the same notifier.

- Accepts JSON on stdin or as `$1`: `{ "message", "title", "kitty_window_id", "kitty_listen_on" }`
- Falls back to `KITTY_WINDOW_ID` / `KITTY_LISTEN_ON` env vars
- Requires: `kitty` with `allow_remote_control yes` and a listen socket

Environment controls:

- `NOTIFY_DEFAULT_TITLE="Claude Code"`
- `NOTIFY_TITLE_PREFIX="[dev] "`
- `NOTIFY_KITTY_BIN=/path/to/kitty` (optional explicit binary path)
- `NOTIFY_SOURCE=claude|opencode` (controls duplicate suppression)
- `NOTIFY_OPENCODE_SUPPRESS_DUPES=1`
- `NOTIFY_OPENCODE_SUPPRESS_FILE=/tmp/opencode-notify-last.json`
- `NOTIFY_OPENCODE_SUPPRESS_WINDOW_SEC=5`
- `NOTIFY_DRY_RUN=1` (prints resolved payload to stderr without sending)
- `NOTIFY_DISABLE=1` (fully disable)

Quick local test:

```bash
NOTIFY_DRY_RUN=1 ./hooks/executable_notify.sh '{"message":"Build finished","title":"CI"}'
```
