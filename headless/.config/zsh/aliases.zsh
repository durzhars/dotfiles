# Headless Zsh Aliases (Dynamic Multi-Device Architecture)

# Dynamic ls / eza / exa
if (( $+commands[eza] )); then
    alias ls='eza --icons=always --color=always --group-directories-first'
    alias ll='eza -lh --icons=always --color=always --group-directories-first --git'
    alias la='eza -lha --icons=always --color=always --group-directories-first --git'
    alias lsa='eza -a --icons=always --color=always --group-directories-first'
    alias tree='eza --tree --icons=always'
elif (( $+commands[exa] )); then
    alias ls='exa --icons=always --color=always --group-directories-first'
    alias ll='exa -lh --icons=always --color=always --group-directories-first --git'
    alias la='exa -lha --icons=always --color=always --group-directories-first --git'
    alias lsa='exa -a --icons=always --color=always --group-directories-first'
    alias tree='exa --tree --icons=always'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF --color=auto'
    alias la='ls -A --color=auto'
    alias lsa='ls -A --color=auto'
fi

# Dynamic cat / bat / batcat
if (( $+commands[bat] )); then
    alias cat='bat'
elif (( $+commands[batcat] )); then
    alias cat='batcat'
fi

# Dynamic rg / grep
if (( $+commands[rg] )); then
    alias rg='rg --hidden --glob "!.git"'
else
    alias grep='grep --color=auto'
fi

# Dynamic fd / fdfind
if ! (( $+commands[fd] )) && (( $+commands[fdfind] )); then
    alias fd='fdfind'
fi

# Process monitors
if (( $+commands[btop] )); then
    alias top='btop'
elif (( $+commands[htop] )); then
    alias top='htop'
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
alias ports='ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null || lsof -i'
alias myip='curl -s https://ifconfig.me || curl -s https://api.ipify.org'
alias reload='exec $SHELL -l'
alias meminfo='free -m -l -t 2>/dev/null || top -l 1 | head -n 10'
alias diskinfo='df -hT 2>/dev/null || df -h'


