local colors = require("config.colors")
local icons = require("config.icons")
local settings = require("config.settings")
local app_icons = require("lib.app_icons")

local MAX_APPS = 8

local spaces = {}
local space_app_items = {}
local brackets = {}
local space_apps = {}
local space_selected = {}
local current_front_app = ""
local space_spacers = {}

local function update_space_icons(space_num)
	local apps = space_apps[space_num]
	local items = space_app_items[space_num]
	if not spaces[space_num] or not items then
		return
	end

	local has_apps = apps and #apps > 0
	local selected = space_selected[space_num]

	for j = 1, MAX_APPS do
		if has_apps and j <= #apps then
			local app_name = apps[j]
			local app_icon = app_icons(app_name)
			local is_focused = app_name == current_front_app
			local is_last = j == #apps
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
				string = has_apps and "" or " —",
				drawing = not has_apps,
			},
		})
	end)
end

for i = 1, 9 do
	if i > 1 then
		space_spacers[i] = sbar.add("item", "space.spacer." .. i, {
			width = 0,
			background = { drawing = false },
			icon = { drawing = false },
			label = { drawing = false },
		})
	end

	local space = sbar.add("space", "space." .. i, {
		space = i,
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
		local app_item = sbar.add("item", "space." .. i .. ".app." .. j, {
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
			background = { color = 0x00000000 },
		})
		app_items[j] = app_item
		table.insert(bracket_members, "space." .. i .. ".app." .. j)
	end

	local bracket = sbar.add("bracket", "space.bracket." .. i, bracket_members, {
		background = {
			color = colors.bg1,
			border_color = colors.bg2,
		},
	})

	spaces[i] = space
	space_app_items[i] = app_items
	brackets[i] = bracket

	-- Handle space selection highlighting
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

	-- Handle mouse clicks
	local function handle_click(env)
		if env.BUTTON == "right" then
			sbar.exec("yabai -m space " .. i .. " --destroy")
		elseif env.MODIFIER == "shift" then
			sbar.exec([[
        osascript -e 'return (text returned of (display dialog "Give a name to space ]] .. i .. [[:" default answer "" with icon note buttons {"Cancel", "Continue"} default button "Continue"))'
      ]], function(result)
				local label = result:gsub("%s+$", "")
				if label ~= "" then
					space:set({ icon = { string = i .. " (" .. label .. ")" } })
				else
					space:set({ icon = { string = tostring(i) } })
				end
			end)
		else
			sbar.exec("yabai -m space --focus " .. i)
		end
	end

	space:subscribe("mouse.clicked", handle_click)
	bracket:subscribe("mouse.clicked", handle_click)
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

-- Custom event for yabai window move/resize signals
sbar.add("event", "windows_on_spaces_changed")

-- Update space labels with app icons
space_creator:subscribe("space_windows_change", function(env)
	local space_num = env.INFO and env.INFO.space
	if not space_num or not spaces[space_num] then
		return
	end

	sbar.exec(
		"yabai -m query --windows --space "
			.. space_num
			.. [[ | jq -r '[.[] | select(.role == "AXWindow" and ."is-minimized" == false and ."is-hidden" == false)] | sort_by(."stack-index" * 10000 + .frame.x) | .[].app']],
		function(result)
			local apps = {}
			for app_name in result:gmatch("[^\n]+") do
				table.insert(apps, app_name)
			end
			space_apps[space_num] = apps
			update_space_icons(space_num)
		end
	)
end)

space_creator:subscribe("front_app_switched", function(env)
	current_front_app = env.INFO or ""
	for space_num, _ in pairs(space_apps) do
		update_space_icons(space_num)
	end
end)

space_creator:subscribe("windows_on_spaces_changed", function()
	for space_num, _ in pairs(space_apps) do
		sbar.exec(
			"yabai -m query --windows --space "
				.. space_num
				.. [[ | jq -r '[.[] | select(.role == "AXWindow" and ."is-minimized" == false and ."is-hidden" == false)] | sort_by(."stack-index" * 10000 + .frame.x) | .[].app']],
			function(result)
				local apps = {}
				for app_name in result:gmatch("[^\n]+") do
					table.insert(apps, app_name)
				end
				space_apps[space_num] = apps
				update_space_icons(space_num)
			end
		)
	end
end)

-- Seed all spaces and manage spacer visibility on load
local function refresh_spaces()
	sbar.exec("yabai -m query --spaces | jq -r '.[].index'", function(result)
		local active = {}
		for space_num_str in result:gmatch("%d+") do
			local space_num = tonumber(space_num_str)
			if space_num then
				active[space_num] = true
			end
		end

		-- Update spacer widths based on which spaces exist
		for i = 2, 9 do
			if space_spacers[i] then
				space_spacers[i]:set({ width = active[i] and settings.group_paddings or 0 })
			end
		end

		-- Seed window icons for active spaces
		for space_num, _ in pairs(active) do
			if spaces[space_num] then
				sbar.exec(
					"yabai -m query --windows --space "
						.. space_num
						.. [[ | jq -r '[.[] | select(.role == "AXWindow" and ."is-minimized" == false and ."is-hidden" == false)] | sort_by(."stack-index" * 10000 + .frame.x) | .[].app']],
					function(win_result)
						local apps = {}
						for app_name in win_result:gmatch("[^\n]+") do
							table.insert(apps, app_name)
						end
						space_apps[space_num] = apps
						update_space_icons(space_num)
					end
				)
			end
		end
	end)
end

refresh_spaces()
