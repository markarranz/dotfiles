#!/usr/bin/env python3
import argparse
import json
import os
import pathlib
import re
import subprocess
import sys


NVIM_NAMES = {"nvim", "vim", "view"}


def run(cmd, input_text=None):
    return subprocess.run(
        cmd,
        input=input_text,
        capture_output=True,
        check=True,
        text=True,
    )


def kitty_ls():
    try:
        result = run(["kitty", "@", "ls"])
    except FileNotFoundError:
        raise SystemExit("kitty executable not found")
    except subprocess.CalledProcessError as exc:
        msg = exc.stderr.strip() or exc.stdout.strip() or str(exc)
        raise SystemExit(f"kitty remote control failed: {msg}")

    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"failed to parse `kitty @ ls` JSON: {exc}")


def window_id(window):
    return str(window.get("id", ""))


def foreground_cmd(window):
    processes = window.get("foreground_processes") or []
    if not processes:
        return []
    return processes[-1].get("cmdline") or []


def window_title(window):
    return window.get("title") or window.get("cwd") or ""


def is_neovim_window(window):
    cmd = foreground_cmd(window)
    if cmd:
        name = pathlib.Path(cmd[0]).name
        if name in NVIM_NAMES or name.endswith("nvim"):
            return True
    title = window_title(window).lower()
    return "nvim" in title or re.search(r"\bvim\b", title) is not None


def active_window_id(tab):
    for window in tab.get("windows", []):
        if window.get("is_active"):
            return window_id(window)
    for candidate_id in tab.get("active_window_history", []):
        for window in tab.get("windows", []):
            if window_id(window) == str(candidate_id):
                return window_id(window)
    windows = tab.get("windows", [])
    return window_id(windows[0]) if windows else ""


def find_current_tab(tree, requested_window=None, requested_tab=None):
    tabs = [tab for os_window in tree for tab in os_window.get("tabs", [])]
    if requested_window:
        for tab in tabs:
            if any(window_id(w) == str(requested_window) for w in tab.get("windows", [])):
                if requested_tab and str(tab.get("id")) != str(requested_tab):
                    raise SystemExit("requested window is not in the requested tab")
                return tab, ""
        raise SystemExit(f"kitty window id {requested_window} not found")
    if requested_tab:
        for tab in tabs:
            if str(tab.get("id")) == str(requested_tab):
                return tab, ""
        raise SystemExit(f"kitty tab id {requested_tab} not found")

    current_id = os.environ.get("KITTY_WINDOW_ID", "")
    for tab in tabs:
        if any(window_id(w) == current_id for w in tab.get("windows", [])):
            return tab, current_id

    # Focus and layout history do not establish which tab owns this session.
    print("cannot identify this session's kitty tab; choose --window-id or --tab-id:", file=sys.stderr)
    for tab in tabs:
        print(f"  tab {tab.get('id')}\t{tab.get('title', '')}", file=sys.stderr)
        for window in tab.get("windows", []):
            processes = window.get("foreground_processes") or []
            cwd = next((p.get("cwd") for p in reversed(processes) if p.get("cwd")), window.get("cwd", ""))
            print(f"    window {window_id(window)}\t{window_title(window)}\t{cwd}", file=sys.stderr)
    raise SystemExit(2)


def nvim_candidates(tab, current_id):
    out = []
    for window in tab.get("windows", []):
        if window_id(window) == current_id:
            continue
        if is_neovim_window(window):
            out.append(window)
    return out


def pick_window(tab, current_id, requested_id):
    if requested_id:
        for window in tab.get("windows", []):
            if window_id(window) == str(requested_id):
                if not is_neovim_window(window):
                    raise SystemExit(f"kitty window id {requested_id} does not look like Neovim")
                return window
        raise SystemExit(f"kitty window id {requested_id} not found in the current tab")

    candidates = nvim_candidates(tab, current_id)
    if len(candidates) == 1:
        return candidates[0]

    if not candidates:
        return None

    print("multiple Neovim-looking kitty windows found; rerun with --window-id:", file=sys.stderr)
    for window in candidates:
        print(
            f"  {window_id(window)}\t{window_title(window)}\t{' '.join(foreground_cmd(window))}",
            file=sys.stderr,
        )
    raise SystemExit(2)


def launch_nvim_window(current_id, path, line=None, column=None):
    cmd = ["kitty", "@", "launch", "--type=window", "--cwd=current", "--match", f"window_id:{current_id}", "--source-window", f"id:{current_id}", "nvim"]
    if line and column:
        cmd.append(f"+call cursor({line}, {column})")
    elif line:
        cmd.append(f"+{line}")
    cmd.append(str(path))
    try:
        result = run(cmd)
    except subprocess.CalledProcessError as exc:
        msg = exc.stderr.strip() or exc.stdout.strip() or str(exc)
        raise SystemExit(f"no Neovim window found and launching one failed: {msg}")
    return result.stdout.strip()


def vim_fnameescape(path):
    return re.sub(r'([ \\%\#\|"<>])', r"\\\1", str(path))


def edit_command(path, line=None, column=None):
    escaped_path = vim_fnameescape(path)
    plus = f" +{line}" if line else ""
    command = f"\x1b:edit{plus} {escaped_path}\r"
    if line and column:
        command += f":call cursor({line}, {column})\r"
    return command


def send_to_window(window_id_value, text):
    try:
        run(["kitty", "@", "send-text", "--match", f"id:{window_id_value}", "--stdin"], input_text=text)
    except subprocess.CalledProcessError as exc:
        msg = exc.stderr.strip() or exc.stdout.strip() or str(exc)
        raise SystemExit(f"failed to send command to kitty window {window_id_value}: {msg}")


def positive_int(value):
    parsed = int(value)
    if parsed < 1:
        raise argparse.ArgumentTypeError("must be >= 1")
    return parsed


def main():
    parser = argparse.ArgumentParser(description="Open a same-tab kitty Neovim window to a file and optional line.")
    parser.add_argument("--file", required=True, help="Absolute or resolvable path to open in Neovim.")
    parser.add_argument("--line", type=positive_int, help="Optional 1-based line number.")
    parser.add_argument("--column", type=positive_int, help="Optional 1-based column number.")
    parser.add_argument("--window-id", help="Explicit Neovim window id; bypasses automatic tab detection.")
    parser.add_argument("--tab-id", help="Explicit tab id for editor selection or launch.")
    parser.add_argument(
        "--no-launch",
        action="store_true",
        help="Fail instead of launching a new Neovim window when none is found.",
    )
    args = parser.parse_args()

    path = pathlib.Path(args.file).expanduser()
    if not path.is_absolute():
        path = pathlib.Path.cwd() / path
    path = path.resolve()

    if not path.exists():
        raise SystemExit(f"file does not exist: {path}")
    if args.column and not args.line:
        raise SystemExit("--column requires --line")

    tab, current_id = find_current_tab(kitty_ls(), args.window_id, args.tab_id)
    target = pick_window(tab, current_id, args.window_id)

    suffix = f":{args.line}" if args.line else ""
    if args.column:
        suffix += f":{args.column}"

    if target is None:
        if args.no_launch:
            raise SystemExit("no Neovim-looking kitty window found in the current tab")
        anchor_id = current_id or active_window_id(tab)
        if not anchor_id:
            raise SystemExit("current kitty tab has no window to launch Neovim beside")
        new_id = launch_nvim_window(anchor_id, path, args.line, args.column)
        print(f"opened {path}{suffix} in new kitty window {new_id}")
        return

    target_id = window_id(target)
    send_to_window(target_id, edit_command(path, args.line, args.column))
    print(f"opened {path}{suffix} in kitty window {target_id}")


if __name__ == "__main__":
    main()
