# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# History Configuration (Moved to ~/.local/state/)
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST

# Core Options
setopt PROMPT_SUBST
setopt INTERACTIVE_COMMENTS
setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

# Default Apps
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export TERM="xterm-kitty"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# =============================================================================
# Modern CLI Integrations (fzf + fd + bat + rg)
# =============================================================================

# 1. fzf Backend (Use fd instead of find)
# This makes Ctrl+T and default fzf searches blisteringly fast and respect .gitignore
export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# Use fd to find directories for Alt+C
export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --exclude .git'

# 2. fzf Previews (Use bat and eza)
# Ctrl+T shows a syntax-highlighted file preview (capped at 500 lines for speed)
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
# Alt+C shows a colored tree view of the directory you are about to jump into
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# 3. Man Pages (Use bat as the pager)
# Fully syntax-highlighted manual pages
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"
