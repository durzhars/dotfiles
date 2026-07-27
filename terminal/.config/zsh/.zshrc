# =============================================================================
# Source Modular Zsh Components
# =============================================================================
[[ -f "$ZDOTDIR/env.zsh" ]] && source "$ZDOTDIR/env.zsh"
[[ -f "$ZDOTDIR/plugins.zsh" ]] && source "$ZDOTDIR/plugins.zsh"
[[ -f "$ZDOTDIR/fzf.zsh" ]] && source "$ZDOTDIR/fzf.zsh"
[[ -f "$ZDOTDIR/aliases.zsh" ]] && source "$ZDOTDIR/aliases.zsh"
[[ -f "$ZDOTDIR/bindings.zsh" ]] && source "$ZDOTDIR/bindings.zsh"

# =============================================================================
# Transient Prompt
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

# =============================================================================
# Fastfetch Terminal Welcome Banner
# =============================================================================
if [[ $- == *i* ]] && command -v fastfetch &>/dev/null; then
  fastfetch -c "$HOME/.config/fastfetch/config.jsonc"
fi
