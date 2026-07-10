local colors = require("config.colors")
local icons = require("config.icons")
local settings = require("config.settings")

local state_file = os.getenv("MIC_MONITOR_STATE_FILE")
if not state_file or state_file == "" then
	state_file = (os.getenv("HOME") or "") .. "/Library/Caches/com.user.mic-monitor/state"
end

local function shell_quote(value)
	return "'" .. value:gsub("'", "'\\''") .. "'"
end

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

local function set_active(active)
	mic:set({ drawing = active })
	if active then
		update_mic_state()
	end
end

local function update_active_state()
	sbar.exec("cat " .. shell_quote(state_file) .. " 2>/dev/null", function(result)
		local state, timestamp = result:match("^%s*(%d+)%s+(%d+)")
		local fresh = timestamp and os.time() - tonumber(timestamp) <= 15
		set_active(fresh == true and state == "1")
	end)
end

mic:subscribe("mic_active_changed", function(env)
	local active = env.ACTIVE
	if active == "1" then
		set_active(true)
	else
		set_active(false)
	end
end)

mic:subscribe("mic_mute_changed", function(env)
	if env.MUTED == "1" then
		mic:set({ icon = { string = icons.mic.off, color = colors.red } })
	elseif env.MUTED == "0" then
		mic:set({ icon = { string = icons.mic.on, color = colors.green } })
	else
		update_mic_state()
	end
end)

mic:subscribe("system_woke", function(env)
	update_mic_state()
	update_active_state()
end)

mic:subscribe("routine", function(env)
	update_active_state()
end)

update_mic_state()
