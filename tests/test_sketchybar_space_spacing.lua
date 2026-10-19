package.path = "private_dot_config/sketchybar/?.lua;" .. package.path
package.loaded["lib.app_icons"] = function() return "app" end

local items = {}
local topology = "1\t1\n2\t2\n3\t3\n"
sbar = {
	add = function(kind, name, opts)
		if kind == "event" then return end
		local item = { state = opts or {}, callbacks = {} }
		function item:set(values)
			for key, value in pairs(values) do self.state[key] = value end
		end
		function item:subscribe(event, callback) self.callbacks[event] = callback end
		items[name] = item
		return item
	end,
	exec = function(command, callback)
		if command:find("query --spaces", 1, true) then
			callback(topology, 0)
		else
			callback("", 0)
		end
	end,
	animate = function(_, _, callback) callback() end,
}

dofile("private_dot_config/sketchybar/items/spaces.lua")

local function check(index, width)
	local state = items["space.spacer." .. index].state
	assert(state.width == width, "wrong spacer width for space " .. index)
	assert(state.drawing == (width > 0), "wrong spacer visibility for space " .. index)
end

check(2, 0)
check(3, 0)
topology = "1\t1\n2\t1\n3\t2\n4\t2\n5\t3\n"
items.space_creator.callbacks.spaces_refresh()
check(2, 8)
check(3, 0)
check(4, 8)
check(5, 0)
topology = "1\t1\n2\t2\n3\t3\n"
items.space_creator.callbacks.spaces_refresh()
check(2, 0)
check(3, 0)
check(4, 0)
check(5, 0)
print("Space spacing checks passed: separate displays, shared displays, and topology changes")
