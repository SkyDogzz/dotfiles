# Dotfiles

Minimal dotfiles for my Arch + Hyprland setup. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Included

- `hypr` — Hyprland, hypridle, hyprlock, hyprpaper, and helper scripts (Catppuccin Mocha border/window colors)
- `kitty` — terminal (Catppuccin Mocha theme)
- `waybar` — status bar (Catppuccin Mocha colors)
- `rofi` — launcher (Catppuccin Mocha theme)
- `firefox` — Firefox UI and built-in pages (Catppuccin Mocha, fully dotfiles-based)
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
- `scripts/ollama-tools` — local CLI tool loop for Ollama models
- `scripts/update-system` — system upgrade helper for Arch
- `scripts/configure-hotspot` — enable automatic reconnect for the iPhone hotspot
- `scripts/stow-healthcheck` — dry-run Stow validation across packages
- `scripts/check-symlinks` — verify symlinks point back to the repo
- `scripts/dotfiles-doctor` — diagnostics for commands, symlinks, and Hyprland helpers
- `scripts/stowctl/` — C++ ncurses TUI for Stow package management
- `.agents/` — opencode subagents
- `ai-models.md` — local AI model references
- `LOCAL-FILES.md` — generated files and local override conventions
- `packages.md` — Arch Linux prerequisites for this repo
- `projects/` — per-project overrides

## Quick Start

- `make bootstrap` — apply packages, regenerate completions, and run the main checks
- `make check` — run the health checks and diagnostics
- `make doctor` — run the repo-wide diagnostics directly

## Notes

- Run `./scripts/configure-hotspot` once to configure the saved NetworkManager profile `iPhone de Thomas (2)`. Pass a different connection name as the first argument if needed. If permission is denied, run it with `sudo`. NetworkManager stores these settings outside the Stow-managed dotfiles; run the helper again on a new machine after saving the hotspot connection.
- All apps follow the `XDG` layout under their respective directory.
- Some configs assume Wayland tools like `wl-clipboard`, `brightnessctl`, and `wpctl`.
- Hyprland starts desktop helpers directly from its config.
- The Firefox package targets the `default-release` profile folder; rename that directory if your profile uses a different name.
