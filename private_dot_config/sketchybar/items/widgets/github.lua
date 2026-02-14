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

local max_popup_items = 20

local function update_github()
	-- Get accurate total count: --jq runs per page, so sum the per-page lengths
	sbar.exec("gh api notifications --paginate --jq length 2>/dev/null | awk '{s+=$1} END{print s+0}'", function(count_result)
		local count = tonumber(count_result) or 0

		-- Get first page of notifications for popup display
		sbar.exec("gh api notifications 2>/dev/null", function(result)
			sbar.exec("sketchybar --remove '/github.notification\\..*/' 2>/dev/null")

			local notifications = {}
			if type(result) == "table" then
				notifications = result
			elseif type(result) == "string" and result ~= "" then
				github_bell:set({
					icon = { string = icons.bell },
					label = { string = "!" },
				})
				return
			end

			local prev_count = notification_count
			notification_count = count

			if count == 0 then
				github_bell:set({
					icon = { string = icons.bell, color = colors.blue },
					label = { string = "0" },
				})

				sbar.add("item", "github.notification.0", {
					position = "popup." .. github_bell.name,
					icon = { string = "Note" },
					label = { string = "No new notifications" },
					drawing = true,
				})
				return
			end

			github_bell:set({
				icon = { string = icons.bell_dot, color = colors.blue },
				label = { string = tostring(count) },
			})

			local display_count = math.min(#notifications, max_popup_items)
			for i = 1, display_count do
				local notification = notifications[i]
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
					label = { string = title },
					drawing = true,
					click_script = "open 'https://github.com/notifications'; sketchybar --set "
						.. github_bell.name
						.. " popup.drawing=off; sleep 5; sketchybar --trigger github.update",
				})
			end

			if count > display_count then
				sbar.add("item", "github.notification.more", {
					position = "popup." .. github_bell.name,
					icon = { string = "+" .. (count - display_count) .. " more" },
					label = { string = "" },
					drawing = true,
					click_script = "open 'https://github.com/notifications'; sketchybar --set "
						.. github_bell.name
						.. " popup.drawing=off",
				})
			end

			if count > prev_count then
				sbar.animate("tanh", 15, function()
					github_bell:set({ label = { y_offset = 5 } })
				end)
				sbar.animate("tanh", 15, function()
					github_bell:set({ label = { y_offset = 0 } })
				end)
			end
		end)
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
	sbar.exec("open https://github.com/notifications")
	popup(false)
end)

-- Initial update
update_github()
