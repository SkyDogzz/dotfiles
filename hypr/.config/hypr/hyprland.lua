-- Hyprland 0.55+ Lua configuration.
-- API examples and option names follow the official Hyprland Lua example:
-- https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua

local terminal = "kitty"
local fileManager = "dolphin"
local menu = "/home/skydogzz/dotfiles/hypr/.config/hypr/scripts/rofi-launcher.sh"
local editor = "nvim"
local scripts = "/home/skydogzz/dotfiles/hypr/.config/hypr/scripts/"
local mainMod = "SUPER"

-- Monitor layout (converted from the former hyprmonitors.conf).
hl.monitor({
    output = "eDP-2",
    mode = "2560x1600@165",
    position = "0x0",
    scale = 1.3333333333,
})

-- Catppuccin Mocha theme and desktop defaults.
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("XCURSOR_THEME", "breeze-dark")
hl.env("XCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 18,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(89b4faff)", "rgba(cba6f7ff)" }, angle = 45 },
            inactive_border = "rgba(45475add)",
        },
        resize_on_border = true,
    },
    decoration = {
        rounding = 10,
        active_opacity = 0.98,
        inactive_opacity = 0.92,
        shadow = {
            enabled = true,
            range = 10,
            render_power = 3,
            color = "rgba(00000077)",
        },
        blur = {
            enabled = true,
            size = 5,
            passes = 2,
            vibrancy = 0.15,
        },
    },
    animations = { enabled = true },
    misc = {
        background_color = "0x11111b",
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

-- Window rules converted from hyprrules.conf. Rule properties go in match;
-- effects are fields alongside match per the official Lua rule API.
local function windowRule(name, match, effects)
    effects.name = name
    effects.match = match
    hl.window_rule(effects)
end

windowRule("iwgtk-float", { class = "^(org\\.twosheds\\.iwgtk|iwgtk)$" }, { float = true })
windowRule("iwgtk-center", { class = "^(org\\.twosheds\\.iwgtk|iwgtk)$" }, { center = true })
windowRule("blueberry-float", { class = "^(blueberry\\.py|Blueberry\\.py)$" }, { float = true })
windowRule("blueberry-center", { class = "^(blueberry\\.py|Blueberry\\.py)$" }, { center = true })
windowRule("tecla-float", { class = "^org\\.gnome\\.Tecla$" }, { float = true })
windowRule("tecla-size", { class = "^org\\.gnome\\.Tecla$" }, { size = { 1100, 420 } })
windowRule("tecla-center", { class = "^org\\.gnome\\.Tecla$" }, { center = true })
windowRule("tecla-opacity", { class = "^org\\.gnome\\.Tecla$" }, { opacity = "0.92 override 0.88 override" })
windowRule("pavucontrol", { initial_class = "^(pavucontrol|Pavucontrol|org\\.pulseaudio\\.pavucontrol)$" }, {
    float = true, center = true, size = { 1200, 700 },
})
windowRule("portal-float", { class = "^xdg-desktop-portal$" }, { float = true })
windowRule("wlogout-float", { class = "^wlogout$" }, { float = true })
windowRule("pip-float", { title = "^Picture-in-Picture$" }, { float = true })
windowRule("pip-center", { title = "^Picture-in-Picture$" }, { center = true })
windowRule("pip-pin", { title = "^Picture-in-Picture$" }, { float = true, pin = true })
windowRule("waybar-no-blur", { class = "^waybar$" }, { no_blur = true })
windowRule("rofi-no-blur", { class = "^rofi$" }, { no_blur = true })
windowRule("fullscreen-no-border", { fullscreen = true }, { border_size = 0 })

-- Desktop helpers are launched as external commands so shell logic stays out
-- of the compositor's Lua event loop.
hl.on("hyprland.start", function()
    hl.exec_cmd("pkill waybar || true; waybar")
    hl.exec_cmd(scripts .. "hyprmonitors")
    hl.exec_cmd("pkill udiskie || true; udiskie")
    hl.exec_cmd("pkill dunst || true; dunst")
    hl.exec_cmd("pkill wl-paste || true; wl-paste --watch cliphist store")
    hl.exec_cmd("pkill hypridle || true; if [ ! -f \"${XDG_CACHE_HOME:-$HOME/.cache}/hypr/caffeine\" ]; then hypridle; fi")
    hl.exec_cmd("hyprlock")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'")
end)

local function bind(key, command, options)
    hl.bind(key, hl.dsp.exec_cmd(command), options)
end

-- Application and window controls.
bind(mainMod .. " + Q", terminal)
bind(mainMod .. " + N", editor)
hl.bind(mainMod .. " + C", hl.dsp.window.close())
bind(mainMod .. " + M", "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit")
bind(mainMod .. " + E", fileManager)
bind(mainMod .. " + SHIFT + E", "wlogout")
bind(mainMod .. " + V", scripts .. "rofi-launcher.sh clipboard")
bind(mainMod .. " + SHIFT + V", scripts .. "clipboard-clear.sh clear")
bind(mainMod .. " + CTRL + SHIFT + V", scripts .. "clipboard-clear.sh wipe")
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
bind(mainMod .. " + R", menu)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
bind(mainMod .. " + SHIFT + L", "hyprlock")
bind(mainMod .. " + SHIFT + C", scripts .. "caffeine.sh toggle")
bind(mainMod .. " + P", scripts .. "hyprmonitors")
bind(mainMod .. " + SHIFT + P", scripts .. "low-power.sh toggle")
bind(mainMod .. " + W", scripts .. "wallpaper.sh next")
bind(mainMod .. " + SHIFT + W", scripts .. "rofi-launcher.sh wallpaper")
bind(mainMod .. " + CTRL + equal", scripts .. "zoom.sh in")
bind(mainMod .. " + CTRL + minus", scripts .. "zoom.sh out")
bind(mainMod .. " + CTRL + 0", scripts .. "zoom.sh reset")

-- Screenshots.
bind(mainMod .. " + S", scripts .. "screenshot.sh full")
bind(mainMod .. " + SHIFT + S", scripts .. "screenshot.sh region")
bind(mainMod .. " + CTRL + S", scripts .. "screenshot.sh window")
bind(mainMod .. " + ALT + S", scripts .. "screenshot.sh edit")

-- Media, audio, and brightness keys.
local lockedRepeating = { locked = true, repeating = true }
local locked = { locked = true }
bind("XF86AudioRaiseVolume", scripts .. "audio.sh up", lockedRepeating)
bind("XF86AudioLowerVolume", scripts .. "audio.sh down", lockedRepeating)
bind("XF86AudioMute", scripts .. "audio.sh mute", locked)
bind("XF86AudioMicMute", scripts .. "audio.sh mic-mute", locked)
bind("XF86AudioPlay", scripts .. "media.sh play-pause", locked)
bind("XF86AudioPause", scripts .. "media.sh play-pause", locked)
bind("XF86AudioNext", scripts .. "media.sh next", locked)
bind("XF86AudioPrev", scripts .. "media.sh previous", locked)
bind("XF86MonBrightnessUp", scripts .. "brightness.sh up", lockedRepeating)
bind("XF86MonBrightnessDown", scripts .. "brightness.sh down", lockedRepeating)

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move windows to workspaces silently with SUPER+ALT+number, switch with
-- SUPER+number, and move the focused window with SUPER+SHIFT+number.
for i = 1, 9 do
    hl.bind(mainMod .. " + ALT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
