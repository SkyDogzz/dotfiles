# Global Memory

Always respond in English unless explicitly asked otherwise.

## User Profile

- **Name**: SkyDogzz
- **OS**: Arch Linux
- **WM/DE**: Hyprland (Wayland)
- **Shell**: Zsh + Starship prompt
- **Terminal**: Kitty
- **Editor**: Neovim
- **Languages**: C, C++, and others as needed

## Dotfiles

- Managed with **stow** — `~/dotfiles/<app>/.config/<app>/...`
- All opencode config lives under `dotfiles/opencode/.config/opencode/` (symlinked to `~/.config/opencode/`)
- Also uses: `dotfiles/.agents/` at the repo root for opencode agents

## Workflow Preferences

- **Coding style**: Thorough & detailed — explain what you're doing and why
- **Before coding**: Always check existing patterns and conventions in the codebase first
- **Dangerous operations** (git push --force, rm -rf, etc.): Always ask before executing
- **Commit style**: Conventional commits preferred (feat:, fix:, chore:, etc.)
- **Keep it simple**: Avoid over-engineering; prefer straightforward solutions

## Desktop Environment Details

- **Shell**: Zsh with autosuggestions, syntax highlighting, custom Starship transient prompt
- **Session**: Wayland (tools: wl-clipboard, brightnessctl, wpctl, cliphist)
- **Notifications**: dunst
- **Launcher**: rofi
- **Status bar**: waybar
- **Automount**: udiskie
- **TODO**: Screenshot helper, power menu, wallpaper switcher, network helper, media control, clipboard cleanup scripts

## Notes

- Some configs assume Wayland tools like `wl-clipboard`, `brightnessctl`, and `wpctl`
- Hyprland starts desktop helpers directly from its config
