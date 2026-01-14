local colors = require("config.colors")
local icons = require("config.icons")
local settings = require("config.settings")

-- Register custom event
sbar.add("event", "github.update")

local github_bell = sbar.add("item", "github.bell", {
	position = "right",
	padding_right = 6,
	update_freq = 180,
	icon = {
		string = icons.bell,
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 15.0,
		},
		color = colors.blue,
	},
	label = {
		string = icons.loading,
		highlight_color = colors.blue,
	},
	popup = {
		align = "right",
	},
})

local github_template = sbar.add("item", "github.template", {
	position = "popup." .. github_bell.name,
	drawing = false,
	background = {
		corner_radius = 12,
	},
	padding_left = 7,
	padding_right = 7,
	icon = {
		background = {
			height = 2,
			y_offset = -12,
		},
	},
})

local notification_count = 0

local function update_github()
	sbar.exec("gh api notifications 2>/dev/null", function(result)
		-- Remove old notification items
		sbar.exec("sketchybar --remove '/github.notification\\..*/' 2>/dev/null")

		-- Handle result - sbar.exec parses JSON automatically into Lua tables
		local notifications = {}
		if type(result) == "table" then
			notifications = result
		elseif type(result) == "string" and result ~= "" then
			-- Fallback: if result is a string, it's an error or unexpected format
			github_bell:set({
				icon = { string = icons.bell },
				label = { string = "!" },
			})
			return
		end

		local count = #notifications

		local prev_count = notification_count
		notification_count = count

		if count == 0 then
			github_bell:set({
				icon = { string = icons.bell, color = colors.blue },
				label = { string = "0" },
			})

			-- Add "no notifications" item
			sbar.add("item", "github.notification.0", {
				position = "popup." .. github_bell.name,
				icon = {
					string = "Note",
				},
				label = {
					string = "No new notifications",
				},
				drawing = true,
			})
			return
		end

		github_bell:set({
			icon = { string = icons.bell_dot, color = colors.blue },
			label = { string = tostring(count) },
		})

		-- Create notification items from parsed data
		for i, notification in ipairs(notifications) do
			local repo = notification.repository and notification.repository.name or "unknown"
			local ntype = notification.subject and notification.subject.type or ""
			local title = notification.subject and notification.subject.title or "No title"

			local color = colors.blue
			local item_icon = icons.git.indicator

			if ntype == "Issue" then
				color = colors.green
				item_icon = icons.git.issue
			elseif ntype == "PullRequest" then
				color = colors.magenta
				item_icon = icons.git.pull_request
			elseif ntype == "Discussion" then
				color = colors.white
				item_icon = icons.git.discussion
			elseif ntype == "Commit" then
				color = colors.white
				item_icon = icons.git.commit
			end

			-- Check for important keywords
			if title:lower():match("deprecat") or title:lower():match("break") or title:lower():match("broke") then
				color = colors.red
				item_icon = "􀁞"
				github_bell:set({ icon = { color = colors.red } })
			end

			sbar.add("item", "github.notification." .. i, {
				position = "popup." .. github_bell.name,
				icon = {
					string = item_icon .. " " .. repo .. ":",
					color = color,
					background = { color = color },
				},
				label = {
					string = title,
				},
				drawing = true,
				click_script = "open 'https://github.com/notifications'; sketchybar --set "
					.. github_bell.name
					.. " popup.drawing=off; sleep 5; sketchybar --trigger github.update",
			})
		end

		-- Animate if new notifications
		if count > prev_count then
			sbar.animate("tanh", 15, function()
				github_bell:set({ label = { y_offset = 5 } })
			end)
			sbar.animate("tanh", 15, function()
				github_bell:set({ label = { y_offset = 0 } })
			end)
		end
	end)
end

local function popup(state)
	github_bell:set({ popup = { drawing = state } })
end

github_bell:subscribe({ "routine", "forced", "github.update" }, function(env)
	update_github()
end)

github_bell:subscribe("system_woke", function(env)
	sbar.exec("sleep 10", function()
		update_github()
	end)
end)

github_bell:subscribe("mouse.entered", function(env)
	popup(true)
end)

github_bell:subscribe({ "mouse.exited", "mouse.exited.global" }, function(env)
	popup(false)
end)

github_bell:subscribe("mouse.clicked", function(env)
	sbar.exec("sketchybar --query " .. github_bell.name .. " | jq -r '.popup.drawing'", function(state)
		popup(state ~= "on")
	end)
end)

-- Initial update
update_github()
