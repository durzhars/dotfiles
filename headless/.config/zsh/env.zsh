# Headless Zsh Environment Configuration

# XDG Base Directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# History Configuration (XDG-compliant)
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST

# Core Zsh Options
setopt PROMPT_SUBST
setopt INTERACTIVE_COMMENTS
setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

# Safe Default Apps
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

# Fallback TERM for headless SSH / TTY sessions
if [[ -z "$TERM" || "$TERM" == "dumb" ]]; then
    export TERM="xterm-256color"
fi

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# =============================================================================
# Modern CLI Integrations (fzf + fd + bat + eza)
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
