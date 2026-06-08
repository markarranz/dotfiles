local colors = require("themes.catppuccin-mocha")

local home = os.getenv("HOME") or ""
local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/run/user/1000"

local terminal = "kitty --single-instance"
local file_manager = "nautilus"
local menu = "nc -U " .. runtime_dir .. "/walker/walker.sock"
local browser = "firefox"
local focus_or_launch = home .. "/.config/hypr/scripts/focus-or-launch"

local function bind(keys, dispatcher, description, opts)
	opts = opts or {}

	if description then
		opts.description = description
	end

	return hl.bind(keys, dispatcher, opts)
end

hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- ashell")
	hl.exec_cmd("uwsm app -- walker --gapplication-service")
	hl.exec_cmd("uwsm app -- kitty --single-instance")
	hl.exec_cmd("uwsm app -- " .. home .. "/.config/hypr/scripts/discord-game-mode")
end)

hl.config({
	general = {
		border_size = 3,
		resize_on_border = true,
		allow_tearing = true,

		col = {
			active_border = {
				colors = { colors.pink, colors.sky },
				angle = 45,
			},
			inactive_border = colors.mantle,
		},

		layout = "dwindle",

		snap = {
			enabled = true,
		},
	},

	decoration = {
		rounding = 5,

		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = true,
	},

	misc = {
		disable_hyprland_logo = true,
	},

	render = {
		direct_scanout = 2,
	},

	debug = {
		full_cm_proto = true,
	},

	input = {
		kb_layout = "us",
		kb_options = "caps:escape_shifted_capslock",
		follow_mouse = 1,
		sensitivity = 0,
	},
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

hl.config({
	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},
})

require("hardware")

local main_mod = "SUPER"

bind(
	main_mod .. " + semicolon",
	hl.dsp.exec_cmd(focus_or_launch .. " kitty uwsm app -- " .. terminal),
	"Focus terminal"
)
bind(main_mod .. " + SHIFT + semicolon", hl.dsp.exec_cmd("uwsm app -- " .. terminal), "New terminal window")
bind(main_mod .. " + Space", hl.dsp.exec_cmd(menu), "Open app launcher")
bind(
	main_mod .. " + E",
	hl.dsp.exec_cmd(focus_or_launch .. " org.gnome.Nautilus uwsm app -- " .. file_manager),
	"Focus file manager"
)
bind(main_mod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm app -- " .. file_manager), "New file manager window")
bind(main_mod .. " + B", hl.dsp.exec_cmd(focus_or_launch .. " firefox uwsm app -- " .. browser), "Focus browser")
bind(main_mod .. " + SHIFT + B", hl.dsp.exec_cmd("uwsm app -- " .. browser), "New browser window")
bind(main_mod .. " + Q", hl.dsp.window.close(), "Close window")
bind(main_mod .. " + M", hl.dsp.exec_cmd("uwsm stop"), "Terminate session")
bind(main_mod .. " + Escape", hl.dsp.exec_cmd("hyprlock --immediate-render"), "Lock screen")
bind(main_mod .. " + SHIFT + Escape", hl.dsp.exec_cmd("systemctl sleep"), "Put system to sleep")

bind(main_mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }), "Toggle fullscreen")
bind(main_mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
bind(main_mod .. " + T", hl.dsp.layout("togglesplit"), "Toggle split")

bind(main_mod .. " + H", hl.dsp.focus({ direction = "left" }))
bind(main_mod .. " + J", hl.dsp.focus({ direction = "down" }))
bind(main_mod .. " + K", hl.dsp.focus({ direction = "up" }))
bind(main_mod .. " + L", hl.dsp.focus({ direction = "right" }))

bind(main_mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
bind(main_mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
bind(main_mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
bind(main_mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

bind(main_mod .. " + ALT + H", hl.dsp.focus({ workspace = "-1" }))
bind(main_mod .. " + ALT + L", hl.dsp.focus({ workspace = "+1" }))

for i = 1, 10 do
	local key = i % 10

	bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

bind(main_mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
bind(main_mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), nil, { mouse = true })
bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), nil, { mouse = true })

bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), nil, { locked = true, repeating = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), nil, { locked = true, repeating = true })
bind("SHIFT + XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +1%"), nil, { locked = true, repeating = true })
bind(
	"SHIFT + XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl set 1%-"),
	nil,
	{ locked = true, repeating = true }
)

bind(
	"XF86KbdBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl --device='smc::kbd_backlight' set +10%"),
	nil,
	{ locked = true, repeating = true }
)
bind(
	"XF86KbdBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl --device='smc::kbd_backlight' set 10%-"),
	nil,
	{ locked = true, repeating = true }
)
bind(
	"SHIFT + XF86KbdBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl --device='smc::kbd_backlight' set +5%"),
	nil,
	{ locked = true, repeating = true }
)
bind(
	"SHIFT + XF86KbdBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl --device='smc::kbd_backlight' set 5%-"),
	nil,
	{ locked = true, repeating = true }
)

bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	nil,
	{ locked = true, repeating = true }
)
bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	nil,
	{ locked = true, repeating = true }
)
bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), nil, { locked = true })
bind("SHIFT + XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), nil, { locked = true })

bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), nil, { locked = true })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), nil, { locked = true })
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), nil, { locked = true })
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), nil, { locked = true })

-------------------
---- MAKO BINDS ----
-------------------

-- Dismiss current notification
bind("SUPER + N", hl.dsp.exec_cmd("makoctl dismiss"))

-- Restore last notification
bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("makoctl restore"))

-- Dismiss all notifications
bind("SUPER + CTRL + N", hl.dsp.exec_cmd("makoctl dismiss --all"))

-- Invoke default notification action
bind("SUPER + ALT + N", hl.dsp.exec_cmd("makoctl invoke"))

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "float-bitwarden",
	match = { class = "Bitwarden" },
	float = true,
	size = "900 600",
})

hl.window_rule({
	name = "tearing-gamescope",
	match = { class = "^(gamescope)$" },
	immediate = true,
})

hl.window_rule({
	name = "gamescope-workspace",
	match = { class = "^(gamescope)$" },
	workspace = "10",
})
