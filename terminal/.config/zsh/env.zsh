# XDG Base Directories (Fallback)
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# History Configuration (Saved in ~/.local/state/zsh/)
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY          # Append history to history file on exit
setopt SHARE_HISTORY           # Share history across all active sessions
setopt INC_APPEND_HISTORY      # Write to history file immediately
setopt HIST_IGNORE_DUPS        # Do not record an entry that was just recorded
setopt HIST_IGNORE_ALL_DUPS    # Remove older duplicate entry if new entry is a duplicate
setopt HIST_IGNORE_SPACE       # Do not record entries starting with a space
setopt HIST_EXPIRE_DUPS_FIRST  # Expire duplicate entries first when trimming history
setopt HIST_SAVE_NO_DUPS       # Do not write duplicate entries to history file
setopt HIST_REDUCE_BLANKS      # Remove superfluous blanks before recording
setopt HIST_VERIFY             # Do not execute immediately upon history expansion

# Core Options
setopt PROMPT_SUBST            # Enable expansion in prompt
setopt INTERACTIVE_COMMENTS    # Allow comments in interactive shell
setopt AUTOCD                  # cd into directory by typing name
setopt AUTO_PUSHD              # Save directory history on cd
setopt PUSHD_IGNORE_DUPS       # Don't push duplicate directories onto stack
setopt PUSHD_SILENT            # Keep pushd/popd quiet
setopt EXTENDED_GLOB           # Advanced pattern matching (#, ~, ^)
setopt COMPLETE_IN_WORD        # Allow completing from inside a word
setopt ALWAYS_TO_END           # Move cursor to end of word after completion
setopt NO_BEEP                 # Disable terminal bell
setopt NUMERIC_GLOB_SORT       # Sort filenames numerically when globbing

# Default Applications
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export TERM="${TERM:-xterm-kitty}"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"

# =============================================================================
# Modern CLI Integrations (fzf + fd + bat + eza + rg)
# =============================================================================

if command -v fzf &>/dev/null; then
  # Styled FZF Theme & Layout (Catppuccin Macchiato/Mocha aligned)
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border=rounded --inline-info \
    --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
    --color=marker:#b4befe,prompt:#cba6f7,query:#f38ba8"

  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --strip-cwd-prefix --hidden --exclude .git'
  fi

  if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
  fi

  if command -v eza &>/dev/null; then
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
  fi
fi

# Syntax-highlighted Man Pages
if command -v bat &>/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
fi
