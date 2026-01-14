local colors = require("config.colors")
local icons = require("config.icons")

local wifi = sbar.add("item", "wifi", {
	position = "right",
	padding_right = 7,
	icon = {
		string = icons.wifi.disconnected,
	},
	label = {
		width = 0,
	},
})

local function update_wifi()
	sbar.exec("ipconfig getifaddr en0", function(ip)
		ip = ip:gsub("%s+", "")

		if ip ~= "" then
			-- Use networksetup on newer macOS (Sonoma+) or ipconfig for older versions
			sbar.exec(
				"networksetup -getairportnetwork en0 2>/dev/null | sed 's/Current Wi-Fi Network: //'",
				function(ssid)
					ssid = ssid:gsub("%s+$", "")
					if ssid == "" or ssid:match("not associated") then
						ssid = "Connected"
					end
					wifi:set({
						icon = { string = icons.wifi.connected },
						label = { string = ssid .. " (" .. ip .. ")" },
					})
				end
			)
		else
			wifi:set({
				icon = { string = icons.wifi.disconnected },
				label = { string = "Disconnected" },
			})
		end
	end)
end

local function toggle_wifi_label()
	sbar.exec("sketchybar --query wifi | jq -r '.label.width'", function(width_str)
		local current_width = tonumber(width_str) or 0
		local new_width = current_width == 0 and "dynamic" or 0

		sbar.animate("sin", 20, function()
			wifi:set({ label = { width = new_width } })
		end)
	end)
end

wifi:subscribe("wifi_change", function(env)
	update_wifi()
end)

wifi:subscribe("mouse.clicked", function(env)
	toggle_wifi_label()
end)

-- Initial update
update_wifi()
