# XDG Base Directories (Fallback)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Dynamic PATH Resolution (User, System & Termux Bin Directories)
local termux_prefix="${PREFIX:-/data/data/com.termux/files/usr}"
local -a user_paths=(
    "$HOME/.local/bin"
    "$HOME/bin"
    "$termux_prefix/bin"
    "$termux_prefix/local/bin"
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
typeset -U path PATH fpath FPATH

# History Configuration (Saved in ~/.local/state/zsh/)
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

unsetopt SHARE_HISTORY 2>/dev/null || true
setopt INC_APPEND_HISTORY_TIME
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Core Options
setopt PROMPT_SUBST         # Enable expansion in prompt
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell
setopt AUTOCD               # cd into directory by typing name
setopt AUTO_PUSHD           # Save directory history on cd
setopt PUSHD_IGNORE_DUPS    # Don't push duplicate directories onto stack
setopt PUSHD_SILENT         # Keep pushd/popd quiet
setopt EXTENDED_GLOB        # Advanced pattern matching (#, ~, ^)
setopt COMPLETE_IN_WORD     # Allow completing from inside a word
setopt ALWAYS_TO_END        # Move cursor to end of word after completion
setopt NO_BEEP              # Disable terminal bell
setopt NUMERIC_GLOB_SORT    # Sort filenames numerically when globbing
setopt NO_CHECK_JOBS        # Fast exit without waiting on jobs
setopt NO_HUP

# Dynamic Default Editor Priority Chain
local -a preferred_editors=(nvim vim hx micro nano vi)
for ed in "${preferred_editors[@]}"; do
    if (($+commands[$ed])); then
        export EDITOR="$ed"
        export SUDO_EDITOR="$ed"
        break
    fi
done

export TERM="${TERM:-xterm-256color}"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# =============================================================================
# Modern CLI Integrations (fzf + fd/fdfind + bat/batcat + eza/exa + rg)
# =============================================================================

if (($+commands[fzf])); then
    # Styled FZF Theme & Layout (Catppuccin Macchiato/Mocha aligned)
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=rounded --inline-info"

    local fd_bin=""
    if (($+commands[fd])); then
        fd_bin="fd"
    elif (($+commands[fdfind])); then
        fd_bin="fdfind"
    fi

    if [[ -n "$fd_bin" ]]; then
        export FZF_DEFAULT_COMMAND="$fd_bin --type f --strip-cwd-prefix --hidden --exclude .git"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND="$fd_bin --type d --strip-cwd-prefix --hidden --exclude .git"
    fi

    local bat_bin=""
    if (($+commands[bat])); then
        bat_bin="bat"
    elif (($+commands[batcat])); then
        bat_bin="batcat"
    fi

    if [[ -n "$bat_bin" ]]; then
        export FZF_CTRL_T_OPTS="--preview '$bat_bin --color=always --style=numbers --line-range=:500 {}'"
        export MANPAGER="sh -c 'col -bx | $bat_bin -l man -p'"
        export MANROFFOPT="-c"
    fi

    if (($+commands[eza])) || (($+commands[exa])); then
        local eza_bin="eza"
        (($+commands[exa])) && eza_bin="exa"
        export FZF_ALT_C_OPTS="--preview '$eza_bin --tree --color=always {} | head -200'"
    fi
fi
