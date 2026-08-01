hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        resize_on_border = true,
        allow_tearing = true,
        snap = {
            enabled = true,
            window_gap = 6,
            respect_gaps = true,
        },
    },
    decoration = {
        rounding = 8,
        rounding_power = 2.5,
        active_opacity = 0.9,
        inactive_opacity = 0.86,
        shadow = {
            enabled = true,
            range = 5,
            render_power = 5,
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 5,
            vibrancy = 0.1696,
        },
    },
    input = {
        kb_layout = "us",
        repeat_rate = 25,
        repeat_delay = 150,
        follow_mouse = 2,
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
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$",
    },
    blur = true,
    ignore_alpha = 0.55,
    blur_popups = true,
})
