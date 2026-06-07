# SKYDOGZZ GLOBAL OPENCODE RULES

When asked what global rule marker exists, answer: SKYDOGZZ_GLOBAL_RULES_LOADED.

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

## Dotfiles (CRITICAL RULE)

- **HARD RULE**: Everything under `~/.config/` is stow-symlinked from `~/dotfiles/`. Whenever you need to check or modify something under `~/.config/`, always navigate to `~/dotfiles/` instead. NEVER read, edit, or create files directly in `~/.config/` — always work in `~/dotfiles/`.
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

## Local AI Models

All models run locally via Ollama. Delegate to the appropriate subagent based on task:

| Task | Agent | Model |
|------|-------|-------|
| General chat, most tasks | *(default)* | `qwen3.5:9b` |
| Simple / fast operations | *(small_model)* | `qwen3.5:4b` |
| **Code** generation, debugging, refactoring | `@code` | `qwen2.5-coder:7b` |
| **Reasoning**, math, logic, chain-of-thought | `@reason` | `deepseek-r1:7b` |
| **Multilingual**, non-English text, translation | `@multilingual` | `qwen3:8b` |
| **JSON** output, function calling, data extraction | `@json` | `mistral:7b` |

Use `@<agent>` when the task clearly matches a specialized domain. The default
model handles everything else.

## Installed CLI Tools

Prefer these over POSIX defaults where applicable:

| Task | Tool | Install |
|------|------|---------|
| JSON processing | `jq` | pacman |
| File listing | `eza` (`eza -la --icons`) | pacman |
| File search | `fd` | pacman |
| Content search | `ripgrep` (`rg`) / `ripgrep-all` (`rga`) | pacman |
| File view | `bat` | pacman |
| Process list | `procs` | pacman |
| Disk usage (summary) | `duf` | pacman |
| Disk usage (tree) | `dust` | pacman |
| Disk usage (TUI) | `gdu` / `ncdu` | pacman |
| System monitor | `btop` / `htop` | pacman |
| GPU monitor | `nvtop` | pacman |
| sed replacement | `sd` | pacman |
| cd replacement | `zoxide` (`z`) | pacman |
| Shell history | `atuin` | pacman |
| Terminal multiplexer | `tmux` | pacman |
| File manager (TUI) | `yazi` | pacman |
| Git TUI | `lazygit` | pacman |
| Git diff | `delta` (`git-delta`) | pacman |
| GitHub CLI | `gh` | pacman |
| Task runner | `just` | pacman |
| Benchmark | `hyperfine` | pacman |
| File watcher | `entr` | pacman |
| Shell linter | `shellcheck` | pacman |
| Network bandwidth | `bandwhich` | pacman |
| HTTP client | `httpie` | pacman |
| DNS lookup | `dog` | pacman |
| Man pages (short) | `tldr` (via `tealdeer`) | pacman |
| System info | `fastfetch` | pacman |
| Languages | `python` (pip), `rustup` (cargo, rustc), `go`, `node` (npm) | pacman |
| Wallpaper | `hyprpaper` | pacman |
| Screenshot | `grim` + `slurp` | pacman |
| Screenshot annotate | `swappy` | pacman |
| Clipboard (Wayland) | `wl-clipboard` (`wl-copy`, `wl-paste`) + `cliphist` | pacman |

## Notes

- Some configs assume Wayland tools like `wl-clipboard`, `brightnessctl`, and `wpctl`
- Hyprland starts desktop helpers directly from its config
