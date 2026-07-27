-- Fallback Hyprland Window Colors (Used when Noctalia auto-generator is not present)
if not hl then return end

local primary = "rgb(89b4fa)"
local secondary = "rgb(b4befe)"
local surface = "rgb(1e1e2e)"
local error = "rgb(f38ba8)"


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
