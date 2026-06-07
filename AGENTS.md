# SKYDOGZZ GLOBAL CODEX RULES

# ═══════════════════════════════════════════════════════════════════════
#  ▌ HARD RULES — CODING ▌
# ═══════════════════════════════════════════════════════════════════════
#  - Always check existing patterns (conventions, imports, style)
#    before writing new code.
#  - Verify with tests / lint / typecheck after making changes
#    when the project provides them.
#  - Keep changes narrow and avoid unnecessary refactors.
# ═══════════════════════════════════════════════════════════════════════

## User Profile

- **Name**: SkyDogzz
- **OS**: Arch Linux
- **WM/DE**: Hyprland (Wayland)
- **Shell**: Zsh + Starship prompt
- **Terminal**: Kitty
- **Editor**: Neovim
- **Languages**: C, C++, and others as needed

## Dotfiles

- Everything under `~/.config/` is stow-symlinked from `~/dotfiles/`.
- When you need to inspect or modify something under `~/.config/`, work in `~/dotfiles/` instead.
- Managed with GNU Stow in the form `~/dotfiles/<app>/.config/<app>/...`.
- For this repo, `opencode` lives under `dotfiles/opencode/.config/opencode/`.
- `~/dotfiles/.agents/` is available at the repo root for shared agent prompts.

## Workflow Preferences

- Keep the implementation simple.
- Follow the existing repository conventions.
- Prefer conventional commit messages when committing.
- Ask before dangerous operations such as force pushes or destructive deletes.

## Useful CLI Tools

- `jq` for JSON.
- `eza` for listing.
- `fd` for file search.
- `rg` for content search.
- `bat` for file viewing.
- `procs`, `duf`, `dust`, `btop`, `htop`, `nvtop`, `z`, `just`, `lazygit`, `gh`, `stow`.

## Notes

- Prefer Wayland-native tools where relevant.
- If a task depends on files or conventions in this repository, inspect the current layout first.
