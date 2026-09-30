#!/usr/bin/env python3
import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def query(*args):
    return json.loads(subprocess.check_output(
        ["yabai", "-m", "query", *args], stderr=subprocess.DEVNULL
    ))


def eligible(window):
    return (window.get("role") == "AXWindow"
            and window.get("subrole") == "AXStandardWindow"
            and window.get("has-ax-reference") is True
            and not window.get("is-minimized")
            and not window.get("is-hidden")
            and not window.get("is-sticky"))


def identity(window):
    return {key: window[key] for key in ("id", "pid", "app")}


def run(mode, target=None):
    directory = Path(tempfile.gettempdir()) / f"yabai-focus-history-{os.getuid()}"
    directory.mkdir(mode=0o700, exist_ok=True)
    with (directory / "lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        path = directory / "history.json"
        try:
            history = json.loads(path.read_text())
        except (FileNotFoundError, ValueError):
            history = {}
        if mode == "remember":
            window = query("--windows", "--window")
            if not eligible(window) or not window.get("has-focus"):
                return
            space = query("--spaces", "--space", str(window["space"]))
            # Signals can arrive late; never record a window that lost focus.
            current = query("--windows", "--window")
            if (not current.get("has-focus") or identity(current) != identity(window)
                    or current["space"] != window["space"]):
                return
            space_uuids = {s["uuid"] for s in query("--spaces")}
            history = {key: value for key, value in history.items()
                       if key in space_uuids}
            history[space["uuid"]] = identity(window)
            temporary = directory / "history.tmp"
            temporary.write_text(json.dumps(history))
            temporary.replace(path)
        elif mode == "preferred":
            space = query("--spaces", "--space", target)
            saved = history.get(space["uuid"])
            for window in query("--windows", "--space", str(space["index"])):
                if eligible(window) and identity(window) == saved:
                    print(window["id"])
                    return


if __name__ == "__main__":
    try:
        run(*sys.argv[1:])
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError):
        sys.exit(0)
