---------------------
---- Misc. Setup ----
---------------------

hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 8,
		float_gaps = -1,
		gaps_workspaces = 0,

		border_size = 2,

		col = {
			active_border = "0xff9ba6f6",
			inactive_border = "0xff3e486e",
			nogroup_border = "0xffba87ee",
			nogroup_border_active = "0xffd4a1f7",
		},

		layout = "dwindle",
		no_focus_fallback = false,
		resize_on_border = true,
		extend_border_grab_area = 15,
		hover_icon_on_border = true,
		allow_tearing = false,
	},
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		vrr = 0,
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
		animate_manual_resizes = false,
		animate_mouse_windowdragging = false,
		enable_swallow = true,
		swallow_regex = "^(contour|ghostty)",
		on_focus_under_fullscreen = 2,
		allow_session_lock_restore = true,
		session_lock_xray = true,
		initial_workspace_tracking = false,
		focus_on_activate = true,
	},

	xwayland = {
		force_zero_scaling = true,
	},
})
