local colors = require("config.colors")
local settings = require("config.settings")

local cal = sbar.add("item", "calendar", {
	position = "right",
	icon = {
		string = os.date("%a, %d %b"),
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
		padding_right = 0,
	},
	label = {
		string = os.date("%I:%M %p"),
		width = 70,
		align = "right",
	},
	padding_left = 15,
	update_freq = 15,
})

-- Update via Lua callback instead of external script to avoid race condition
-- where the sketchybar CLI can't find the item during config batching
cal:subscribe({ "routine", "system_woke" }, function(env)
	sbar.exec("date '+%a, %d %b|%I:%M %p'", function(output)
		local icon, label = output:match("(.-)|(.-)\n?$")
		if icon and label then
			cal:set({ icon = icon, label = label })
		end
	end)
end)

-- Zen mode toggle function
local zen_mode_on = false

local function toggle_zen()
	zen_mode_on = not zen_mode_on
	local drawing = zen_mode_on and "off" or "on"

	sbar.exec([[
    sketchybar --set wifi drawing=]] .. drawing .. [[ \
               --set apple.logo drawing=]] .. drawing .. [[ \
               --set '/cpu.*/' drawing=]] .. drawing .. [[ \
               --set calendar icon.drawing=]] .. (zen_mode_on and "off" or "on") .. [[ \
               --set front_app drawing=]] .. drawing .. [[ \
               --set volume_icon drawing=]] .. drawing .. [[ \
               --set brew drawing=]] .. drawing .. [[ \
               --set volume drawing=]] .. drawing .. [[ \
               --set github.bell drawing=]] .. drawing)
end

cal:subscribe("mouse.clicked", function(env)
	toggle_zen()
end)
