# Dotfiles

Minimal dotfiles for my Arch + Hyprland setup. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Included

- `hypr` — Hyprland, hypridle, hyprlock, hyprpaper configs and helper scripts
- `kitty` — terminal configuration
- `waybar` — status bar
- `rofi` — launcher theme
- `dunst` — notification daemon
- `udiskie` — automount setup
- `nvim` — Neovim editor settings
- `zsh` — Zsh config, Starship prompt, atuin, fzf
- `bat` — Catppuccin Mocha theme with custom config
- `gitconfig` — Git aliases and user config
- `opencode` — opencode AI coding assistant config
- `scripts` — custom utility scripts
- `.agents/` — opencode subagents
- `ai-models.md` — local AI model references
- `projects/` — per-project overrides

## Notes

- All apps follow the `XDG` layout under their respective directory.
- Some configs assume Wayland tools like `wl-clipboard`, `brightnessctl`, and `wpctl`.
- Hyprland starts desktop helpers directly from its config.
