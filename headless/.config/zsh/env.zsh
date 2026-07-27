# Headless Zsh Environment Configuration (Performance Tuned)

# Deduplicate PATH & fpath arrays in Zsh
typeset -U path PATH fpath FPATH

# XDG Base Directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# History Configuration (Optimized for Low-IO / Slow Servers)
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=10000
SAVEHIST=10000

# Avoid SHARE_HISTORY on slow server disks; use INC_APPEND_HISTORY_TIME instead
unsetopt SHARE_HISTORY 2>/dev/null || true
setopt INC_APPEND_HISTORY_TIME
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST

# Core Zsh Options
setopt PROMPT_SUBST
setopt INTERACTIVE_COMMENTS
setopt AUTOCD
setopt NO_BEEP
setopt NUMERIC_GLOB_SORT
setopt NO_CHECK_JOBS
setopt NO_HUP

# Safe Default Apps (Internal $commands hash lookup, zero subshells)
if (( $+commands[nvim] )); then
    export EDITOR="nvim"
    export SUDO_EDITOR="nvim"
elif (( $+commands[vim] )); then
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

if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --exclude .git'
fi

if (( $+commands[bat] )); then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
    export MANROFFOPT="-c"
fi

if (( $+commands[eza] )); then
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
fi

