local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	background = {
		color = colors.bg1,
	},
	icon = {
		padding_left = 12,
	},
	label = {
		padding_right = 12,
		font = { family = settings.font.numbers },
	},
	update_freq = 180,
	popup = { align = "center" },
})

local remaining_time = sbar.add("item", {
	position = "popup." .. battery.name,
	icon = {
		string = "Time remaining:",
		width = 100,
		align = "left",
	},
	label = {
		string = "??:??h",
		width = 100,
		align = "right",
	},
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local label = "?"

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
			label = charge .. "%"
		end

		local color = colors.green
		local charging, _, _ = batt_info:find("AC Power")

		if charging then
			icon = icons.battery.charging
		elseif found then
			if charge <= 5 then
				icon = icons.battery._0
				color = colors.red
			elseif charge <= 10 then
				icon = icons.battery._10
				color = colors.red
			elseif charge <= 20 then
				icon = icons.battery._20
				color = colors.orange
			elseif charge <= 30 then
				icon = icons.battery._30
			elseif charge <= 40 then
				icon = icons.battery._40
			elseif charge <= 50 then
				icon = icons.battery._50
			elseif charge <= 60 then
				icon = icons.battery._60
			elseif charge <= 70 then
				icon = icons.battery._70
			elseif charge <= 80 then
				icon = icons.battery._80
			elseif charge <= 90 then
				icon = icons.battery._90
			else -- charge <= 100
				icon = icons.battery._100
			end
		else
			icon = icons.battery._0
			color = colors.red
		end

		local lead = ""
		if found and charge < 10 then
			lead = "0"
		end

		battery:set({
			icon = {
				string = icon,
				color = color,
			},
			label = { string = lead .. label },
		})
	end)
end)

battery:subscribe("mouse.clicked", function(env)
	local drawing = battery:query().popup.drawing
	battery:set({ popup = { drawing = "toggle" } })

	if drawing == "off" then
		sbar.exec("pmset -g batt", function(batt_info)
			local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
			local label = found and remaining .. "h" or "No estimate"
			remaining_time:set({ label = label })
		end)
	end
end)
