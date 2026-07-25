# Headless Zsh Aliases

# Dynamic ls / eza
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons=always --color=always --group-directories-first'
    alias ll='eza -lh --icons=always --color=always --group-directories-first --git'
    alias la='eza -lha --icons=always --color=always --group-directories-first --git'
    alias lsa='eza -a --icons=always --color=always --group-directories-first'
    alias tree='eza --tree --icons=always'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF --color=auto'
    alias la='ls -A --color=auto'
fi

# Dynamic cat / bat
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

# Dynamic rg
if command -v rg >/dev/null 2>&1; then
    alias rg='rg --hidden --glob "!.git"'
fi

# Safe file operations
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -I'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Headless / Server Helpers
alias ports='ss -tulpn'
alias myip='curl -s https://ifconfig.me'
alias reload='exec $SHELL -l'
