# Kitty kitten for relative window resizing.
# When IS_NVIM user variable is set, passes the key through to neovim instead.
# Based on MIT licensed code at https://github.com/chancez/dotfiles
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


def relative_resize_window(direction, amount, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    neighbors = boss.active_tab.current_layout.neighbors_for_window(
        window, boss.active_tab.windows
    )

    left_neighbors = neighbors.get("left")
    right_neighbors = neighbors.get("right")
    top_neighbors = neighbors.get("top")
    bottom_neighbors = neighbors.get("bottom")

    if direction == "left" and (left_neighbors and right_neighbors):
        boss.active_tab.resize_window("narrower", amount)
    elif direction == "left" and left_neighbors:
        boss.active_tab.resize_window("wider", amount)
    elif direction == "left" and right_neighbors:
        boss.active_tab.resize_window("narrower", amount)

    elif direction == "right" and (left_neighbors and right_neighbors):
        boss.active_tab.resize_window("wider", amount)
    elif direction == "right" and left_neighbors:
        boss.active_tab.resize_window("narrower", amount)
    elif direction == "right" and right_neighbors:
        boss.active_tab.resize_window("wider", amount)

    elif direction == "up" and (top_neighbors and bottom_neighbors):
        boss.active_tab.resize_window("shorter", amount)
    elif direction == "up" and top_neighbors:
        boss.active_tab.resize_window("taller", amount)
    elif direction == "up" and bottom_neighbors:
        boss.active_tab.resize_window("shorter", amount)

    elif direction == "down" and (top_neighbors and bottom_neighbors):
        boss.active_tab.resize_window("taller", amount)
    elif direction == "down" and top_neighbors:
        boss.active_tab.resize_window("shorter", amount)
    elif direction == "down" and bottom_neighbors:
        boss.active_tab.resize_window("taller", amount)


@result_handler(no_ui=True)
def handle_result(args, result, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    # Pass key through to neovim when IS_NVIM is set
    if window.user_vars.get("IS_NVIM"):
        encoded = encode_key_mapping(window, args[3])
        window.write_to_child(encoded)
        return

    direction = args[1]
    amount = int(args[2])
    relative_resize_window(direction, amount, target_window_id, boss)
