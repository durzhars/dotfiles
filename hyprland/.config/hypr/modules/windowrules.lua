binder.create_tags({
    matches = {
        { class = "^(org.freedesktop.impl.portal.*)$" },
        { class = "^(code|visual-studio-code-bin)$", title = "^(Open Folder|Save As|Extension.*)$" },
        { class = "^(steam)$", title = "^(Friends List|Steam - News|.*Settings.*)$" },
        { class = "^(com.obsproject.Studio)$", title = "^(Settings|Projector.*)$" },
        { modal = true },
    },
    rules = {
        tag = "+dialogs",
    },
})

hl.window_rule({
    name = "style_dialogs",
    match = { tag = "dialogs" },
    float = true,
    center = true,
    persistent_size = true,
})

-- ==========================================
-- SYSTEM FIXES & HYPRLAND NATIVES
-- ==========================================-

hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    float = true,
    move = { "20", "monitor_h-120" }, -- Expressions go in an array of strings
})

-- ==========================================
-- WORKSPACE DELEGATION
-- ==========================================

hl.window_rule({
    name = "terminals",
    match = { class = "^(kitty.*)$" },
    workspace = "1",
})

hl.window_rule({
    name = "browsers",
    match = { class = "^(brave.*)$" },
    workspace = "2",
})

hl.window_rule({
    name = "libreoffice",
    match = { class = "(.*libreoffice-.*)" },
    workspace = "3",
    opaque = true,
})

hl.window_rule({
    name = "media_viewers",
    match = { class = "^(mpv|feh)$" },
    float = true, -- Translated from `tile = off`
    center = true,
    opaque = true,
    workspace = "4",
})

hl.window_rule({
    name = "game",
    match = { class = "^(steam_proton|steam_app.*)$" },
    fullscreen = true,
    opaque = true,
    workspace = "9 silent", -- Silent keyword stays inside the string
})

hl.window_rule({
    name = "fix_gimp",
    match = { class = "^(gimp)$" },
    float = true,
})

-- ==========================================
-- ANONYMOUS RULES (Evaluated Last)
-- ==========================================

-- Main GIMP Window (Combined your two separate rules into one!)
hl.window_rule({
    match = { class = "^(gimp)$", title = "(.*GNU Image Manipulation Program.*)" },
    tile = true,
    maximize = true,
    opaque = true,
})

-- Brave DevTools
hl.window_rule({
    match = { class = "^(brave.*)$", title = "^(DevTools.*|Untitled.*)$" },
    float = true,
    center = true,
    size = { 500, 750 }, -- Absolute coordinates can be passed as numbers
})

-- Universal Floating Rules (Catch-all)
hl.window_rule({
    match = { float = true },
    center = true,
    persistent_size = false,
})
