local colors = require("config.colors")
local icons = require("config.icons")
local settings = require("config.settings")

sbar.add("event", "yabai_layout_change")

local layout = sbar.add("item", "yabai_layout", {
	display = "active",
	icon = {
		string = icons.yabai.grid,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
		color = colors.white,
	},
	label = { drawing = false },
	padding_left = 6,
	padding_right = 2,
	background = { drawing = false },
})

local function update_layout()
	sbar.exec("yabai -m query --spaces --space | jq -r '.type'", function(result)
		local layout_type = result:gsub("%s+$", "")
		local icon = layout_type == "stack" and icons.yabai.stack or icons.yabai.grid
		local color = layout_type == "stack" and colors.yellow or colors.white
		layout:set({ icon = { string = icon, color = color } })
	end)
end

layout:subscribe("space_change", update_layout)
layout:subscribe("front_app_switched", update_layout)
layout:subscribe("yabai_layout_change", update_layout)
layout:subscribe("mouse.clicked", function()
	sbar.exec('yabai -m space --layout "$([ "$(yabai -m query --spaces --space | jq -r \'.type\')" = bsp ] && echo stack || echo bsp)"')
	update_layout()
end)

update_layout()
