-- Catppuccin Mocha color palette
return {
	black = 0xff11111b,   -- Crust
	white = 0xffcdd6f4,   -- Text
	red = 0xfff38ba8,     -- Red
	green = 0xffa6e3a1,   -- Green
	blue = 0xff89b4fa,    -- Blue
	yellow = 0xfff9e2af,  -- Yellow
	orange = 0xfffab387,  -- Peach
	magenta = 0xffcba6f7, -- Mauve
	grey = 0xff9399b2,    -- Overlay2
	transparent = 0x00000000,

	-- Background colors
	bg0 = 0xff1e1e2e,     -- Base
	bg1 = 0x60585b70,     -- Surface2 (with alpha)
	bg2 = 0x6045475a,     -- Surface1 (with alpha)

	-- Bar colors
	bar = {
		bg = 0xff1e1e2e,   -- Base
		border = 0x6045475a, -- Surface1 (with alpha)
	},

	-- Popup colors
	popup = {
		bg = 0xff1e1e2e,   -- Base
		border = 0xffcdd6f4, -- Text
	},

	-- Utility function to adjust alpha
	with_alpha = function(color, alpha)
		if alpha > 1.0 or alpha < 0.0 then
			return color
		end
		return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
	end,
}
