hl.config = {
	animation = {
		enabled = true,
	},
}
--- Curves
hl.curve("springSnap", {
	type = "bezier",
	points = { { 0.18, 1.35 }, { 0.1, 1 } },
})
hl.curve("emphasizedIn", {
	type = "bezier",
	points = { { 0.04, 0.92 }, { 0.06, 1 } },
})
hl.curve("emphasizedOut", {
	type = "bezier",
	points = { { 0.35, 0 }, { 0.55, 1 } },
})
hl.curve("gentleDecel", {
	type = "bezier",
	points = { { 0, 0 }, { 0.08, 1 } },
})
hl.curve("sharpAccel", {
	type = "bezier",
	points = { { 0.42, 0 }, { 0.82, 0.12 } },
})
hl.curve("workspaceFly", {
	type = "bezier",
	points = { { 0.2, 1 }, { 0.32, 1 } },
})
hl.curve("overshootSoft", {
	type = "bezier",
	points = { { 0.3, 1.22 }, { 0.26, 0.98 } },
})
hl.curve("menuOpen", {
	type = "bezier",
	points = { { 0.06, 1 }, { 0, 1 } },
})
hl.curve("menuClose", {
	type = "bezier",
	points = { { 0.5, 0 }, { 0.78, 0.08 } },
})

--- Animations
hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 3.0,
	bezier = "emphasizedIn",
	style = "popin 82%",
})
hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 1.9,
	bezier = "emphasizedOut",
	style = "popin 88%",
})
hl.animation({
	leaf = "windowsMove",
	enabled = true,
	speed = 2.8,
	bezier = "workspaceFly",
	style = "slide",
})
hl.animation({
	leaf = "fadeIn",
	enabled = true,
	speed = 3.0,
	bezier = "emphasizedIn",
})
hl.animation({
	leaf = "fadeOut",
	enabled = true,
	speed = 1.9,
	bezier = "sharpAccel",
})
hl.animation({
	leaf = "border",
	enabled = true,
	speed = 7,
	bezier = "gentleDecel",
})
hl.animation({
	leaf = "layersIn",
	enabled = true,
	speed = 2.6,
	bezier = "emphasizedIn",
	style = "popin 90%",
})
hl.animation({
	leaf = "layersOut",
	enabled = true,
	speed = 1.8,
	bezier = "menuClose",
	style = "popin 93%",
})
hl.animation({
	leaf = "fadeLayersIn",
	enabled = true,
	speed = 2.6,
	bezier = "menuOpen",
})
hl.animation({
	leaf = "fadeLayersOut",
	enabled = true,
	speed = 1.8,
	bezier = "sharpAccel",
})
hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 7.5,
	bezier = "workspaceFly",
	style = "slide",
})
hl.animation({
	leaf = "specialWorkspaceIn",
	enabled = true,
	speed = 2.8,
	bezier = "overshootSoft",
	style = "slidevert",
})
hl.animation({
	leaf = "specialWorkspaceOut",
	enabled = true,
	speed = 1.6,
	bezier = "sharpAccel",
	style = "slidevert",
})
hl.animation({
	leaf = "zoomFactor",
	enabled = true,
	speed = 3.0,
	bezier = "gentleDecel",
})
