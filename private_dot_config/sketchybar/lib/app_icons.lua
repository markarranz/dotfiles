local icon_map = require("lib.icon_map")

local aliases = {
	["DBeaver Community"] = ":dbeaver:",
}

return function(app_name)
	return aliases[app_name] or icon_map[app_name] or ":default:"
end
