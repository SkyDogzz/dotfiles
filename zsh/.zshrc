# Created by newuser for 5.9.1
bindkey -e
bindkey_emacs() {
  bindkey -M emacs "$1" "$2"
}

bindkey_emacs '^[[1;5D' backward-word
bindkey_emacs '^[[1;5C' forward-word
bindkey_emacs '^[[1;3D' backward-word
bindkey_emacs '^[[1;3C' forward-word
bindkey_emacs '^[b' backward-word
bindkey_emacs '^[f' forward-word
bindkey_emacs '^A' beginning-of-line
bindkey_emacs '^E' end-of-line
bindkey_emacs '^U' kill-whole-line
bindkey_emacs '^W' backward-kill-word
bindkey_emacs '^H' backward-delete-char
bindkey_emacs '^?' backward-delete-char
bindkey_emacs '^[[8;5~' backward-kill-word
bindkey_emacs '^[[127;5~' backward-kill-word
bindkey_emacs '^[^?' backward-kill-word
bindkey_emacs '^[[3;3~' kill-word
bindkey_emacs '^[[3;5~' kill-word
bindkey_emacs '^[[3~' delete-char
bindkey_emacs '^R' history-incremental-search-backward
bindkey_emacs '^[[H' beginning-of-line
bindkey_emacs '^[[F' end-of-line

insert-newline() {
  LBUFFER+=$'\n'
}

zle -N insert-newline
bindkey_emacs '^N' insert-newline

export EDITOR=nvim

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_VERIFY
setopt INTERACTIVE_COMMENTS
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt CORRECT

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias grep='grep --color=auto'

alias stow-all="$DOTFILES_ROOT/scripts/stow-all"

# atuin shell history (ctrl-r only, not up-arrow)
eval "$(atuin init zsh --disable-up-arrow)" 2>/dev/null
# Keep cursor at end of line when recalling history with arrow keys.
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

# Restore default up/down-arrow bindings in case old atuin bindings linger
bindkey -M emacs '^[[A' history-beginning-search-backward-end
bindkey -M emacs '^[OA' history-beginning-search-backward-end
bindkey -M emacs '^[[B' history-beginning-search-forward-end
bindkey -M emacs '^[OB' history-beginning-search-forward-end
bindkey -M viins '^[[A' history-beginning-search-backward-end
bindkey -M viins '^[OA' history-beginning-search-backward-end
bindkey -M viins '^[[B' history-beginning-search-forward-end
bindkey -M viins '^[OB' history-beginning-search-forward-end
bindkey -M vicmd '^[[A' history-beginning-search-backward-end
bindkey -M vicmd '^[OA' history-beginning-search-backward-end
bindkey -M vicmd '^[[B' history-beginning-search-forward-end
bindkey -M vicmd '^[OB' history-beginning-search-forward-end

# fzf Catppuccin Mocha theme
export FZF_DEFAULT_OPTS=" \
  --color=fg:#cdd6f4,bg:#1e1e2e,hl:#f38ba8 \
  --color=fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8 \
  --color=info:#cba6f7,prompt:#89b4fa,pointer:#f5e0dc \
  --color=marker:#f5e0dc,spinner:#f5e0dc,header:#cba6f7"

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

for plugin in \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh \
  /usr/share/zsh/site-functions/zsh-autosuggestions.zsh
do
  if [[ -r "$plugin" ]]; then
    source "$plugin"
    break
  fi
done

eval "$(starship init zsh)"

typeset -g STARSHIP_FULL_PROMPT="$PROMPT"
typeset -g STARSHIP_FULL_RPROMPT="$RPROMPT"
typeset -g STARSHIP_TRANSIENT_PROMPT='$(starship module character)'
typeset -g STARSHIP_TRANSIENT_RPROMPT=''
typeset -g STARSHIP_TRANSIENT_ACTIVE=0

starship_transient_restore_prompt() {
  if (( STARSHIP_TRANSIENT_ACTIVE )); then
    PROMPT="$STARSHIP_FULL_PROMPT"
    RPROMPT="$STARSHIP_FULL_RPROMPT"
    STARSHIP_TRANSIENT_ACTIVE=0
  fi
}

starship_transient_line_finish() {
  STARSHIP_TRANSIENT_ACTIVE=1
  PROMPT="$STARSHIP_TRANSIENT_PROMPT"
  RPROMPT="$STARSHIP_TRANSIENT_RPROMPT"
  zle reset-prompt
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd starship_transient_restore_prompt
zle -N zle-line-finish starship_transient_line_finish

for plugin in \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh \
  /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh
do
  if [[ -r "$plugin" ]]; then
    source "$plugin"
    break
  fi
done

# zsh-syntax-highlighting Catppuccin Mocha theme
ZSH_HIGHLIGHT_STYLES+=(
  default                       'fg=#cdd6f4'
  unknown-token                 'fg=#f38ba8'
  reserved-word                 'fg=#cba6f7'
  suffix-alias                  'fg=#89b4fa'
  global-alias                  'fg=#89b4fa'
  precommand                    'fg=#fab387'
  commandseparator              'fg=#f9e2af'
  hashed-command                'fg=#89b4fa'
  autodirectory                 'fg=#fab387,bold'
  builtin                       'fg=#a6e3a1'
  function                      'fg=#89b4fa'
  command                       'fg=#89b4fa'
  alias                         'fg=#89b4fa'
  single-hyphen-option          'fg=#f5c2e7'
  double-hyphen-option          'fg=#f5c2e7'
  back-quoted-argument          'fg=#cba6f7'
  back-quoted-argument-unclosed 'fg=#f38ba8'
  single-quoted-argument        'fg=#f9e2af'
  double-quoted-argument        'fg=#f9e2af'
  dollar-quoted-argument        'fg=#f9e2af'
  rc-quotes                     'fg=#f9e2af'
  dollar-double-quoted-argument 'fg=#89b4fa'
  back-double-quoted-argument   'fg=#89b4fa'
  back-dollar-quoted-argument   'fg=#89b4fa'
  assign                        'fg=#cdd6f4'
  redirection                   'fg=#cba6f7'
  comment                       'fg=#6c7086'
  named-fd                      'fg=#cba6f7'
  numeric-fd                    'fg=#cba6f7'
  arg0                          'fg=#cdd6f4'
  path                          'fg=#cdd6f4'
  path_prefix                   'fg=#cdd6f4'
  path_approx                   'fg=#fab387'
)

# completion
autoload -Uz compinit
compinit

# Pre-generated completions — regen with: gen-completions
fpath+=~/.zsh/completions
# opencode
export PATH="$HOME/.opencode/bin:$PATH"

export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME/bin:$PNPM_HOME:$PATH"
