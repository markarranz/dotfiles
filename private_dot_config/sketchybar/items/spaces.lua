local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}

for i = 1, 9 do
  local space = sbar.add("space", "space." .. i, {
    space = i,
    icon = {
      string = tostring(i),
      padding_left = 10,
      padding_right = 10,
      highlight_color = colors.red,
    },
    label = {
      padding_right = 20,
      color = colors.grey,
      highlight_color = colors.white,
      font = {
        family = "sketchybar-app-font",
        style = "Regular",
        size = 16.0,
      },
      y_offset = -1,
    },
    padding_left = 2,
    padding_right = 2,
    background = {
      color = colors.bg1,
      border_color = colors.bg2,
    },
  })

  spaces[i] = space

  -- Handle space selection highlighting
  space:subscribe("space_change", function(env)
    local selected = env.SELECTED == "true"
    local border_color = selected and colors.grey or colors.bg2
    space:set({
      icon = { highlight = selected },
      label = { highlight = selected },
      background = { border_color = border_color },
    })
  end)

  -- Handle mouse clicks
  space:subscribe("mouse.clicked", function(env)
    if env.BUTTON == "right" then
      sbar.exec("yabai -m space " .. i .. " --destroy")
    elseif env.MODIFIER == "shift" then
      sbar.exec([[
        osascript -e 'return (text returned of (display dialog "Give a name to space ]] .. i .. [[:" default answer "" with icon note buttons {"Cancel", "Continue"} default button "Continue"))'
      ]], function(result)
        local label = result:gsub("%s+$", "")
        if label ~= "" then
          space:set({ icon = { string = i .. " (" .. label .. ")" } })
        else
          space:set({ icon = { string = tostring(i) } })
        end
      end)
    else
      sbar.exec("yabai -m space --focus " .. i)
    end
  end)
end

-- Space creator item
local space_creator = sbar.add("item", "space_creator", {
  padding_left = 10,
  padding_right = 8,
  icon = {
    string = icons.plus,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Heavy"],
      size = 16.0,
    },
    color = colors.white,
  },
  label = { drawing = false },
  display = "active",
  click_script = "yabai -m space --create",
})

-- Update space labels with app icons
space_creator:subscribe("space_windows_change", function(env)
  local space_num = env.INFO and env.INFO.space
  if not space_num or not spaces[space_num] then return end

  local apps = env.INFO.apps
  local icon_strip = ""

  if apps and next(apps) then
    for app_name, _ in pairs(apps) do
      local app_icon = app_icons(app_name)
      icon_strip = icon_strip .. " " .. app_icon
    end
  else
    icon_strip = " —"
  end

  sbar.animate("sin", 10, function()
    spaces[space_num]:set({ label = { string = icon_strip } })
  end)
end)
