-- Add SBarLua to package path
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

-- Load sketchybar module
sbar = require("sketchybar")

-- Load colors for helper
local colors = require("colors")

-- Start the CPU helper with color environment variables
local config_dir = os.getenv("HOME") .. "/.config/sketchybar"
local helper_cmd = string.format(
	"RED=0x%x ORANGE=0x%x YELLOW=0x%x LABEL_COLOR=0x%x %s/helper/helper git.felix.helper &",
	colors.red,
	colors.orange,
	colors.yellow,
	colors.white,
	config_dir
)
os.execute("killall helper 2>/dev/null; " .. helper_cmd)

-- Bundle configuration into a single message
sbar.begin_config()
require("bar")
require("default")
require("items")
sbar.end_config()

-- Enable hot reload
sbar.hotload(true)

-- Run the event loop
sbar.event_loop()
