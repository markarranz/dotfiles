local colors = require("config.colors")
local icons = require("config.icons")
local settings = require("config.settings")

local SLIDER_WIDTH = 100

-- Volume slider
local volume_slider = sbar.add("slider", "volume", SLIDER_WIDTH, {
	position = "right",
	updates = true,
	label = { drawing = false },
	icon = { drawing = false },
	slider = {
		highlight_color = colors.blue,
		background = {
			height = 5,
			corner_radius = 3,
			color = colors.bg2,
		},
		knob = {
			string = "􀀁",
			drawing = true,
		},
	},
})

-- Volume icon
local volume_icon = sbar.add("item", "volume_icon", {
	position = "right",
	padding_left = 10,
	icon = {
		string = icons.volume._100,
		width = 0,
		align = "left",
		color = colors.grey,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
	},
	label = {
		width = 25,
		align = "left",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
	},
})

-- Status bracket
local status_bracket = sbar.add("bracket", "status", { "brew", "github.bell", "wifi", "volume_icon" }, {
	background = {
		color = colors.bg1,
		border_color = colors.bg2,
	},
})

local function get_volume_icon(volume)
	if volume >= 60 then
		return icons.volume._100
	elseif volume >= 30 then
		return icons.volume._66
	elseif volume >= 10 then
		return icons.volume._33
	elseif volume > 0 then
		return icons.volume._10
	else
		return icons.volume._0
	end
end

local function query_slider_width(callback)
	sbar.exec("sketchybar --query volume | jq -r '.slider.width'", function(width_str)
		callback(tonumber(width_str) or 0)
	end)
end

local function query_slider_percentage(callback)
	sbar.exec("sketchybar --query volume | jq -r '.slider.percentage'", function(pct_str)
		callback(tonumber(pct_str) or 0)
	end)
end

local function animate_slider_width(width)
	sbar.animate("tanh", 30, function()
		volume_slider:set({ slider = { width = width } })
	end)
end

local function animate_slider_for_volume_change(expected_volume)
	query_slider_width(function(width)
		if width == 0 then
			animate_slider_width(SLIDER_WIDTH)
		end

		sbar.exec("sleep 2", function()
			query_slider_percentage(function(pct)
				if pct == expected_volume then
					animate_slider_width(0)
				end
			end)
		end)
	end)
end

volume_slider:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO) or 0

	volume_icon:set({
		label = { string = get_volume_icon(volume) },
	})

	volume_slider:set({
		slider = { percentage = volume },
	})

	animate_slider_for_volume_change(volume)
end)

volume_slider:subscribe("mouse.clicked", function(env)
	local percentage = env.PERCENTAGE
	if percentage then
		sbar.exec('osascript -e "set volume output volume ' .. percentage .. '"')
	end
end)

-- Volume icon click - toggle detail or device selection
local popup_visible = false

local function toggle_devices()
	sbar.exec("which SwitchAudioSource", function(result)
		if result == "" then
			return
		end

		-- Remove existing device items
		sbar.exec("sketchybar --remove '/volume.device\\..*/'")

		if not popup_visible then
			sbar.exec("SwitchAudioSource -c -t output", function(current_device)
				current_device = current_device:gsub("%s+$", "")

				sbar.exec("SwitchAudioSource -a -t output", function(devices_str)
					local counter = 0
					for device in devices_str:gmatch("[^\n]+") do
						local color = device == current_device and colors.white or colors.grey
						counter = counter + 1

						sbar.add("item", "volume.device." .. counter, {
							position = "popup." .. volume_icon.name,
							label = {
								string = device,
								color = color,
							},
							click_script = "SwitchAudioSource -s '"
								.. device:gsub("'", "'\\''")
								.. "' && sketchybar --set /volume.device\\..*/ label.color="
								.. colors.grey
								.. " --set $NAME label.color="
								.. colors.white
								.. " --set "
								.. volume_icon.name
								.. " popup.drawing=off",
						})
					end
				end)
			end)
		end

		popup_visible = not popup_visible
		volume_icon:set({ popup = { drawing = popup_visible } })
	end)
end

local function toggle_detail()
	query_slider_width(function(width)
		local new_width = width == 0 and SLIDER_WIDTH or 0
		animate_slider_width(new_width)
	end)
end

volume_icon:subscribe("mouse.clicked", function(env)
	if env.BUTTON == "right" or env.MODIFIER == "shift" then
		toggle_devices()
	else
		toggle_detail()
	end
end)
