# Dotfiles

Minimal dotfiles for my Arch + Hyprland setup. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Included

- `hypr` — Hyprland, hypridle, hyprlock, hyprpaper, and helper scripts (Catppuccin Mocha border/window colors)
- `kitty` — terminal (Catppuccin Mocha theme)
- `waybar` — status bar (Catppuccin Mocha colors)
- `rofi` — launcher (Catppuccin Mocha theme)
- `dunst` — notification daemon
- `udiskie` — automount setup
- `nvim` — Neovim editor settings (catppuccin/nvim)
- `zsh` — Zsh config, Starship prompt, atuin, fzf (Catppuccin Mocha)
- `bat` — Catppuccin Mocha theme with custom config
- `btop` — system monitor (Catppuccin Mocha theme)
- `lazygit` — Git TUI (Catppuccin Mocha theme)
- `gitconfig` — Git aliases, delta config (Catppuccin Mocha)
- `opencode` — opencode AI coding assistant config
- `scripts` — custom utility scripts
- `scripts/stow-all` — apply all Stow packages except ignored ones
- `scripts/gen-completions` — generate shell completions for installed tools
- `scripts/check-ai-models.sh` — check local Ollama model availability
- `scripts/update-system` — system upgrade helper for Arch
- `scripts/stow-healthcheck` — dry-run Stow validation across packages
- `scripts/check-symlinks` — verify symlinks point back to the repo
- `scripts/dotfiles-doctor` — diagnostics for commands, symlinks, and Hyprland helpers
- `scripts/stowctl/` — C++ ncurses TUI for Stow package management
- `.agents/` — opencode subagents
- `ai-models.md` — local AI model references
- `projects/` — per-project overrides

## Notes

- All apps follow the `XDG` layout under their respective directory.
- Some configs assume Wayland tools like `wl-clipboard`, `brightnessctl`, and `wpctl`.
- Hyprland starts desktop helpers directly from its config.
