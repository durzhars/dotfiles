# Headless Zsh Main Entrypoint

source "$ZDOTDIR/env.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/bindings.zsh"

# Transient Prompt for Starship
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
add-zle-hook-widget zle-line-finish set_transient_prompt 2>/dev/null || true

# Launch fastfetch if available
if command -v fastfetch >/dev/null 2>&1; then
  fastfetch -c "$HOME/.config/fastfetch/config.jsonc" 2>/dev/null
fi
