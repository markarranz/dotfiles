local colors = require("config.colors")
local icons = require("config.icons")
local settings = require("config.settings")

-- Register custom events (must be before item creation — github.lua pattern)
sbar.add("event", "mic_active_changed")
sbar.add("event", "mic_mute_changed")

local mic = sbar.add("item", "mic", {
	position = "right",
	drawing = false,
	updates = true,
	update_freq = 5,
	icon = {
		font = {
			family = "Symbols Nerd Font",
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
		string = icons.mic.on,
		color = colors.green,
	},
	label = { drawing = false },
})

local function update_mic_state()
	sbar.exec("osascript -e 'input volume of (get volume settings)'", function(vol)
		local volume = tonumber(vol) or 0
		if volume == 0 then
			mic:set({ icon = { string = icons.mic.off, color = colors.red } })
		else
			mic:set({ icon = { string = icons.mic.on, color = colors.green } })
		end
	end)
end

mic:subscribe("mic_active_changed", function(env)
	local active = env.ACTIVE
	if active == "1" then
		mic:set({ drawing = true })
		update_mic_state()
	else
		mic:set({ drawing = false })
	end
end)

mic:subscribe("mic_mute_changed", function(env)
	update_mic_state()
end)

mic:subscribe("system_woke", function(env)
	update_mic_state()
end)

mic:subscribe("routine", function(env)
	sbar.exec("cat /tmp/mic-monitor-state 2>/dev/null", function(result)
		local state = result:match("%d+")
		local active = tonumber(state) or 0
		if active == 1 then
			mic:set({ drawing = true })
			update_mic_state()
		else
			mic:set({ drawing = false })
		end
	end)
end)

update_mic_state()
