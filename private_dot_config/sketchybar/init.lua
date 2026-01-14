-- Add SBarLua to package path
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

-- Load sketchybar module
sbar = require("sketchybar")

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
