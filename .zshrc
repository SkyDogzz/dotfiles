if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=( git zsh-syntax-highlighting zsh-autosuggestions )

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export FZF_DEFAULT_OPTS=" \
  --color=spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
  --color=selected-bg:#45475a \
  --multi"

source /usr/share/nvm/init-nvm.sh

alias ls="lsd"
alias ll="lsd -l"
alias la="lsd -la"
alias zshsource="source ~/.zshrc"

batclip() {
    { 
        for file in "$@"; do
            echo "File: $file"
            bat "$file"
            echo -e "\n"
        done 
    } | xclip -selection clipboard
}

silent() {
    "$@" >/dev/null 2>&1
}

hgrep() {
    history | rga "$1"
}

pingcheck() {
    for site in "$@"; do
        echo "Pinging $site..."
        ping -c 3 "$site" > /dev/null && echo "$site is up" || echo "$site is down"
    done
}
export PATH=$PATH:/home/skydogzz/.venv/bin
export PATH=$PATH:/home/skydogzz/.venv/bin
