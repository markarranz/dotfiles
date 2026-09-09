---
name: open-nvim
description: Open a Neovim session running in the same kitty tab to a discussed file path and optional line or column. Use when the user invokes $open-nvim, asks to open/jump/show referenced code in Neovim, or wants the active editor navigated to a mentioned code location.
---

# Open Neovim

## Overview

Open the existing Neovim window in the same kitty tab to the code currently being discussed. This skill is for navigation only; do not edit files unless the user separately asks for edits.

## Workflow

1. Identify the target file and optional line/column from the conversation, selected text, error output, stack trace, diff, or code reference.
2. Prefer an absolute path. If the user or prior assistant message only mentions a relative path, resolve it from the current workspace or the repo/worktree being discussed.
3. If the target file is ambiguous, ask a short clarification instead of guessing.
4. Run the helper from this skill's base directory (the "Base directory for this skill" provided when the skill is invoked):

```bash
python3 <skill-base-dir>/scripts/open_nvim.py --file /absolute/path/to/file.go --line 123
```

Omit `--line` when no line number is applicable. Use `--column` only when the discussion has a precise column.

## Handling Kitty Windows

The helper uses `kitty @ ls` to find Neovim-looking windows in the same kitty tab as the agent, then sends an Ex command to that window. If `KITTY_WINDOW_ID` is missing or no longer exists, the helper lists tabs, windows, and working directories and stops. Focus and layout history are not reliable evidence of the session's tab.

Inspect `kitty @ ls` and match the tab and foreground Neovim working directory to the worktree being discussed. Use `--window-id <id>` to target that editor directly, even if automatic tab detection fails. If the intended tab has no editor, use `--tab-id <id>` to select it explicitly. Ask the user only when the metadata leaves the target ambiguous. Reuse the verified editor ID for subsequent walkthrough steps.

If multiple Neovim windows are found in the selected tab, the helper prints candidate IDs instead of choosing one.

If no Neovim window is found in the tab, the helper launches a new kitty window in the same tab running `nvim` at the requested file/line and reports the new window id. Pass `--no-launch` to fail instead of launching.

If `KITTY_LISTEN_ON` points to a missing socket, inspect available Kitty sockets and their window metadata before retrying with a corrected address. Do not infer the target tab from the replacement socket or Kitty's `is_self` field. If remote control remains unavailable, report that directly and include the target file/line.

## Examples

Explicit path and line:

```bash
python3 <skill-base-dir>/scripts/open_nvim.py --file /absolute/path/to/project/file.go --line 42
```

Multiple Neovim windows:

```bash
python3 <skill-base-dir>/scripts/open_nvim.py --window-id 7 --file /absolute/path/to/project/file.go --line 42
```
