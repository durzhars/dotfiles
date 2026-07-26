local primary = "rgb(0059bc)"
local secondary = "rgb(f9f9ff)"
local tertiary = "rgb(8b32ab)"
local surface = "rgb(f9f9ff)"
local surfaceLowest = "rgb(ffffff)"
local surfaceHighest = "rgb(e0e2ec)"
local error = "rgb(ba1a1a)"

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
