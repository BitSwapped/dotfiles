-------------------------
---- Autostart Setup ----
-------------------------

hl.on("hyprland.start", function()
  -- Load cursor
  hl.exec_cmd("hyprctl setcursor Material Dark Cursors 24")
  -- Start polkit daemon
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  -- Restore wallpaper
  hl.exec_cmd("wpaper -d")
  -- Environment for xdg-desktop-portal-hyprland
  hl.exec_cmd("/usr/libexec/xdg-desktop-portal --replace")
  hl.exec_cmd("/usr/libexec/xdg-desktop-portal-hyprland")
  -- Start hypridle
  hl.exec_cmd("hypridle")
  -- Load cliphist history
  hl.exec_cmd("wl-paste --watch cliphist store")
end)
