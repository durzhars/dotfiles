# Source modular components
source "$ZDOTDIR/env.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/bindings.zsh"

# =============================================================================
# Transient Prompt (Powered natively by Starship Profiles)
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
fastfetch -c "$HOME/.config/fastfetch/config.jsonc"
