# Kitty kitten for visual-position-based window navigation.
# When IS_NVIM user variable is set, passes the key through to neovim instead.
# Uses window geometry to find the nearest neighbor in a direction, avoiding
# the split-tree ordering issues of kitty's built-in neighboring_window.
#
# Usage from kitty.conf keymap:
#   kitten navigate.py <direction> <key_mapping>
#
# Usage from neovim's navigate.lua (via remote control):
#   kitty @ action kitten navigate.py --no-passthrough <direction>
from kitty.key_encoding import KeyEvent, parse_shortcut
from kittens.tui.handler import result_handler


def main(args):
    pass


def encode_key_mapping(window, key_mapping):
    mods, key = parse_shortcut(key_mapping)
    event = KeyEvent(
        mods=mods,
        key=key,
        shift=bool(mods & 1),
        alt=bool(mods & 2),
        ctrl=bool(mods & 4),
        super=bool(mods & 8),
        hyper=bool(mods & 16),
        meta=bool(mods & 32),
    ).as_window_system_event()
    return window.encoded_key(event)


def find_neighbor_window(direction, active, boss):
    tab = boss.active_tab
    if tab is None:
        return None

    ag = active.geometry
    a_cx = (ag.left + ag.right) / 2
    a_cy = (ag.top + ag.bottom) / 2

    best = None
    best_dist = float('inf')

    for window in tab.windows:
        if window.id == active.id:
            continue
        wg = window.geometry
        w_cx = (wg.left + wg.right) / 2
        w_cy = (wg.top + wg.bottom) / 2

        if direction in ('down', 'up'):
            # Must overlap horizontally
            if min(ag.right, wg.right) <= max(ag.left, wg.left):
                continue
            if direction == 'down' and w_cy <= a_cy:
                continue
            if direction == 'up' and w_cy >= a_cy:
                continue
            dist = abs(w_cy - a_cy)
        else:
            # Must overlap vertically
            if min(ag.bottom, wg.bottom) <= max(ag.top, wg.top):
                continue
            if direction == 'right' and w_cx <= a_cx:
                continue
            if direction == 'left' and w_cx >= a_cx:
                continue
            dist = abs(w_cx - a_cx)

        if dist < best_dist:
            best = window
            best_dist = dist

    return best


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    # --no-passthrough: called from neovim via kitty @ action, skip IS_NVIM check
    if args[1] == '--no-passthrough':
        direction = args[2]
    else:
        # Called from keymap: pass key through to neovim when IS_NVIM is set
        if window.user_vars.get("IS_NVIM"):
            encoded = encode_key_mapping(window, args[2])
            window.write_to_child(encoded)
            return
        direction = args[1]

    neighbor = find_neighbor_window(direction, window, boss)
    if neighbor is not None:
        boss.active_tab.set_active_window(neighbor)
