local colors = require("colors")
local icons = require("icons")

_ = sbar.add("item", "apple", {
	icon = {
		font = { size = 16.0 },
		string = icons.apple,
		padding_right = 12,
		padding_left = 12,
	},
	label = { drawing = false },
	background = {
		color = colors.bg1,
	},
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})
