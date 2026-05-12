local fileManager = "dolphin"
local browser = "brave"
local screenshot = "~/.config/hypr/scripts/screenshot.sh"
local ipc = "qs -c noctalia-shell ipc call "
local terminal = "kitty"
local btop = "kitty -e btop"

local mainMod = "SUPER " -- Sets "Windows" key as main modifier
local dsp = hl.dsp
local cmd = dsp.exec_cmd
local win = dsp.window

-- TERMINAL APPS
binder.create_bind({
    keys = {
        mainMod .. "+ return",
        mainMod .. "+ SHIFT + return",
        mainMod .. "+ SHIFT + B",
    },
    exec = {
        cmd(terminal),
        cmd(terminal, {
            float = true,
            size = "800 600",
            center = true,
        }),
        cmd(btop, {
            float = true,
            size = "750 490",
            move = "15 55",
            no_initial_focus = true,
        }),
    },
})

-- APPLICATIONS
binder.create_bind({
    keys = {
        mainMod .. "+ SHIFT + S",
        mainMod .. "+ E",
        mainMod .. "+ B",
    },
    exec = {
        cmd(screenshot),
        cmd(fileManager),
        cmd(browser),
    },
})

-- SYSTEM
binder.create_bind({
    keys = {
        mainMod .. "+ D",
        mainMod .. "+ S",
        mainMod .. "+ X",
        mainMod .. "+ M",
        mainMod .. "+ W",
        mainMod .. "+ SHIFT + P",
    },
    exec = {
        cmd(ipc .. "launcher toggle"),
        cmd(ipc .. "settings toggle"),
        cmd(ipc .. "controlCenter toggle"),
        cmd(ipc .. "lockScreen lock"),
        cmd(ipc .. "wallpaper toggle"),
        cmd(ipc .. "sessionMenu toggle"),
    },
})

-- WINDOW MANAGEMENT
local closeWindowBind = hl.bind(mainMod .. " + Q", win.close())
closeWindowBind:set_enabled(true)

hl.bind(mainMod .. "+ mouse:272", win.drag())
hl.bind(mainMod .. "+ mouse:273", win.resize())

local directions = {
    { "left", "h", "l" },
    { "right", "l", "r" },
    { "up", "k", "u" },
    { "down", "j", "d" },
}

-- Window Movement
for _, map in ipairs(directions) do
    local arrow = map[1]
    local vim = map[2]
    local dir = map[3]

    binder.create_bind({
        keys = {
            { mainMod .. "+ " .. arrow, mainMod .. "+ " .. vim },
            { mainMod .. "+ SHIFT + " .. arrow, mainMod .. "+ SHIFT + " .. vim },
        },
        exec = {
            dsp.focus({ direction = dir }),
            win.move({ direction = dir }),
        },
    })
end

-- Resize Window
binder.create_bind({
    keys = {
        mainMod .. "+ ALT + right",
        mainMod .. "+ ALT + left",
        mainMod .. "+ ALT + up",
        mainMod .. "+ ALT + down",
        mainMod .. "+ bracketright",
        mainMod .. "+ bracketleft",
    },
    exec = {
        win.resize({ x = 20, y = 0, relative = true }),
        win.resize({ x = -20, y = 0, relative = true }),
        win.resize({ x = 0, y = -20, relative = true }),
        win.resize({ x = 0, y = 20, relative = true }),
        win.resize({ x = 20, y = 0, relative = true }), -- bracketright
        win.resize({ x = -20, y = 0, relative = true }), -- bracketleft
    },
    opts = { repeating = true },
})

-- Relative Workspaces (Scroll & Keys)
binder.create_bind({
    keys = {
        mainMod .. "+ mouse_down",
        mainMod .. "+ mouse_up",
        mainMod .. "+ period",
        mainMod .. "+ comma",
        mainMod .. "+ tab",
        mainMod .. "+ SHIFT + period",
        mainMod .. "+ SHIFT + comma",
    },
    exec = {
        dsp.focus({ workspace = "e+1" }), -- Scroll Next
        dsp.focus({ workspace = "e-1" }), -- Scroll Prev
        dsp.focus({ workspace = "r+1" }), -- Next
        dsp.focus({ workspace = "r-1" }), -- Prev
        dsp.focus({ workspace = "e+1" }), -- Tab Next
        win.move({ workspace = "r+1" }), -- Move to Next
        win.move({ workspace = "r-1" }), -- Move to Prev
    },
})

--- Layouts
binder.create_bind({
    keys = {
        mainMod .. "+ SPACE",
        mainMod .. "+ P",
        mainMod .. "+ J",
        mainMod .. "+ Y",
        mainMod .. "+ F",
        mainMod .. "+ SHIFT + F",
    },
    exec = {
        win.float({ action = "toggle" }),
        win.pseudo(),
        dsp.layout("togglesplit"),
        dsp.layout("scrolling"),
        win.fullscreen({
            mode = "maximized",
            action = "toggle",
        }),
        win.fullscreen({ action = "toggle" }),
    },
})

--- Workspace Movement
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    binder.create_bind({
        keys = {
            mainMod .. "+ " .. key,
            mainMod .. "+ SHIFT + " .. key,
            mainMod .. "+ CTRL + " .. key,
        },
        exec = {
            dsp.focus({ workspace = i }),
            win.move({ workspace = i, follow = true }),
            win.move({ workspace = i, follow = false }),
        },
    })
end

-- Volume & Brightness Control
binder.create_bind({
    keys = {
        "XF86AudioRaiseVolume",
        "XF86AudioLowerVolume",
        "XF86MonBrightnessUp",
        "XF86MonBrightnessDown",
        { "XF86AudioMute", mainMod .. "+ I" },
        { "XF86AudioNext", mainMod .. "+ O" },
        { "XF86AudioPrev", mainMod .. "+ U" },
    },
    exec = {
        cmd(ipc .. "volume increase"),
        cmd(ipc .. "volume decrease"),
        cmd(ipc .. "brightness increase"),
        cmd(ipc .. "brightness decrease"),
        cmd(ipc .. "media playPause"),
        cmd(ipc .. "media next"),
        cmd(ipc .. "media previous"),
    },
})
