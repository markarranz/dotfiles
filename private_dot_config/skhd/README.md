# skhd

[skhd](https://github.com/koekeishiya/skhd) is a simple hotkey daemon for macOS. It listens for keyboard shortcuts globally and triggers actions like launching apps, focusing windows, or sending commands to yabai. It acts as the keybinding layer for the yabai window manager.

## Prerequisites

- [skhd](https://github.com/koekeishiya/skhd)
- [yabai](https://github.com/koekeishiya/yabai) -- most keybindings send commands to yabai
- [Kitty](https://sw.kovidgoyal.net/kitty/) -- default terminal
- [Firefox](https://www.mozilla.org/firefox/) -- default browser (or Chrome on work machines)

## Key Bindings

### Application Launchers

| Binding       | Action                                        |
| ------------- | --------------------------------------------- |
| `Cmd+;`       | Open / focus Kitty                            |
| `Cmd+Shift+;` | New Kitty window                              |
| `Cmd+b`       | Open / focus browser                          |
| `Cmd+Shift+b` | New browser window                            |
| `Cmd+e`       | Open Finder                                   |

### Space Navigation

| Binding               | Action                                |
| --------------------- | ------------------------------------- |
| `Cmd+Alt+Tab`         | Toggle to recent space                |
| `Ctrl+Alt+h` / `l`   | Previous / next space (wraps across displays) |
| `Cmd+1-9, 0`          | Focus space (creates it if needed)    |
| `Cmd+Alt+h` / `l`     | Focus left / right display            |
| `Cmd+Alt+Shift+h / l` | Move space to left / right display    |
| `Ctrl+Alt+Shift+h` / `l` | Move window to prev / next space      |
| `Cmd+Alt+r`           | Rotate tree clockwise                 |
| `Cmd+Alt+u`           | Rotate tree counter-clockwise         |
| `Cmd+Alt+\\`          | Mirror tree (y-axis)                  |
| `Cmd+Alt+-`           | Mirror tree (x-axis)                  |
| `Alt+s`               | Toggle layout (bsp / stack)           |

### Window Management

| Binding               | Action                                |
| --------------------- | ------------------------------------- |
| `Cmd+h/j/k/l`        | Focus window west/south/north/east    |
| `Cmd+Shift+h/j/k/l`  | Move (warp) window                    |
| `Cmd+Shift+1-9, 0`   | Send window to space                  |
| `Cmd+Shift+f`         | Toggle native fullscreen              |
| `Cmd+Alt+f`           | Toggle float (centered grid)          |
| `Cmd+Alt+p`           | Toggle picture-in-picture             |
| `Alt+t`               | Toggle split direction                |
| `Alt+p`               | Toggle sticky (window on all spaces)  |

### System

| Binding       | Action         |
| ------------- | -------------- |
| `Hyper+r`     | Restart yabai  |
| `Hyper+m`     | Toggle mic     |

### Blacklisted Applications

Keybindings are disabled in Microsoft Excel and Microsoft Word to avoid conflicts with their built-in shortcuts.
