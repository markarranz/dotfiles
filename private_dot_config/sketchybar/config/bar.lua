local colors = require("config.colors")

-- Bar configuration
sbar.bar({
	height = 39,
	color = colors.bar.bg,
	border_color = colors.bar.border,
	shadow = "off",
	position = "top",
	sticky = "on",
	padding_right = 10,
	padding_left = 10,
	topmost = "window",
})
