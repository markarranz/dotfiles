local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local volume = sbar.add("item", "widgets.volume", {
	position = "right",
	background = {
		color = colors.bg1,
	},
	icon = {
		padding_left = 12,
		color = colors.white,
		font = {
			style = settings.font.style_map["Regular"],
		},
	},
	label = {
		padding_right = 12,
		font = { family = settings.font.numbers },
	},
})

volume:subscribe("volume_change", function(env)
	local level = tonumber(env.INFO)
	local icon = icons.volume._0
	local color = colors.red

	if level > 60 then
		icon = icons.volume._100
	elseif level > 30 then
		icon = icons.volume._66
	elseif level > 10 then
		icon = icons.volume._33
	elseif level > 0 then
		icon = icons.volume._10
	end

	local lead = ""
	if level < 10 then
		lead = "0"
	end

	volume:set({
		icon = icon,
		label = lead .. level .. "%",
	})
end)
