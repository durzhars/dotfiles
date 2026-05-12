local primary = "{{colors.primary.default.hex}}"
local secondary = "{{colors.surface.default.hex}}"
local tertiary = "{{colors.tertiary.default.hex}}"
local surface = "{{colors.surface.default.hex}}"
local surfaceLowest = "{{colors.surface_container_lowest.default.hex}}"
local surfaceHighest = "{{colors.surface_container_highest.default.hex}}"
local error = "{{colors.error.default.hex}}"

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
