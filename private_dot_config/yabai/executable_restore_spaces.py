#!/usr/bin/env python3
# pyright: reportUnknownVariableType=false, reportUnknownMemberType=false, reportUnknownArgumentType=false

import fcntl
import json
import os
import subprocess
import sys
import time

LOCKFILE = "/tmp/yabai_display_transition"
LABELS = ["chat", "code", "docs"]
POLL_INTERVAL_SECONDS = 0.5
POLL_TIMEOUT_SECONDS = 30
YABAI_TIMEOUT_SECONDS = 5


def log(message: str) -> None:
    print(message, file=sys.stderr)


def to_dict_list(data: object) -> list[dict[str, object]] | None:
    if not isinstance(data, list):
        return None
    return [item for item in data if isinstance(item, dict)]


def run_yabai_json(args: list[str]) -> list[dict[str, object]] | None:
    try:
        result = subprocess.run(
            ["yabai", "-m", *args],
            capture_output=True,
            text=True,
            timeout=YABAI_TIMEOUT_SECONDS,
        )
    except subprocess.TimeoutExpired:
        log(f"restore_spaces: yabai timeout running: yabai -m {' '.join(args)}")
        return None
    if result.returncode != 0:
        log(f"restore_spaces: yabai -m {' '.join(args)} failed: {result.stderr.strip()}")
        return None
    try:
        data: object = json.loads(result.stdout)  # pyright: ignore[reportAny]
    except json.JSONDecodeError:
        return None
    return to_dict_list(data)


def run_yabai_cmd(args: list[str]) -> bool:
    try:
        result = subprocess.run(
            ["yabai", "-m", *args],
            capture_output=True,
            text=True,
            timeout=YABAI_TIMEOUT_SECONDS,
        )
    except subprocess.TimeoutExpired:
        log(f"restore_spaces: yabai timeout running: yabai -m {' '.join(args)}")
        return False
    if result.returncode != 0:
        log(f"restore_spaces: yabai -m {' '.join(args)} failed: {result.stderr.strip()}")
    return result.returncode == 0


def get_index(d: dict[str, object]) -> int:
    value = d.get("index")
    return value if isinstance(value, int) else 0


def space_label(space: dict[str, object]) -> str:
    value = space.get("label")
    return value if isinstance(value, str) else ""


def display_frame_x(display: dict[str, object]) -> float:
    frame = display.get("frame")
    if isinstance(frame, dict):
        x = frame.get("x")
        if isinstance(x, (int, float)):
            return float(x)
    return 0.0


def wait_for_yabai() -> tuple[
    list[dict[str, object]] | None, list[dict[str, object]] | None
]:
    log("restore_spaces: waiting for yabai...")
    deadline = time.monotonic() + POLL_TIMEOUT_SECONDS
    while time.monotonic() < deadline:
        spaces = run_yabai_json(["query", "--spaces"])
        if spaces is not None:
            displays = run_yabai_json(["query", "--displays"])
            if displays is not None and len(displays) >= 1:
                return spaces, displays
        time.sleep(POLL_INTERVAL_SECONDS)
    return None, None


def is_already_labeled(spaces: list[dict[str, object]]) -> bool:
    ordered = sorted(spaces, key=get_index)
    labeled = [space for space in ordered if space_label(space)]
    labels = [space_label(space) for space in labeled]
    return len(labeled) == len(LABELS) and labels == LABELS


def ordered_space_indices(displays: list[dict[str, object]]) -> list[int] | None:
    display_indices = [
        get_index(display) for display in sorted(displays, key=display_frame_x)
    ]
    space_indices: list[int] = []
    for display_idx in display_indices:
        display_spaces = run_yabai_json(
            ["query", "--spaces", "--display", str(display_idx)]
        )
        if display_spaces is None:
            return None
        for space in sorted(display_spaces, key=get_index):
            idx = get_index(space)
            if idx > 0:
                space_indices.append(idx)
    return space_indices


def main() -> int:
    with open(LOCKFILE, "a") as lock_handle:
        try:
            fcntl.flock(lock_handle.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            log("restore_spaces: another instance is running, exiting")
            return 0

        try:
            spaces, displays = wait_for_yabai()
            if spaces is None or displays is None:
                log("restore_spaces: timeout waiting for yabai after 30s")
                return 1

            log(
                f"restore_spaces: yabai ready, {len(spaces)} spaces on {len(displays)} displays"
            )

            if is_already_labeled(spaces):
                log("restore_spaces: spaces already correctly labeled, skipping")
                return 0

            current_count = len(spaces)
            missing = max(0, len(LABELS) - current_count)
            if missing > 0:
                log(f"restore_spaces: creating {missing} missing spaces")
                for _ in range(current_count + 1, len(LABELS) + 1):
                    if not run_yabai_cmd(["space", "--create"]):
                        log("restore_spaces: failed to create space")
                        return 1

            refreshed_displays = run_yabai_json(["query", "--displays"])
            if refreshed_displays is None:
                log("restore_spaces: failed to query displays after space creation")
                return 1
            space_indices = ordered_space_indices(refreshed_displays)
            if space_indices is None or len(space_indices) < len(LABELS):
                log("restore_spaces: not enough space indices for labeling")
                return 1

            labeled_pairs: list[str] = []
            for label, idx in zip(LABELS, space_indices[: len(LABELS)]):
                if not run_yabai_cmd(["space", str(idx), "--label", label]):
                    log(f"restore_spaces: failed to label space {idx} as {label}")
                    return 1
                labeled_pairs.append(f"{label}={idx}")

            log(f"restore_spaces: labeled spaces: {', '.join(labeled_pairs)}")
            return 0
        finally:
            try:
                os.unlink(LOCKFILE)
            except OSError:
                pass


if __name__ == "__main__":
    sys.exit(main())
