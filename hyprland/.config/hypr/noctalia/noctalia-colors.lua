local primary = "#e5c449"
local secondary = "#15130e"
local tertiary = "#abd0b0"
local surface = "#15130e"
local surfaceLowest = "#100e09"
local surfaceHighest = "#37342e"
local error = "#ffb4ab"

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
