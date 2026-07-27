# Headless Zsh Environment Configuration (Dynamic Multi-Device Architecture)

# Dynamic PATH Resolution (User & System Bin Directories)
local -a user_paths=(
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.nix-profile/bin"
    "/usr/local/bin"
    "/opt/homebrew/bin"
    "/snap/bin"
)
for p in "${user_paths[@]}"; do
    [[ -d "$p" ]] && path=("$p" $path)
done

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

# Dynamic Default Editor Priority Chain
local -a preferred_editors=(nvim vim hx micro nano vi)
for ed in "${preferred_editors[@]}"; do
    if (( $+commands[$ed] )); then
        export EDITOR="$ed"
        export SUDO_EDITOR="$ed"
        break
    fi
done

# Fallback TERM for headless SSH / TTY sessions
if [[ -z "$TERM" || "$TERM" == "dumb" ]]; then
    export TERM="xterm-256color"
fi

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# =============================================================================
# Dynamic CLI Integrations (fzf + fd/fdfind + bat/batcat + eza/exa)
# =============================================================================

# Debian/Ubuntu Command Normalization & FZF Commands
local fd_bin=""
if (( $+commands[fd] )); then
    fd_bin="fd"
elif (( $+commands[fdfind] )); then
    fd_bin="fdfind"
fi

if [[ -n "$fd_bin" ]]; then
    export FZF_DEFAULT_COMMAND="$fd_bin --type f --strip-cwd-prefix --hidden --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$fd_bin --type d --strip-cwd-prefix --hidden --exclude .git"
fi

local bat_bin=""
if (( $+commands[bat] )); then
    bat_bin="bat"
elif (( $+commands[batcat] )); then
    bat_bin="batcat"
fi

if [[ -n "$bat_bin" ]]; then
    export FZF_CTRL_T_OPTS="--preview '$bat_bin --color=always --style=numbers --line-range=:500 {}'"
    export MANPAGER="sh -c 'col -bx | $bat_bin -l man -p'"
    export MANROFFOPT="-c"
fi

if (( $+commands[eza] )) || (( $+commands[exa] )); then
    local eza_bin="eza"
    (( $+commands[exa] )) && eza_bin="exa"
    export FZF_ALT_C_OPTS="--preview '$eza_bin --tree --color=always {} | head -200'"
fi


