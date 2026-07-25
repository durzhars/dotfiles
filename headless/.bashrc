#
# ~/.bashrc — Headless Terminal Session Configuration
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# =============================================================================
# Environment & XDG Base Directories
# =============================================================================

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# History Configuration (XDG-compliant)
mkdir -p "$XDG_STATE_HOME/bash"
HISTFILE="$XDG_STATE_HOME/bash/history"
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:ll:la:cd:pwd:exit:clear:history"
shopt -s histappend

# Core Shell Options
shopt -s autocd 2>/dev/null
shopt -s cdspell 2>/dev/null
shopt -s nocaseglob 2>/dev/null
shopt -s checkwinsize
shopt -s globstar 2>/dev/null
bind 'set bell-style none' 2>/dev/null

# Safe Default Apps & Terminal
if command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    export SUDO_EDITOR="nvim"
elif command -v vim >/dev/null 2>&1; then
    export EDITOR="vim"
    export SUDO_EDITOR="vim"
else
    export EDITOR="vi"
    export SUDO_EDITOR="vi"
fi

# Fallback TERM for headless SSH / TTY sessions if generic or unset
if [[ -z "$TERM" || "$TERM" == "dumb" ]]; then
    export TERM="xterm-256color"
fi

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# =============================================================================
# Modern CLI Integrations — fzf + fd + bat + eza + rg
# =============================================================================

if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --exclude .git'
fi

if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
fi

if command -v eza >/dev/null 2>&1; then
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
fi

# =============================================================================
# Completion & Keybindings
# =============================================================================

if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
elif [[ -r /etc/bash_completion ]]; then
    source /etc/bash_completion
fi

bind 'set completion-ignore-case on' 2>/dev/null
bind 'set show-all-if-ambiguous on' 2>/dev/null
bind 'set colored-stats on' 2>/dev/null
bind 'set mark-directories on' 2>/dev/null

# =============================================================================
# Aliases
# =============================================================================

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

if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

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

# Headless / Server Utilities
alias ports='ss -tulpn'
alias myip='curl -s https://ifconfig.me'
alias reload='exec $SHELL -l'

# =============================================================================
# Integrations
# =============================================================================

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash 2>/dev/null)"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash 2>/dev/null)"
fi
