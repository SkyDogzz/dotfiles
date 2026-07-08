# System Prerequisites

This repo targets Arch Linux. The list below is the practical baseline for the configs and scripts in this tree.

## Core

- `stow`
- `git`
- `zsh`
- `starship`
- `atuin`
- `fzf`
- `delta`
- `jq`
- `bat`
- `eza`
- `fd`
- `ripgrep`
- `just`
- `kitty`
- `nvim`
- `lazygit`
- `yazi`

## Desktop

- `hyprland`
- `hyprpaper`
- `hyprlock`
- `hypridle`
- `waybar`
- `rofi`
- `dunst`
- `udiskie`
- `firefox`

## Wayland Utilities

- `wl-clipboard`
- `grim`
- `slurp`
- `swappy`
- `brightnessctl`
- `playerctl`
- `cliphist`
- `wpctl` via PipeWire / WirePlumber

## Networking and Device Helpers

- `iw`
- `iwgtk`

## AI / Local Tools

- `codex`
- `opencode`
- `ollama`

## Build Tools

- `base-devel`
- `cmake`
- `ninja`
- `gcc`
- `ncurses`

## Bootstrap

A minimal Arch install command for the pieces above looks like this:

```bash
sudo pacman -S --needed \
  stow git zsh starship atuin fzf delta jq bat eza fd ripgrep just kitty nvim \
  lazygit yazi hyprland hyprpaper hyprlock hypridle waybar rofi dunst udiskie \
  firefox wl-clipboard grim slurp swappy brightnessctl playerctl cliphist iw \
  iwgtk base-devel cmake ninja gcc ncurses
```

`codex`, `opencode`, and `ollama` may come from other package sources depending on how you install them.
