hl.config({
    general = {
        gaps_in = 1,
        gaps_out = 1,
        border_size = 1,
        resize_on_border = true,
        allow_tearing = true,
        layout = "dwindle",
        snap = {
            enabled = true,
            window_gap = 6,
            respect_gaps = true,
        },
    },
    decoration = {
        rounding = 1,
        rounding_power = 2.5,
        active_opacity = 0.95,
        inactive_opacity = 0.8,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 5,
            passes = 3,
            vibrancy = 0.1696,
        },
    },
    input = {
        kb_layout = "us",
        repeat_rate = 25,
        repeat_delay = 150,
        follow_mouse = 1,
        touchpad = {
            natural_scroll = true,
        },
    },
    xwayland = {
        force_zero_scaling = true,
    },
    binds = {
        workspace_back_and_forth = true,
    },
})

hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "noctalia-background-.*$",
    },
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})
