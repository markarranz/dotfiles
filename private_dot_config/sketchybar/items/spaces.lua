local colors = require("config.colors")
local icons = require("config.icons")
local settings = require("config.settings")
local icon_map = require("lib.icon_map")

local MAX_APPS = 8

local JQ_VISIBLE_APPS = [[ | jq -r '[.[] | select(.role == "AXWindow" and ."is-minimized" == false and ."is-hidden" == false)] | sort_by(."stack-index" * 10000 + .frame.x) | .[] | "\(.app)\t\(.id)"']]


local spaces = {}
local space_app_items = {}
local brackets = {}
local space_windows = {}
local space_selected = {}
local current_focused_window_id = 0
local space_spacers = {}

local refresh_spaces

local function show_space(i)
	if spaces[i] then
		spaces[i]:set({ drawing = true })
	end
	if brackets[i] then
		brackets[i]:set({ background = { drawing = true } })
	end
	if i > 1 and space_spacers[i] then
		space_spacers[i]:set({ width = settings.group_paddings })
	end
end

local function hide_space(i)
	if spaces[i] then
		spaces[i]:set({ drawing = false })
	end
	if brackets[i] then
		brackets[i]:set({ background = { drawing = false } })
	end
	if i > 1 and space_spacers[i] then
		space_spacers[i]:set({ width = 0 })
	end
	if space_app_items[i] then
		for j = 1, MAX_APPS do
			space_app_items[i][j]:set({ drawing = false })
		end
	end
end

local function update_space_icons(space_num)
	local windows = space_windows[space_num]
	local items = space_app_items[space_num]
	if not spaces[space_num] or not items then
		return
	end

	local has_windows = windows and #windows > 0
	local selected = space_selected[space_num]

	for j = 1, MAX_APPS do
		if has_windows and j <= #windows then
			local win = windows[j]
			local app_icon = icon_map[win.app] or ":default:"
			local is_focused = win.id == current_focused_window_id
			local is_last = j == #windows
			local color = is_focused and colors.lavender or (selected and colors.white or colors.grey)
			items[j]:set({
				drawing = true,
				label = {
					string = app_icon,
					color = color,
					padding_right = is_last and 12 or 0,
				},
			})
		else
			items[j]:set({ drawing = false })
		end
	end

	sbar.animate("sin", 10, function()
		spaces[space_num]:set({
			label = {
				string = has_windows and "" or " —",
				drawing = not has_windows,
			},
		})
	end)
end

local function update_all_space_icons()
	for space_num, _ in pairs(space_windows) do
		update_space_icons(space_num)
	end
end

local function query_space_windows(space_num)
	sbar.exec("yabai -m query --windows --space " .. space_num .. JQ_VISIBLE_APPS, function(result, exit_code)
		if exit_code and exit_code ~= 0 then
			return
		end
		local windows = {}
		for line in result:gmatch("[^\n]+") do
			local app, id = line:match("^(.-)\t(%d+)$")
			if app and id then
				table.insert(windows, { app = app, id = tonumber(id) })
			end
		end
		space_windows[space_num] = windows
		show_space(space_num)
		update_space_icons(space_num)
	end)
end

for i = 1, 9 do
	if i > 1 then
		space_spacers[i] = sbar.add("space", "space.spacer." .. i, {
			space = i,
			width = 0,
			background = { drawing = false },
			icon = { drawing = false },
			label = { drawing = false },
		})
	end

	local debounced_focus = 'kill $(cat /tmp/.sketchybar-space-pid 2>/dev/null) 2>/dev/null;'
		.. ' (sleep 0.1 && yabai -m space --focus ' .. i .. ') &'
		.. ' echo $! > /tmp/.sketchybar-space-pid'

	local click_script = 'if [ "$BUTTON" = "right" ]; then'
		.. ' yabai -m space ' .. i .. ' --destroy;'
		.. ' elif [ "$MODIFIER" = "shift" ]; then'
		.. ' LABEL="$(osascript -e \'return (text returned of (display dialog "Give a name to space ' .. i .. ':" default answer "" with icon note buttons {"Cancel", "Continue"} default button "Continue"))\' 2>/dev/null)";'
		.. ' if [ -n "$LABEL" ]; then sketchybar --set space.' .. i .. ' icon.string="' .. i .. ' ($LABEL)";'
		.. ' else sketchybar --set space.' .. i .. ' icon.string="' .. i .. '"; fi;'
		.. ' else ' .. debounced_focus .. ' fi'

	local space = sbar.add("space", "space." .. i, {
		space = i,
		click_script = click_script,
		icon = {
			string = tostring(i),
			padding_left = 10,
			padding_right = 8,
			highlight_color = colors.red,
		},
		label = {
			padding_right = 10,
			color = colors.grey,
			highlight_color = colors.white,
			font = {
				family = "sketchybar-app-font",
				style = "Regular",
				size = 16.0,
			},
			y_offset = -1,
		},
		padding_left = 2,
		padding_right = 0,
		background = { drawing = false },
	})

	local app_items = {}
	local bracket_members = { "space." .. i }

	for j = 1, MAX_APPS do
		local app_item = sbar.add("space", "space." .. i .. ".app." .. j, {
			space = i,
			click_script = debounced_focus,
			icon = { drawing = false },
			label = {
				padding_left = 4,
				padding_right = 4,
				color = colors.grey,
				font = {
					family = "sketchybar-app-font",
					style = "Regular",
					size = 16.0,
				},
				y_offset = 0,
			},
			padding_left = 3,
			padding_right = 3,
			drawing = false,
			background = { color = colors.transparent },
		})
		app_items[j] = app_item
		table.insert(bracket_members, "space." .. i .. ".app." .. j)
	end

	local bracket = sbar.add("bracket", "space.bracket." .. i, bracket_members, {
		click_script = debounced_focus,
		background = {
			color = colors.bg1,
			border_color = colors.bg2,
		},
	})

	spaces[i] = space
	space_app_items[i] = app_items
	brackets[i] = bracket

	space:subscribe("space_change", function(env)
		local selected = false
		if env.INFO then
			for _, space_id in pairs(env.INFO) do
				if space_id == i then
					selected = true
					break
				end
			end
		end
		space_selected[i] = selected
		local border_color = selected and colors.grey or colors.bg2
		space:set({
			icon = { highlight = selected },
			label = { highlight = selected },
		})
		brackets[i]:set({ background = { border_color = border_color } })
		update_space_icons(i)
	end)

end

-- Space creator item
local space_creator = sbar.add("item", "space_creator", {
	padding_left = 10,
	padding_right = 8,
	icon = {
		string = icons.plus,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Heavy"],
			size = 16.0,
		},
		color = colors.white,
	},
	label = { drawing = false },
	display = "active",
	click_script = "yabai -m space --create",
})

-- Custom events for yabai signals
sbar.add("event", "windows_on_spaces_changed")
sbar.add("event", "window_focused")

-- Refresh space visibility on space changes. Using space_creator ("item" type)
-- ensures a single callback per event, unlike per-space "space" type handlers.
space_creator:subscribe("space_change", function()
	refresh_spaces()
end)

space_creator:subscribe("space_windows_change", function(env)
	local space_num = env.INFO and env.INFO.space
	if not space_num or not spaces[space_num] then
		return
	end
	query_space_windows(space_num)
end)

space_creator:subscribe("window_focused", function(env)
	current_focused_window_id = tonumber(env.WINDOW_ID) or 0
	update_all_space_icons()
end)

space_creator:subscribe("front_app_switched", function()
	sbar.exec("yabai -m query --windows --window | jq '.id'", function(result, exit_code)
		if exit_code and exit_code ~= 0 then
			return
		end
		local id = tonumber(result:match("%d+"))
		if id and id ~= current_focused_window_id then
			current_focused_window_id = id
			update_all_space_icons()
		end
	end)
end)

space_creator:subscribe("windows_on_spaces_changed", function()
	for space_num, _ in pairs(space_windows) do
		query_space_windows(space_num)
	end
end)

refresh_spaces = function()
	sbar.exec("yabai -m query --spaces | jq -r '.[].index'", function(result, exit_code)
		if exit_code and exit_code ~= 0 then
			return
		end
		local active = {}
		for space_num_str in result:gmatch("%d+") do
			local space_num = tonumber(space_num_str)
			if space_num then
				active[space_num] = true
			end
		end

		for i = 1, 9 do
			if active[i] then
				show_space(i)
				query_space_windows(i)
			else
				hide_space(i)
			end
		end
	end)
end

sbar.exec("yabai -m query --windows --window | jq '.id'", function(result, exit_code)
	if exit_code and exit_code ~= 0 then
		return
	end
	current_focused_window_id = tonumber(result:match("%d+")) or 0
	refresh_spaces()
end)
