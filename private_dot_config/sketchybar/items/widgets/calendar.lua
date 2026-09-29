local settings = require("config.settings")
local item_utils = require("helpers.item_utils")

local date_fmt = "%a %b %d"
local time_fmt = "%I:%M %p"
local dt_cmd = "date '+" .. date_fmt .. "|" .. time_fmt .. "'"

local cal = sbar.add("item", "calendar", {
	position = "right",
	icon = {
		string = os.date(date_fmt),
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
cal:subscribe({ "routine", "system_woke" }, function()
	sbar.exec(dt_cmd, function(output)
		local icon, label = output:match("(.-)|(.-)\n?$")
		cal:set({ icon = icon, label = label })
	end)
end)

-- Zen mode toggle function
local zen_mode_on = false

local function toggle_zen()
	zen_mode_on = not zen_mode_on
	local drawing = not zen_mode_on

	item_utils.set_drawing({ "wifi", "apple.logo", "front_app", "volume_icon", "brew", "volume", "github.bell" }, drawing)
	sbar.set("/cpu.*/", { drawing = drawing })
	cal:set({ icon = { drawing = drawing } })
end

cal:subscribe("mouse.clicked", function()
	toggle_zen()
end)
