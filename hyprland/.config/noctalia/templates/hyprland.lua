local primary = "rgb({{colors.primary.default.hex_stripped}})"
local secondary = "rgb({{colors.surface.default.hex_stripped}})"
local tertiary = "rgb({{colors.tertiary.default.hex_stripped}})"
local surface = "rgb({{colors.surface.default.hex_stripped}})"
local surfaceLowest = "rgb({{colors.surface_container_lowest.default.hex_stripped}})"
local surfaceHighest = "rgb({{colors.surface_container_highest.default.hex_stripped}})"
local error = "rgb({{colors.error.default.hex_stripped}})"

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
