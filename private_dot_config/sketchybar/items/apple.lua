local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local popup_toggle = "sketchybar --set $NAME popup.drawing=toggle"

local apple_logo = sbar.add("item", "apple.logo", {
	padding_right = 15,
	click_script = popup_toggle,
	icon = {
		string = icons.apple,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Black"],
			size = 16.0,
		},
		color = colors.green,
	},
	label = { drawing = false },
	popup = { height = 35 },
})

local apple_prefs = sbar.add("item", "apple.prefs", {
	position = "popup." .. apple_logo.name,
	icon = icons.preferences,
	label = "Preferences",
})

apple_prefs:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'System Preferences'")
	apple_logo:set({ popup = { drawing = false } })
end)

local apple_activity = sbar.add("item", "apple.activity", {
	position = "popup." .. apple_logo.name,
	icon = icons.activity,
	label = "Activity",
})

apple_activity:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
	apple_logo:set({ popup = { drawing = false } })
end)

local apple_lock = sbar.add("item", "apple.lock", {
	position = "popup." .. apple_logo.name,
	icon = icons.lock,
	label = "Lock Screen",
})

apple_lock:subscribe("mouse.clicked", function(env)
	sbar.exec("pmset displaysleepnow")
	apple_logo:set({ popup = { drawing = false } })
end)
