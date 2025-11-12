local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local max_workspaces = 9
local focused_workspace_index = nil

local workspaces = {}

-- Update workspace UI to reflect current window(s) state.
-- Shows window icons when apps are open and hides them when empty,
-- except for the focused workspace which shows a placeholder.
local function updateAppIconsForWorkspace(workspace_index)
	local get_windows =
		string.format("aerospace list-windows --workspace %s --format '%%{app-name}' --json", workspace_index)

	sbar.exec(get_windows, function(open_windows)
		-- Create string of app icons.
		local no_app = true
		local icon_line = ""
		for _, open_window in ipairs(open_windows) do
			no_app = false

			local app = open_window["app-name"]
			local lookup = app_icons[app]
			-- Fallback to default icon if app-specific icon isn't found
			local icon = ((lookup == nil) and app_icons["default"] or lookup)

			icon_line = icon_line .. " " .. icon
		end

		sbar.animate("tanh", 10, function()
			if no_app then
				if workspace_index == focused_workspace_index then
					-- Show placeholder for empty focused workspace
					icon_line = " —"
					workspaces[workspace_index]:set({
						icon = { drawing = true },
						label = { drawing = true, string = icon_line },
						background = { drawing = true },
						padding_right = 1,
						padding_left = 4,
					})
					return
				end

				-- Hide empty unfocused workspaces
				workspaces[workspace_index]:set({
					icon = { drawing = false },
					label = { drawing = false },
					background = { drawing = false },
					padding_right = 0,
					padding_left = 0,
				})
				return
			end

			workspaces[workspace_index]:set({
				icon = { drawing = true },
				label = { drawing = true, string = icon_line },
				background = { drawing = true },
				padding_right = 1,
				padding_left = 4,
			})
		end)
	end)
end

local function addWorkspaceSectionToBar(workspace_name)
	local workspace = sbar.add("item", {
		icon = {
			font = { family = settings.font.numbers },
			string = workspace_name,
			padding_left = 15,
			padding_right = 8,
			color = colors.white,
			highlight_color = colors.red,
		},
		label = {
			padding_right = 20,
			color = colors.grey,
			highlight_color = colors.white,
			font = "sketchybar-app-font:Regular:16.0",
			y_offset = -1,
		},
		padding_right = 1,
		padding_left = 1,
		background = {
			color = colors.bg2,
			border_width = 3,
			border_color = colors.transparent,
		},
	})

	workspaces[workspace_name] = workspace

	workspace:subscribe("aerospace_workspace_change", function(env)
		focused_workspace_index = env.FOCUSED_WORKSPACE
		local is_focused = focused_workspace_index == workspace_name

		sbar.animate("tanh", 10, function()
			workspace:set({
				icon = { highlight = is_focused },
				label = { highlight = is_focused },
				background = {
					border_color = is_focused and colors.bg1 or colors.bg2,
				},
			})
		end)
	end)

	workspace:subscribe("aerospace_focus_change", function()
		updateAppIconsForWorkspace(workspace_name)
	end)

	workspace:subscribe("mouse.clicked", function()
		sbar.exec("aerospace workspace " .. workspace_name)
	end)

	-- Set initial workspace state
	updateAppIconsForWorkspace(workspace_name)

	sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
		workspaces[focused_workspace]:set({
			icon = { highlight = true },
			label = { highlight = true },
			background = {
				border_color = colors.bg1,
			},
		})
	end)
end

sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "aerospace_focus_change")

for workspace_index = 1, max_workspaces do
	addWorkspaceSectionToBar(tostring(workspace_index))
end

-- Special workspaces for:
-- C = kitty
-- N = Notion, Slab
-- S = Slack, Zoom
local specials = "CNS"
for i = 1, #specials do
	local c = specials:sub(i, i)
	addWorkspaceSectionToBar(c)
end
