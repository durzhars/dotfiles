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

# Auto byte-compile configuration files into $zcache_dir (0ms startup overhead)
local zcache_dir="${ZDOTDIR:-$HOME/.config/zsh}/cache"
[[ -d "$zcache_dir" ]] || mkdir -p "$zcache_dir"

local _stamp="$zcache_dir/.zwc_stamp"
if [[ ! -f "$_stamp" || "$ZDOTDIR" -nt "$_stamp" ]]; then
    (
        setopt LOCAL_OPTIONS EXTENDED_GLOB
        for _zfile in "$ZDOTDIR"/*.zsh(N) "$ZDOTDIR"/.zshrc(N); do
            local _zwc_target="$zcache_dir/${_zfile:t}.zwc"
            local _zwc_link="${_zfile}.zwc"
            if [[ -f "$_zfile" && (! -f "$_zwc_target" || "$_zfile" -nt "$_zwc_target") ]]; then
                zcompile "$_zwc_target" "$_zfile" 2>/dev/null
            fi
            if [[ -f "$_zwc_target" && (! -L "$_zwc_link" || "$_zwc_target" -nt "$_zwc_link") ]]; then
                ln -sf "cache/${_zfile:t}.zwc" "$_zwc_link" 2>/dev/null
            fi
        done
        touch "$_stamp" 2>/dev/null
    ) &|
fi
unset _stamp

# Lightweight Transient Prompt for Starship
if (($+commands[starship])); then
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
if [[ -t 1 && "$SHLVL" -eq 1 && -z "$NO_FASTFETCH" ]] && (($+commands[fastfetch])); then
    fastfetch -c "$HOME/.config/fastfetch/config.jsonc" 2>/dev/null
fi
