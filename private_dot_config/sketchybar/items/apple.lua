local colors = require("config.colors")
local icons = require("config.icons")
local settings = require("config.settings")
local item_utils = require("helpers.item_utils")

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

local popup_actions = {
	{ name = "apple.prefs", icon = icons.preferences, label = "Preferences", command = "open -a 'System Preferences'" },
	{ name = "apple.activity", icon = icons.activity, label = "Activity", command = "open -a 'Activity Monitor'" },
	{ name = "apple.lock", icon = icons.lock, label = "Lock Screen", command = "pmset displaysleepnow" },
}

for _, action in ipairs(popup_actions) do
	item_utils.create_popup_action(apple_logo, action.name, action.icon, action.label, action.command)
end
