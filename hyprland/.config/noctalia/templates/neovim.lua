-- ~/.config/noctalia/templates/neovim.lua
return {
	-- UI Backgrounds
	bg = "{{colors.surface.default.hex}}",
	bg_float = "{{colors.surface_container_high.default.hex}}",
	bg_alt = "{{colors.surface_container.default.hex}}",

	-- UI Foregrounds
	fg = "{{colors.on_surface.default.hex}}",
	fg_dim = "{{colors.on_surface_variant.default.hex}}",
	fg_light = "{{colors.on_background.default.hex}}",
	border = "{{colors.outline.default.hex}}",

	-- BASE FAMILIES
	primary = "{{colors.primary.default.hex}}",
	primary_bold = "{{colors.primary.default.hex | saturate: 10 | auto_lightness: -10}}",
	primary_muted = "{{colors.primary.default.hex | desaturate: 20 | auto_lightness: 20}}",

	secondary = "{{colors.secondary.default.hex}}",
	secondary_bold = "{{colors.secondary.default.hex | saturate: 10 | auto_lightness: -10}}",
	secondary_muted = "{{colors.secondary.default.hex | desaturate: 20 | auto_lightness: 20}}",

	tertiary = "{{colors.tertiary.default.hex}}",
	tertiary_bold = "{{colors.tertiary.default.hex | saturate: 10 | auto_lightness: -10}}",
	tertiary_muted = "{{colors.tertiary.default.hex | desaturate: 20 | auto_lightness: 20}}",

	error = "{{colors.error.default.hex}}",
	error_bold = "{{colors.error.default.hex | saturate: 10 | auto_lightness: -10}}",
	error_muted = "{{colors.error.default.hex | desaturate: 20 | auto_lightness: 20}}",

	-- PROCEDURAL FAMILIES

	-- VARIABLES: Triadic Split (Shifted 120° from Primary)
	variable = "{{colors.primary.default.hex | rotate_hue: 120}}",
	variable_bold = "{{colors.primary.default.hex | rotate_hue: 120 | saturate: 10 | auto_lightness: -10}}",
	variable_muted = "{{colors.primary.default.hex | rotate_hue: 120 | desaturate: 30 | auto_lightness: 20}}",

	-- CONSTANTS: Complementary Split (Shifted 180° from Primary)
	constant = "{{colors.primary.default.hex | rotate_hue: 180}}",
	constant_bold = "{{colors.primary.default.hex | rotate_hue: 180 | saturate: 10 | auto_lightness: -10}}",
	constant_muted = "{{colors.primary.default.hex | rotate_hue: 180 | desaturate: 30 | auto_lightness: 20}}",

	-- DIAGNOSTICS
	diag_warn = "{{colors.primary.default.hex | rotate_hue: 60 | saturate: 20 | auto_lightness: -10}}",
	diag_info = "{{colors.primary.default.hex | rotate_hue: -60 | saturate: 20 | auto_lightness: -10}}",
	diag_hint = "{{colors.secondary.default.hex | auto_lightness: 20}}",
}
