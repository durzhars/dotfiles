_G.binder = require("modules.utils")
require("modules.generals")
require("modules.keybinds")
require("modules.windowrules")
require("modules.animations")
require("noctalia.noctalia-colors")

--- local active_animation = "silk"
--- require("modules.animations." .. active_animation)

hl.monitor({
    output = "",
    mode = "1920x1200@60",
    position = "0x0",
    bitdepth = 10,
})

hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -- /usr/lib/pam_kwallet_init")
    hl.exec_cmd("uwsm app -- /usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("uwsm app -- noctalia")
    hl.exec_cmd("echo 'Xft.dpi=128' | xrdb -merge")
end)
