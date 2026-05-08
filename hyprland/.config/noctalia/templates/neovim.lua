return {
	-- UI Backgrounds
	bg = "{{colors.surface.default.hex}}", -- Default Background
	bg_float = "{{colors.surface_container_high.default.hex}}", -- Selection
	bg_alt = "{{colors.surface_container.default.hex}}", -- Status Bars, etc.
	-- UI Foregrounds
	fg = "{{colors.on_surface.default.hex}}",
	fg_dim = "{{colors.on_surface_variant.default.hex}}", -- For comments and line numbers
	fg_light = "{{colors.on_background.default.hex}}",
	border = "{{colors.outline.default.hex}}",
	-- Syntax Accents
	error = "{{colors.error.default.hex}}",
	primary = "{{colors.primary.default.hex}}", -- Keywords, Functions
	secondary = "{{colors.secondary.default.hex}}", -- Strings, Types
	tertiary = "{{colors.tertiary.default.hex}}", -- Variables, Parameters
	warning = "{{colors.primary.default.hex | blend '#ff9900', 50 | auto_lightness 30}}",
	info = "{{colors.primary.default.hex | auto_lightness 40}}",
	secondary_dim = "{{colors.secondary.default.hex | auto_lightness 15}}",
}
