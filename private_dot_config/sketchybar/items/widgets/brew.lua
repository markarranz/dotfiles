local colors = require("config.colors")
local icons = require("config.icons")

sbar.add("event", "brew_update")

local brew = sbar.add("item", "brew", {
	position = "right",
	update_freq = 1800,
	icon = {
		string = icons.brew,
	},
	label = {
		string = "?",
	},
	padding_right = 10,
})

local home = os.getenv("HOME")
local brew_cmd = home .. "/.config/sketchybar/helpers/brew-count.sh"

local function apply_count(count_str)
	local result = tostring(count_str or ""):match("^%s*(.-)%s*$")
	local count = tonumber(result)

	if not count then
		brew:set({
			label = { string = "!" },
			icon = { color = colors.red },
		})
		return
	end

	local color = colors.red
	local label = tostring(count)

	if count >= 30 and count < 60 then
		color = colors.orange
	elseif count >= 10 and count < 30 then
		color = colors.yellow
	elseif count >= 1 and count < 10 then
		color = colors.white
	elseif count == 0 then
		color = colors.green
		label = icons.checkmark
	end

	brew:set({
		label = { string = label },
		icon = { color = color },
	})
end

brew:subscribe("routine", function(env)
	sbar.exec(brew_cmd, apply_count)
end)

brew:subscribe("brew_update", function(env)
	sbar.exec(brew_cmd, apply_count)
end)

brew:subscribe("system_woke", function(env)
	sbar.exec("sleep 10 && " .. brew_cmd, apply_count)
end)

-- Initial update
sbar.exec(brew_cmd, apply_count)
