return {
	-- UI Backgrounds
	bg = "{{colors.surface.default.hex}}",
	bg_alt = "{{colors.surface_variant.default.hex}}", -- For popups, sidebars, active lines
	bg_float = "{{colors.surface_container_high.default.hex}}", -- For floating windows
	-- UI Text & Borders
	fg = "{{colors.on_surface.default.hex}}",
	fg_dim = "{{colors.on_surface_variant.default.hex}}", -- For comments and line numbers
	border = "{{colors.outline.default.hex}}",
	-- Syntax Accents
	primary = "{{colors.primary.default.hex}}", -- Keywords, Functions
	secondary = "{{colors.secondary.default.hex}}", -- Strings, Types
	tertiary = "{{colors.tertiary.default.hex}}", -- Variables, Parameters
	-- Diagnostics
	error = "{{colors.error.default.hex}}",
	warning = "{{colors.tertiary_fixed.default.hex}}",
	info = "{{colors.primary_fixed.default.hex}}",
}
