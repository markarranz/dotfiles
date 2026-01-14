local colors = require("colors")
local settings = require("settings")

local front_app = sbar.add("item", "front_app", {
	display = "active",
	icon = {
		background = { drawing = true },
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
	},
	updates = true,
	click_script = "open -a 'Mission Control'",
})

front_app:subscribe("front_app_switched", function(env)
	front_app:set({
		label = { string = env.INFO },
		icon = { background = { image = "app." .. env.INFO } },
	})
end)
