local colors = require("config.colors")
local icons = require("config.icons")

local wireguard_check = [=[
if command -v wg >/dev/null 2>&1 && wg show interfaces 2>/dev/null | grep -q .; then
	printf '1'
elif scutil --nc list 2>/dev/null | awk 'tolower($0) ~ /wireguard/ && $0 ~ /\([Cc]onnected\)/ { found = 1 } END { exit found ? 0 : 1 }'; then
	printf '1'
elif pgrep -if '[w]ireguard-go|[w]g-quick' >/dev/null 2>&1 && ifconfig 2>/dev/null | awk '
	/^utun[0-9]+:/ {
		if (active && inet) found = 1
		active = 0
		inet = 0
		next
	}
	/status: active/ { active = 1 }
	/^[[:space:]]*inet[[:space:]]/ { inet = 1 }
	END {
		if (active && inet) found = 1
		exit found ? 0 : 1
	}
'; then
	printf '1'
else
	printf '0'
fi
]=]

local wireguard = sbar.add("item", "wireguard", {
	position = "right",
	drawing = false,
	update_freq = 30,
	updates = true,
	padding_right = 7,
	icon = {
		string = icons.wireguard,
		color = colors.sky,
		font = {
			family = "sketchybar-app-font",
			style = "Regular",
			size = 16.0,
		},
	},
	label = { drawing = false },
})

local function update_wireguard()
	sbar.exec(wireguard_check, function(result)
		local active = tostring(result or ""):match("1") ~= nil
		wireguard:set({ drawing = active })
	end)
end

wireguard:subscribe({ "routine", "system_woke" }, function(env)
	update_wireguard()
end)

update_wireguard()
