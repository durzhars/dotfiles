local primary = "rgb(9ecaff)"
local secondary = "rgb(111417)"
local tertiary = "rgb(f0b0fc)"
local surface = "rgb(111417)"
local surfaceLowest = "rgb(0c0e12)"
local surfaceHighest = "rgb(323539)"
local error = "rgb(ffb4ab)"

hl.config({
	general = {
		col = {
			active_border = {
				colors = { primary, secondary },
				angle = 80,
			},
		},
	},
	group = {
		col = {
			border_active = { colors = { secondary } },
			border_inactive = { colors = { surface } },
			border_locked_active = { colors = { error } },
			border_locked_inactive = { colors = { surface } },
		},
		groupbar = {
			col = {
				active = secondary,
				inactive = surface,
				locked_active = error,
				locked_inactive = surface,
			},
		},
	},
})

hl.layer_rule({
	name = "noctalia",
	match = {
		namespace = "^noctalia-(bar-.+|notification|dock|panel)$",
	},
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})
