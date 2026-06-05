local icon_map = require("lib.icon_map")

local aliases = {
	["DBeaver Community"] = ":dbeaver:",
	-- :tuple: pending upstream sketchybar-app-font PR; alias works once font ships it
	["Tuple"] = ":tuple:",
}

return function(app_name)
	return aliases[app_name] or icon_map[app_name] or ":default:"
end
