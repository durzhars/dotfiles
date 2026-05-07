setopt PROMPT_SUBST          # Allow variables/commands to be evaluated in the prompt
setopt INTERACTIVE_COMMENTS  # Allow # comments in the interactive terminal

# =============================================================================
# History Configuration
# =============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY        # Append to history file, don't overwrite
setopt SHARE_HISTORY         # Share history across all open terminal windows
setopt INC_APPEND_HISTORY    # Write to the history file immediately, not when shell exits

# Note on execution time: Zsh's native EXTENDED_HISTORY saves BOTH timestamp 
# and duration to the file. If you only want to *see* how long a command took 
# to run visually in your prompt, keep EXTENDED_HISTORY off. Modern prompts 
# like Starship will calculate and display execution time automatically.

# =============================================================================
# Tab Completion (Native, no OMZ overhead)
# =============================================================================
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select # Use an interactive menu for tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Match colors to ls

# =============================================================================
# Keybindings (Using standard Zsh behavior)
# =============================================================================
bindkey -e 
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# =============================================================================
# Aliases
# =============================================================================
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias ll='ls -lh'      # Long format, human-readable file sizes
alias la='ls -lha'     # Long format, includes hidden files
alias l='ls -CF'       # Compact format with file type indicators
alias lsa='ls -a'      # Compact, with hidden files

alias cp='cp -iv'      # Prompt before overwrite, show what is being copied
alias mv='mv -iv'      # Prompt before overwrite, show what is being moved
alias rm='rm -I'       # Prompts only if deleting >3 files or recursive (less annoying than -i)

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# =============================================================================
# Environment Variables & Aliases
# =============================================================================
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export TERM="xterm-kitty"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

# =============================================================================
# Fast System-Level Plugins & Prompt
# =============================================================================
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"

# =============================================================================
# Transient Prompt (Shrinks previous commands to a single line)
# =============================================================================
function set_transient_prompt() {
  local SAVED_PROMPT="$PROMPT"
  local SAVED_RPROMPT="$RPROMPT"

  PROMPT="%(?.%B%F{green}❯%f%b.%B%F{red}❯%f%b) "
  RPROMPT=""

  zle reset-prompt

  PROMPT="$SAVED_PROMPT"
  RPROMPT="$SAVED_RPROMPT"
}

autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-finish set_transient_prompt
