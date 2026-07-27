# Headless Zsh Main Entrypoint (Dynamic Multi-Device Architecture)

source "$ZDOTDIR/env.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/bindings.zsh"

# Device-Specific Custom Overrides (Loaded if present on target machine)
if [[ -r "$ZDOTDIR/local.zsh" ]]; then
    source "$ZDOTDIR/local.zsh"
elif [[ -r "$HOME/.zshrc.local" ]]; then
    source "$HOME/.zshrc.local"
fi

# Auto byte-compile configuration files when updated
setopt LOCAL_OPTIONS EXTENDED_GLOB
for _zfile in "$ZDOTDIR"/*.zsh(N) "$ZDOTDIR"/.zshrc(N); do
    if [[ -f "$_zfile" && (! -f "${_zfile}.zwc" || "$_zfile" -nt "${_zfile}.zwc") ]]; then
        zcompile "$_zfile" 2>/dev/null
    fi
done
unset _zfile

# Lightweight Transient Prompt for Starship
if (( $+commands[starship] )); then
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
fi

# Fastfetch (Interactive top-level shell guard only; bypassable with NO_FASTFETCH=1)
if [[ -t 1 && "$SHLVL" -eq 1 && -z "$NO_FASTFETCH" ]] && (( $+commands[fastfetch] )); then
    fastfetch -c "$HOME/.config/fastfetch/config.jsonc" 2>/dev/null
fi


