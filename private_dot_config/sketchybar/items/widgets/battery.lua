local colors = require("config.colors")
local icons = require("config.icons")
local settings = require("config.settings")

local battery = sbar.add("item", "battery", {
	position = "right",
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 19.0,
		},
	},
	label = { drawing = false },
	padding_right = 5,
	padding_left = 0,
	update_freq = 120,
	updates = true,
})

local function update_battery()
	sbar.exec("pmset -g batt", function(batt_info)
		local percentage = batt_info:match("(%d+)%%")
		local charging = batt_info:match("AC Power")

		if not percentage then
			return
		end

		local pct = tonumber(percentage)
		local icon = icons.battery._0
		local color = colors.white
		local drawing = true

		if pct >= 90 then
			icon = icons.battery._100
			drawing = false
		elseif pct >= 60 then
			icon = icons.battery._75
			drawing = false
		elseif pct >= 30 then
			icon = icons.battery._50
		elseif pct >= 10 then
			icon = icons.battery._25
			color = colors.orange
		else
			icon = icons.battery._0
			color = colors.red
		end

		if charging then
			icon = icons.battery.charging
			drawing = false
		end

		battery:set({
			drawing = drawing,
			icon = {
				string = icon,
				color = color,
			},
		})
	end)
end

battery:subscribe({ "power_source_change", "system_woke", "routine" }, function(env)
	update_battery()
end)

-- Initial update
update_battery()
