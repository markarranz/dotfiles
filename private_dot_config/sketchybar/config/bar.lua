local colors = require("config.colors")

-- Bar configuration
sbar.bar({
	height = 45,
	color = colors.bar.bg,
	border_width = 2,
	border_color = colors.bar.border,
	shadow = "off",
	position = "top",
	sticky = "on",
	padding_right = 10,
	padding_left = 10,
	y_offset = -5,
	margin = -2,
	topmost = "window",
})
