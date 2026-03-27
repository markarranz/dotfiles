local M = {}

function M.set_drawing(items, drawing)
	for _, item in ipairs(items) do
		sbar.set(item, { drawing = drawing })
	end
end

function M.create_popup_action(parent, name, icon, label, command)
	local item = sbar.add("item", name, {
		position = "popup." .. parent.name,
		icon = icon,
		label = label,
	})

	item:subscribe("mouse.clicked", function()
		sbar.exec(command)
		parent:set({ popup = { drawing = false } })
	end)

	return item
end

return M
