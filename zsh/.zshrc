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

eval "$(starship init zsh)"
