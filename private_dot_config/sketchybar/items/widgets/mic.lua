local colors = require("config.colors")
local icons = require("config.icons")
local settings = require("config.settings")

-- Register custom events (must be before item creation — github.lua pattern)
sbar.add("event", "mic_active_changed")
sbar.add("event", "mic_mute_changed")

local mic = sbar.add("item", "mic", {
	position = "right",
	drawing = false, -- hidden by default; shown only when mic is in use
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
		string = icons.mic.on,
		color = colors.green,
	},
	label = { drawing = false }, -- no label, icon only
})

local function update_mic_state()
	-- Check input volume to determine mute state
	sbar.exec("osascript -e 'input volume of (get volume settings)'", function(vol)
		local volume = tonumber(vol) or 0
		if volume == 0 then
			-- Muted
			mic:set({ icon = { string = icons.mic.off, color = colors.red } })
		else
			-- Active and unmuted
			mic:set({ icon = { string = icons.mic.on, color = colors.green } })
		end
	end)
end

-- Handle mic-in-use state from Swift daemon
mic:subscribe("mic_active_changed", function(env)
	local active = env.ACTIVE
	if active == "1" then
		mic:set({ drawing = true })
		update_mic_state()
	else
		mic:set({ drawing = false })
	end
end)

-- Handle mute/unmute from toggle script
mic:subscribe("mic_mute_changed", function(env)
	update_mic_state()
end)

-- Handle system wake (re-check state after sleep)
mic:subscribe("system_woke", function(env)
	update_mic_state()
end)

-- Initial state: check if already muted (widget starts hidden; daemon will show it if mic is active)
update_mic_state()
