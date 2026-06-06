# Created by newuser for 5.9.1
bindkey -M emacs '^[[1;5D' backward-word
bindkey -M emacs '^[[1;5C' forward-word
bindkey -M viins '^[[1;5D' backward-word
bindkey -M viins '^[[1;5C' forward-word
bindkey -M emacs '^A' beginning-of-line
bindkey -M emacs '^E' end-of-line
bindkey -M emacs '^U' kill-whole-line
bindkey -M emacs '^W' backward-kill-word
bindkey -M emacs '^R' history-incremental-search-backward
bindkey -M emacs '^[[3~' delete-char
bindkey -M emacs '^[[H' beginning-of-line
bindkey -M emacs '^[[F' end-of-line

setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt HIST_VERIFY

alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias grep='grep --color=auto'

# atuin shell history
eval "$(atuin init zsh --disable-up-arrow)" 2>/dev/null

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
typeset -g STARSHIP_TRANSIENT_PROMPT='$(/usr/local/bin/starship module character)'
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
