#
# ~/.bashrc — Mirrors ~/.config/zsh/ config for Bash parity
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# =============================================================================
# Environment (mirrors env.zsh)
# =============================================================================

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# History Configuration (XDG-compliant: ~/.local/state/bash/history)
mkdir -p "$XDG_STATE_HOME/bash"
HISTFILE="$XDG_STATE_HOME/bash/history"
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups   # ignorespace + ignoredups + erase older dups
HISTIGNORE="ls:ll:la:cd:pwd:exit:clear:history"
shopt -s histappend                # Append to history, never overwrite

# Core Shell Options
shopt -s autocd         # cd into a directory by typing its name (like setopt AUTOCD)
shopt -s cdspell        # Auto-correct minor typos in cd arguments
shopt -s nocaseglob     # Case-insensitive globbing
shopt -s checkwinsize   # Update LINES/COLUMNS after each command
shopt -s globstar       # Enable ** recursive globbing
bind 'set bell-style none'  # Disable terminal bell (like setopt NOBEEP)

# Default Apps
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export TERM="xterm-kitty"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# =============================================================================
# Modern CLI Integrations — fzf + fd + bat + rg (mirrors env.zsh)
# =============================================================================

# 1. fzf Backend (Use fd instead of find)
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --exclude .git'

# 2. fzf Previews (Use bat and eza)
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# 3. Man Pages (Use bat as the pager)
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# =============================================================================
# Completion (mirrors plugins.zsh)
# =============================================================================

# Load bash-completion if available (Arch: pacman -S bash-completion)
if [[ -r /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
fi

# Case-insensitive tab completion (like zstyle matcher-list case-insensitive)
bind 'set completion-ignore-case on'
# Show all matches on ambiguous completion (like zstyle menu select)
bind 'set show-all-if-ambiguous on'
# Color completions by file type (like zstyle list-colors)
bind 'set colored-stats on'
# Append slash to directories on completion
bind 'set mark-directories on'
bind 'set mark-symlinked-directories on'

# =============================================================================
# Aliases (mirrors aliases.zsh)
# =============================================================================

# eza (modern ls replacement)
alias ls='eza --icons=always --color=always --group-directories-first'
alias ll='eza -lh --icons=always --color=always --group-directories-first --git'
alias la='eza -lha --icons=always --color=always --group-directories-first --git'
alias lsa='eza -a --icons=always --color=always --group-directories-first'
alias tree='eza --tree --icons=always'

# Safe file operations
alias cp='cp -iv'  # Prompt before overwrite, show what is being copied
alias mv='mv -iv'  # Prompt before overwrite, show what is being moved
alias rm='rm -I'   # Prompts only if deleting >3 files or recursive

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Modern tool replacements
alias icat='kitten icat'
alias cat='bat'
alias rg='rg --hidden --glob "!.git"'

# Kitty SSH integration
[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

# =============================================================================
# Tool Integrations (mirrors plugins.zsh)
# =============================================================================

# fzf keybindings & completion (Ctrl+R for history, Ctrl+T for files)
eval "$(fzf --bash)" 2>/dev/null

# Starship prompt (replaces PS1)
eval "$(starship init bash)" 2>/dev/null
