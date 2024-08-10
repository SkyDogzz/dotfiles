starship init fish | source

# General Purpose Aliases
alias ll="ls -lh"
alias la="ls -lha"
alias gs="git status"
alias gcm="git commit -m"
alias gpu="git push"
alias gpom="git push origin master"
alias dcup="docker-compose up"
alias dcdown="docker-compose down"
alias cls="clear"
alias ..="cd .."
alias ...="cd ../.."
alias n="nvim"
alias e="exit"
alias c="clear"

# Advanced Aliases
alias mkcd="function mkcd; mkdir -p \$argv; and cd \$argv; end;"
alias histg="history | grep"
alias ff="find . -type f -name"
alias weather="curl wttr.in"
