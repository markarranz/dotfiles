local icon_map = require("lib.icon_map")

return function(app_name)
	return icon_map[app_name] or ":default:"
end
