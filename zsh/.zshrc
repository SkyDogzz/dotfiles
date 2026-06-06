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
