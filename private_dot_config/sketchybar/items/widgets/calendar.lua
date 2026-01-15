local colors = require("config.colors")
local settings = require("config.settings")

local cal = sbar.add("item", "calendar", {
	position = "right",
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
		padding_right = 0,
	},
	label = {
		width = 70,
		align = "right",
	},
	padding_left = 15,
	update_freq = 15,
})

-- Set script via CLI since SBarLua doesn't support script property directly
sbar.exec("sketchybar --set calendar script='~/.config/sketchybar/plugins/calendar.sh'")

-- Zen mode toggle function
local zen_mode_on = false

local function toggle_zen()
	zen_mode_on = not zen_mode_on
	local drawing = zen_mode_on and "off" or "on"

	sbar.exec([[
    sketchybar --set wifi drawing=]] .. drawing .. [[ \
               --set apple.logo drawing=]] .. drawing .. [[ \
               --set '/cpu.*/' drawing=]] .. drawing .. [[ \
               --set calendar icon.drawing=]] .. (zen_mode_on and "off" or "on") .. [[ \
               --set front_app drawing=]] .. drawing .. [[ \
               --set volume_icon drawing=]] .. drawing .. [[ \
               --set brew drawing=]] .. drawing .. [[ \
               --set volume drawing=]] .. drawing .. [[ \
               --set github.bell drawing=]] .. drawing)
end

cal:subscribe("system_woke", function(env)
	sbar.exec("sketchybar --set calendar icon=\"$(date '+%a, %d %b')\" label=\"$(date '+%I:%M %p')\"")
end)

cal:subscribe("mouse.clicked", function(env)
	toggle_zen()
end)
