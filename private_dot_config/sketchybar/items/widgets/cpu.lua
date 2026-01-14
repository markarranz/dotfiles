local colors = require("config.colors")
local settings = require("config.settings")

-- CPU top label
local cpu_top = sbar.add("item", "cpu.top", {
	position = "right",
	icon = { drawing = false },
	label = {
		string = "CPU",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Semibold"],
			size = 7.0,
		},
	},
	width = 0,
	padding_right = 15,
	y_offset = 6,
})

-- CPU percent label
local cpu_percent = sbar.add("item", "cpu.percent", {
	position = "right",
	icon = { drawing = false },
	label = {
		string = "??%",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Heavy"],
			size = 12.0,
		},
	},
	y_offset = -4,
	padding_right = 15,
	width = 55,
	update_freq = 4,
	mach_helper = "git.felix.helper",
})

-- CPU system graph
local cpu_sys = sbar.add("graph", "cpu.sys", 75, {
	position = "right",
	width = 0,
	graph = {
		color = colors.red,
		fill_color = colors.red,
	},
	icon = { drawing = false },
	label = { drawing = false },
	background = {
		height = 30,
		drawing = true,
		color = colors.transparent,
	},
})

-- CPU user graph
local cpu_user = sbar.add("graph", "cpu.user", 75, {
	position = "right",
	graph = {
		color = colors.blue,
	},
	icon = { drawing = false },
	label = { drawing = false },
	background = {
		height = 30,
		drawing = true,
		color = colors.transparent,
	},
})

-- The C helper sends data via mach messaging
-- Updates are handled automatically by the mach_helper property
-- The helper sends commands like:
-- --push cpu.sys 0.05 --push cpu.user 0.10 --set cpu.percent label="15%" label.color=0xffxxxxxx --set cpu.top label="process"
