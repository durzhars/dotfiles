alias ls='eza --icons=always --color=always --group-directories-first'
alias ll='eza -lh --icons=always --color=always --group-directories-first --git'
alias la='eza -lha --icons=always --color=always --group-directories-first --git'
alias lsa='eza -a --icons=always --color=always --group-directories-first'
alias tree='eza --tree --icons=always'

alias cp='cp -iv' # Prompt before overwrite, show what is being copied
alias mv='mv -iv' # Prompt before overwrite, show what is being moved
alias rm='rm -I'  # Prompts only if deleting >3 files or recursive (less annoying than -i)

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias icat='kitten icat'
alias cat='bat'

alias grep='rg --color=auto'
alias find='fd'
alias rg='rg --hidden --glob "!.git"'

[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"
