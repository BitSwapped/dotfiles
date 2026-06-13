-------------------------
---- Win Rules Setup ----
-------------------------

-- Disable blur for xwayland context menus
hl.window_rule({ match = { class = "^()$", title = "^()$" }, no_blur = true })

-- Disable blur for every window
hl.window_rule({ match = { class = ".*" }, no_blur = true })

-- Re-enable blur for specific terminals
hl.window_rule({ name = "contour-blur", match = { class = "org.contourterminal.Contour" }, no_blur = false })
hl.window_rule({ name = "ghostty-blur", match = { class = "com.mitchellh.ghostty" }, no_blur = false })

-- Float baseline (KDE-like behavior, applied first so specific rules override)
hl.window_rule({ match = { float = true }, persistent_size = true })
hl.window_rule({ match = { float = true }, center = true })
hl.window_rule({ match = { float = true }, focus_on_activate = true })
hl.window_rule({ match = { modal = true }, float = true, center = true, dim_around = true })

-- Browsers
hl.window_rule({
  name = "zen-browser-ws2",
  match = { class = "zen" },
  workspace = "2 silent",
})
hl.window_rule({
  name = "firefox-ws3",
  match = { class = "Firefox" },
  workspace = "3 silent",
})

-- Zen browser file download/open dialogs
hl.window_rule({
  match = { class = "zen", title = "^\\s*Opening .*\\.[a-zA-Z0-9]+" },
  float = true,
  fullscreen = false,
  suppress_event = "fullscreen",
  focus_on_activate = true,
  size = { "(monitor_w*0.28)", "(monitor_h*0.18)" },
  center = true,
})

-- File Managers
hl.window_rule({
  match = { class = "org.kde.dolphin" },
  float = true,
  center = true,
  size = { "(monitor_w*0.7)", "(monitor_h*0.75)" },
  persistent_size = true,
})
hl.window_rule({
  match = { class = "nemo" },
  float = true,
  center = true,
  size = { "(monitor_w*0.7)", "(monitor_h*0.75)" },
  persistent_size = true,
})

-- System / Settings Utilities
hl.window_rule({
  match = { class = "org.kde.easyeffects" },
  float = true,
  center = true,
  size = { "(monitor_w*0.6)", "(monitor_h*0.7)" },
  persistent_size = true,
})
hl.window_rule({
  match = { class = "lxappearance" },
  float = true,
  center = true,
  size = { "(monitor_w*0.5)", "(monitor_h*0.6)" },
  persistent_size = true,
})
hl.window_rule({
  match = { class = "nwg-look" },
  float = true,
  center = true,
  size = { "(monitor_w*0.5)", "(monitor_h*0.6)" },
  persistent_size = true,
})
hl.window_rule({
  match = { class = "^(pavucontrol)$" },
  float = true,
  center = true,
  size = { "(monitor_w*0.45)", "(monitor_h*0.45)" },
  persistent_size = true,
})
hl.window_rule({
  match = { class = "^(org.pulseaudio.pavucontrol)$" },
  float = true,
  center = true,
  size = { "(monitor_w*0.45)", "(monitor_h*0.45)" },
  persistent_size = true,
})
hl.window_rule({
  match = { class = "org.freedesktop.impl.portal.desktop.kde" },
  float = true,
  size = { "(monitor_w*0.50)", "(monitor_h*0.55)" },
})
hl.window_rule({ match = { class = ".*plasmawindowed.*" }, float = true })
hl.window_rule({ match = { class = "kcm_.*" }, float = true })

-- LibreOffice
hl.window_rule({
  match = { class = "libreoffice-draw" },
  float = true,
  center = true,
  size = { "(monitor_w*0.8)", "(monitor_h*0.85)" },
  persistent_size = true,
})
hl.window_rule({ match = { class = "soffice", title = "^(Tip of the Day)" }, float = true, center = true })

-- Floating dialogs (title-based)
hl.window_rule({ match = { title = "^(Open File)(.*)$" }, float = true, center = true })
hl.window_rule({ match = { title = "^(Select a File)(.*)$" }, float = true, center = true })
hl.window_rule({ match = { title = "^(Open Folder)(.*)$" }, float = true, center = true })
hl.window_rule({ match = { title = "^(Save As)(.*)$" }, float = true, center = true })
hl.window_rule({ match = { title = "^(Library)(.*)$" }, float = true, center = true })
hl.window_rule({ match = { title = "^(File Upload)(.*)$" }, float = true, center = true })
hl.window_rule({ match = { title = "^(.*)(wants to save)$" }, float = true, center = true })
hl.window_rule({ match = { title = "^(.*)(wants to open)$" }, float = true, center = true })

-- Picture-in-Picture (overrides float baseline center)
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, float = true })
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, keep_aspect_ratio = true })
hl.window_rule({ match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" }, pin = true })
hl.window_rule({
  match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
  size = { "(monitor_w*0.25)", "(monitor_h*0.25)" },
  move = { "(monitor_w*0.73)", "(monitor_h*0.72)" },
})

-- Screen sharing (overrides float baseline center)
hl.window_rule({ match = { title = ".*is sharing (a window|your screen).*" }, float = true, pin = true })
hl.window_rule({
  match = { title = ".*is sharing (a window|your screen).*" },
  move = { "(monitor_w*.5-window_w*.5)", "(monitor_h-window_h-12)" },
})

-- kde-material-you-colors: prevent theme change window from interfering
hl.window_rule({
  match = { class = "^(plasma-changeicons)$" },
  float = true,
  no_initial_focus = true,
  no_close_for = 500,
})
hl.window_rule({ match = { class = "^(plasma-changeicons)$" }, move = { 999999, 999999 } })

-- Tiling
hl.window_rule({ match = { class = "^dev\\.warp\\.Warp$" }, tile = true })

-- Tearing
hl.window_rule({ match = { title = ".*\\.exe" }, immediate = true })
hl.window_rule({ match = { title = ".*minecraft.*" }, immediate = true })
hl.window_rule({ match = { class = "^(steam_app).*" }, immediate = true })

-- Idle inhibit for games and video
hl.window_rule({ match = { class = "^(steam_app).*" }, idle_inhibit = "focus" })
hl.window_rule({ match = { title = ".*minecraft.*" }, idle_inhibit = "focus" })
hl.window_rule({ match = { content = "video" }, idle_inhibit = "focus" })
hl.window_rule({ match = { content = "game" }, idle_inhibit = "fullscreen" })

-- No shadow for tiled windows
hl.window_rule({ match = { float = 0 }, no_shadow = true })

-- Workspace rules
hl.workspace_rule({ workspace = "special:special", gaps_out = 30 })
hl.workspace_rule({ workspace = "special:scratchpad", on_created_empty = "alacritty" })
hl.workspace_rule({ workspace = "2", layout = "monocle" })
hl.workspace_rule({ workspace = "3", layout = "monocle" })

-- Smart gaps (ignoring special workspaces)
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, rounding = 0 })

-- Layer Rules
hl.layer_rule({ match = { namespace = ".*" }, xray = true })
hl.layer_rule({ match = { namespace = "wofi" }, no_anim = true })
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true })
hl.layer_rule({ match = { namespace = "overview" }, no_anim = true })
hl.layer_rule({ match = { namespace = "indicator.*" }, no_anim = true })
hl.layer_rule({ match = { namespace = "osk" }, no_anim = true })
hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })
hl.layer_rule({ match = { namespace = "noanim" }, no_anim = true })
hl.layer_rule({ match = { namespace = "gtk4-layer-shell" }, no_anim = true })
hl.layer_rule({ match = { namespace = "gtk-layer-shell" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "launcher" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.69 })
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
