_G.binder = require("modules.utils")
require("modules.generals")
require("modules.keybinds")
require("modules.windowrules")
require("modules.animations")
require("modules.layouts")
if not pcall(require, "noctalia.noctalia-colors") then
    pcall(require, "noctalia.fallback-colors")
end

--- local active_animation = "silk"
--- require("modules.animations." .. active_animation)

hl.monitor({
    output = "eDP-1",
    mode = "1920x1200@60",
    position = "0x0",
    scale = 1,
    bitdepth = 10,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "2560x1440@59.95",
    position = "1920x0",
})

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- /usr/lib/pam_kwallet_init")
    hl.exec_cmd("uwsm app -- /usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("uwsm app -- noctalia")
    hl.exec_cmd("echo 'Xft.dpi=128' | xrdb -merge")
end)
