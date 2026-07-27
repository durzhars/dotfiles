# Headless Zsh Plugins & Completions (Dynamic Multi-Device Architecture)

local zcache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$zcache_dir" ]] || mkdir -p "$zcache_dir"

# -----------------------------------------------------------------------------
# Fast compinit with 24-hour cache & byte compilation
# -----------------------------------------------------------------------------
autoload -Uz compinit
local zcompdump="$zcache_dir/zcompdump-${HOST}-${ZSH_VERSION}"

# Enable extendedglob for native zsh mtime check (#qN.m-1)
setopt LOCAL_OPTIONS EXTENDED_GLOB

if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump" 2>/dev/null
fi

if [[ -s "$zcompdump" && -n "$zcompdump"(#qN.m-1) ]]; then
    compinit -C -d "$zcompdump"
else
    compinit -d "$zcompdump"
    zcompile "$zcompdump" 2>/dev/null
fi

# Completion performance options
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash false          # Disable auto rehash on completion to save disk I/O
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$zcache_dir/zcompcache"

# -----------------------------------------------------------------------------
# Plugin Configurations (must be set BEFORE sourcing plugins)
# -----------------------------------------------------------------------------
export ZSH_AUTOSUGGEST_USE_ASYNC=1           # Run suggestions in background
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1       # Disable heavy widget rebinding
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)    # Lightweight syntax highlighting

# -----------------------------------------------------------------------------
# Dynamic Plugin Discovery & Sourcing (Works across Arch, Debian, Ubuntu, Fedora, macOS, Nix, Termux)
# -----------------------------------------------------------------------------
local -a plugin_names=(
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
    zsh-completions
    fzf-tab
)

# Potential system & user plugin root search directories
local -a plugin_roots=(
    "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
    "${XDG_DATA_HOME:-$HOME/.local/share}"
    "$HOME/.zsh/plugins"
    "$ZDOTDIR/plugins"
    "${PREFIX:-}/share/zsh/plugins"
    "${PREFIX:-}/share/zsh-plugins"
    "${PREFIX:-}/share"
    "/usr/share/zsh/plugins"
    "/usr/share/zsh-plugins"
    "/usr/share"
    "/usr/local/share/zsh/plugins"
    "/usr/local/share"
    "/opt/homebrew/share"
    "/run/current-system/sw/share/zsh/plugins"
    "/run/current-system/sw/share"
    "$HOME/.nix-profile/share/zsh/plugins"
    "$HOME/.nix-profile/share"
)

local plugin_cache="$zcache_dir/plugins_found.zsh"
local rebuild_cache=0

if [[ ! -s "$plugin_cache" ]]; then
    rebuild_cache=1
else
    # Rebuild cache if any plugin search directory has been updated
    for root in "${plugin_roots[@]}"; do
        if [[ -d "$root" && "$root" -nt "$plugin_cache" ]]; then
            rebuild_cache=1
            break
        fi
    done
fi

if (( rebuild_cache )); then
    local cache_tmp="$plugin_cache.tmp"
    echo "# Auto-generated dynamic plugin loader" >! "$cache_tmp"

    for name in "${plugin_names[@]}"; do
        local found=""
        for root in "${plugin_roots[@]}"; do
            local -a candidates=(
                "$root/$name/$name.zsh"(N)
                "$root/$name/$name.plugin.zsh"(N)
                "$root/$name/$name.zsh-theme"(N)
                "$root/$name.zsh"(N)
            )
            if (( ${#candidates} > 0 )); then
                found="${candidates[1]}"
                break
            fi
        done
        if [[ -n "$found" && -r "$found" ]]; then
            echo "source \"$found\"" >> "$cache_tmp"
        fi
    done
    mv "$cache_tmp" "$plugin_cache"
fi

if [[ -s "$plugin_cache" ]]; then
    source "$plugin_cache"
fi

# -----------------------------------------------------------------------------
# Dynamic Cached Init for CLI Tools (fzf + starship)
# -----------------------------------------------------------------------------
if (( $+commands[fzf] )); then
    local fzf_cache="$zcache_dir/fzf_init.zsh"
    if [[ ! -s "$fzf_cache" || "$commands[fzf]" -nt "$fzf_cache" ]]; then
        fzf --zsh >! "$fzf_cache" 2>/dev/null
    fi
    source "$fzf_cache"
fi

if (( $+commands[starship] )); then
    local starship_cache="$zcache_dir/starship_init.zsh"
    if [[ ! -s "$starship_cache" || "$commands[starship]" -nt "$starship_cache" ]]; then
        starship init zsh >! "$starship_cache" 2>/dev/null
    fi
    source "$starship_cache"
fi


