--------------------------
---- Decoration Setup ----
--------------------------

hl.config({
  decoration = {
    rounding = 6,
    rounding_power = 3.7,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    fullscreen_opacity = 1.0,

    blur = {
      enabled = true,
      size = 12,
      passes = 3,
      noise = 0.08,
      contrast = 0.83,
      vibrancy = 0.8,
      brightness = 1,
      xray = true,
      special = false,
    },
    shadow = {
      enabled = false,
    },
  },
})
