export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/dotfiles}"

export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export MANPAGER='less -R'
export LESSHISTFILE=-
export BROWSER=firefox

export GOPATH="$XDG_DATA_HOME/go"
export GOBIN="$HOME/.local/bin"
export GOMODCACHE="$XDG_CACHE_HOME/go/mod"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

export PATH="$HOME/.local/bin:$CARGO_HOME/bin:$PNPM_HOME:$PATH"

export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export SDL_VIDEODRIVER=wayland
