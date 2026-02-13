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

-- Homebrew crashes in SketchyBar's minimal env (Hardware::CPU.cores fails).
-- Pre-set HOMEBREW_DOWNLOAD_CONCURRENCY to bypass CPU detection at startup.
local brew_env = 'eval "$(/opt/homebrew/bin/brew shellenv)" && export HOMEBREW_DOWNLOAD_CONCURRENCY=4'
local brew_cmd = brew_env .. ' && brew outdated 2>/dev/null | wc -l | tr -d " "'
local brew_update_cmd = brew_env .. ' && brew update >/dev/null 2>&1 && brew outdated 2>/dev/null | wc -l | tr -d " "'

local function apply_count(count_str)
	local count = tonumber(count_str) or 0
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

brew:subscribe({ "routine", "brew_update" }, function(env)
	sbar.exec(brew_update_cmd, apply_count)
end)

brew:subscribe("system_woke", function(env)
	sbar.exec("sleep 10 && " .. brew_update_cmd, apply_count)
end)

-- Initial update (fast — just check local index, no brew update)
sbar.exec(brew_cmd, apply_count)
