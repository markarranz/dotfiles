local colors = require("colors")
local icons = require("icons")

sbar.add("event", "brew_update")

local brew = sbar.add("item", "brew", {
	position = "right",
	icon = {
		string = icons.brew,
	},
	label = {
		string = "?",
	},
	padding_right = 10,
})

local function update_brew_count()
	sbar.exec("brew outdated | wc -l | tr -d ' '", function(count_str)
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
	end)
end

brew:subscribe("brew_update", function(env)
	update_brew_count()
end)

-- Initial update
update_brew_count()
