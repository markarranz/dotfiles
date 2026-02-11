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
