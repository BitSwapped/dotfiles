---------------------
---- Input Setup ----
---------------------

hl.config({
	gestures = {
		workspace_swipe_distance = 700,
		workspace_swipe_cancel_ratio = 0.2,
		workspace_swipe_min_speed_to_force = 5,
		workspace_swipe_direction_lock = true,
		workspace_swipe_direction_lock_threshold = 10,
		workspace_swipe_create_new = true,
	},
	input = {
		-- Mouse / Cursor
		accel_profile = "adaptive",

		-- Focus behavior
		follow_mouse = 1,

		-- Scrolling
		natural_scroll = false,
		scroll_method = "2fg",
		scroll_button_lock = true,

		-- Touchpad
		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
			clickfinger_behavior = true,
			tap_to_click = true,
			drag_lock = false,
			scroll_factor = 0.6,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "swipe",
	action = "move",
})
hl.gesture({
	fingers = 3,
	direction = "pinch",
	action = "fullscreen",
})
hl.gesture({
	fingers = 4,
	direction = "horizontal",
	action = "workspace",
})
