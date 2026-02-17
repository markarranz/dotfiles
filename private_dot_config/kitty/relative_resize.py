# Kitty kitten for relative window resizing.
# Based on MIT licensed code at https://github.com/chancez/dotfiles
from kittens.tui.handler import result_handler


def main(args):
    pass


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
    direction = args[1]
    amount = int(args[2])
    relative_resize_window(direction, amount, target_window_id, boss)
