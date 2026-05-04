# =============================================================================
# 1. Core Shell Options (The stuff you actually liked)
# =============================================================================
setopt PROMPT_SUBST          # Allow variables/commands to be evaluated in the prompt
setopt INTERACTIVE_COMMENTS  # Allow # comments in the interactive terminal

# =============================================================================
# 2. History Configuration
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
# 3. Tab Completion (Native, no OMZ overhead)
# =============================================================================
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select # Use an interactive menu for tab completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case-insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Match colors to ls

# =============================================================================
# 4. Keybindings (Using standard Zsh behavior)
# =============================================================================
# Ensure we are using standard keymap (unlike OMZ forcing emacs mode)
bindkey -e 
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# =============================================================================
# 5. Environment Variables & Aliases
# =============================================================================
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export TERM="xterm-kitty"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

[ "$TERM" = "xterm-kitty" ] && alias ssh="kitty +kitten ssh"

# =============================================================================
# 6. Fast System-Level Plugins & Prompt
# =============================================================================
# Load these from the Arch repos exactly as you had them
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Initialize Starship prompt (Make sure you ran `pacman -S starship` first)
eval "$(starship init zsh)"

# =============================================================================
# Transient Prompt (Shrinks previous commands to a single line)
# =============================================================================
function set_transient_prompt() {
  # 1. Back up the Starship execution variables
  local SAVED_PROMPT="$PROMPT"
  local SAVED_RPROMPT="$RPROMPT"
  
  # 2. Swap to our clean, minimal transient symbol
  PROMPT="%(?.%B%F{green}❯%f%b.%B%F{red}❯%f%b) "
  RPROMPT=""
  
  # 3. Force Zsh to redraw the current line using the minimal prompt
  zle reset-prompt
  
  # 4. Immediately restore Starship so it's ready for the NEXT command
  PROMPT="$SAVED_PROMPT"
  RPROMPT="$SAVED_RPROMPT"
}

# Tell Zsh to run this function the moment you hit 'Enter'
autoload -Uz add-zle-hook-widget
add-zle-hook-widget zle-line-finish set_transient_prompt
