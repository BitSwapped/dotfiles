------------------------
---- Keybinds Setup ----
------------------------

-- Programs
local terminal = "contour"
local terminal_alt = "alacritty"
local fileManager = "nemo"
local browser = "zen-browser"
local menu = "wofi"

-- Mods
local mainMod = "SUPER"
local shiftMod = "SHIFT"
local altMod = "ALT"
local ctrlMod = "CTRL"
local returnMod = "RETURN"

-- Functions

-- Function to extend table values
local function tbl_extend(...)
  local result = {}

  for _, t in ipairs({ ... }) do
    if type(t) == "table" then
      for k, v in pairs(t) do
        result[k] = v
      end
    end
  end
  return result
end

local defaults = { transparent = true }
--- Wrapper for bind function
---@param keys string|string[] keycodes
---@param dispatcher function|HL.Dispatcher dispatcher function
---@param opts table? Extra options
local function bind(keys, dispatcher, opts)
  -- nil check
  if not keys or not dispatcher then
    return
  end

  -- if keys is table merge and use otherwise use
  local key_str = type(keys) == "table" and table.concat(keys, " + ") or keys

  -- Merge defaults and opts
  local merged_opts = tbl_extend(defaults, opts or {})

  hl.bind(key_str, dispatcher, merged_opts)
end

-- Keybinds

-- Core Apps
bind({ mainMod, returnMod }, hl.dsp.exec_cmd(terminal), { description = "Open terminal" })
bind({ mainMod, shiftMod, returnMod }, hl.dsp.exec_cmd(terminal_alt), { description = "Open alt terminal" })
bind({ mainMod, "Q" }, hl.dsp.window.close(), { description = "Close active window" })
bind(
  { mainMod, shiftMod, "Q" },
  hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"),
  { description = "Exit Hyprland" }
)
bind({ mainMod, "E" }, hl.dsp.exec_cmd(fileManager), { description = "Open file manager" })
bind({ mainMod, "B" }, hl.dsp.exec_cmd(browser), { description = "Open browser" })
bind({ mainMod, "R" }, hl.dsp.exec_cmd(menu), { release = true, description = "Open app launcher" })

-- Window Actions
bind({ mainMod, "V" }, hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
bind({ mainMod, "P" }, hl.dsp.window.pseudo(), { description = "Toggle pseudo tiling" })
bind({ mainMod, "T" }, hl.dsp.layout("togglesplit"), { description = "Toggle split layout (dwindle)" })
bind(
  { mainMod, "F" },
  hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }),
  { description = "Toggle fullscreen" }
)
bind(
  { mainMod, shiftMod, "F" },
  hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle" }),
  { description = "Fake fullscreen (no presentation mode)" }
)

-- Move focus with mainMod
bind({ mainMod, "H" }, hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
bind({ mainMod, "L" }, hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
bind({ mainMod, "K" }, hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
bind({ mainMod, "J" }, hl.dsp.focus({ direction = "down" }), { description = "Focus down" })

-- Swap windows with mainMod + shiftMod
bind({ mainMod, shiftMod, "H" }, hl.dsp.window.swap({ direction = "left" }), { description = "Swap window left" })
bind({ mainMod, shiftMod, "L" }, hl.dsp.window.swap({ direction = "right" }), { description = "Swap window right" })
bind({ mainMod, shiftMod, "K" }, hl.dsp.window.swap({ direction = "up" }), { description = "Swap window up" })
bind({ mainMod, shiftMod, "J" }, hl.dsp.window.swap({ direction = "down" }), { description = "Swap window down" })

bind({ mainMod, "Tab" }, function()
  hl.dispatch(hl.dsp.window.cycle_next({ tiled = true }))
  hl.dispatch(hl.dsp.window.bring_to_top())
end)

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
  local key = tostring(i % 10) -- 10 maps to key 0, converted to string for concat
  bind({ mainMod, key }, hl.dsp.focus({ workspace = i }), { description = "Switch to workspace " .. i })
  bind(
    { mainMod, shiftMod, key },
    hl.dsp.window.move({ workspace = i }),
    { description = "Move window to workspace " .. i }
  )
end

-- Special workspace (scratchpad)
bind({ mainMod, "S" }, hl.dsp.workspace.toggle_special("magic"), { description = "Toggle scratchpad" })
bind(
  { mainMod, shiftMod, "S" },
  hl.dsp.window.move({ workspace = "special:magic" }),
  { description = "Move to scratchpad" }
)

-- Scroll through existing workspaces with mainMod + scroll
bind({ mainMod, "mouse_down" }, hl.dsp.focus({ workspace = "e+1" }), { description = "Workspace down" })
bind({ mainMod, "mouse_up" }, hl.dsp.focus({ workspace = "e-1" }), { description = "Workspace up" })

-- Move/resize windows with mainMod + LMB/RMB and dragging
bind({ mainMod, "mouse:272" }, hl.dsp.window.drag(), { mouse = true, description = "Drag window" })
bind({ mainMod, "mouse:273" }, hl.dsp.window.resize(), { mouse = true, description = "Resize window" })

-- Laptop multimedia keys for volume and LCD brightness
bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true, description = "Volume up" }
)
bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true, description = "Volume down" }
)
bind(
  "XF86AudioMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, description = "Toggle mute" }
)
bind(
  "XF86AudioMicMute",
  hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, description = "Toggle mic mute" }
)
bind(
  "XF86MonBrightnessUp",
  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
  { locked = true, repeating = true, description = "Brightness up" }
)
bind(
  "XF86MonBrightnessDown",
  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
  { locked = true, repeating = true, description = "Brightness down" }
)

-- Media controls
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Next track" })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Pause" })
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Play/Pause" })
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Previous track" })
