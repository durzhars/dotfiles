# =============================================================================
# Zsh Completions (Fast cached init in $ZDOTDIR/cache)
# =============================================================================
local zcache_dir="${ZDOTDIR:-$HOME/.config/zsh}/cache"
[[ -d "$zcache_dir" ]] || mkdir -p "$zcache_dir"

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

# Completion Styling & Behavior
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$zcache_dir/zcompcache"
zstyle ':completion:*' rehash false # Disable auto rehash to save disk I/O
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w -w'

# Plugin Performance Settings
export ZSH_AUTOSUGGEST_USE_ASYNC=1     # Run suggestions in background
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1 # Disable heavy widget rebinding
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main) # Lightweight syntax highlighting

# =============================================================================
# System Plugins (Universal Multi-Device Dynamic Engine)
# =============================================================================
local -a plugin_names=(
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
    zsh-completions
    fzf-tab
)

local termux_prefix="${PREFIX:-/data/data/com.termux/files/usr}"

local -a plugin_roots=(
    "$ZDOTDIR/plugins"
    "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"
    "${XDG_CONFIG_HOME:-$HOME/.config}/plugins"
    "$HOME/.zsh/plugins"
    "$HOME/.zsh"
    "$HOME/plugins"
    "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    "${ZSH_PLUGINS_DIR:-}"
    "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
    "${XDG_DATA_HOME:-$HOME/.local/share}/zsh-plugins"
    "${XDG_DATA_HOME:-$HOME/.local/share}/plugins"
    "$HOME/.local/share/zinit/plugins"
    "$HOME/.oh-my-zsh/plugins"
    "$termux_prefix/share/zsh-autosuggestions"
    "$termux_prefix/share/zsh-syntax-highlighting"
    "$termux_prefix/share/zsh-history-substring-search"
    "$termux_prefix/share/zsh/plugins"
    "$termux_prefix/share/zsh/site-functions"
    "$termux_prefix/share"
    "/usr/share/zsh/plugins"
    "/usr/share/zsh-plugins"
    "/usr/share/zsh-autosuggestions"
    "/usr/share/zsh-syntax-highlighting"
    "/usr/share/zsh-history-substring-search"
    "/home/linuxbrew/.linuxbrew/share/zsh-autosuggestions"
    "/home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting"
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
    for root in "${plugin_roots[@]}"; do
        if [[ -d "$root" && "$root" -nt "$plugin_cache" ]]; then
            rebuild_cache=1
            break
        fi
    done
fi

if ((rebuild_cache)); then
    local cache_tmp="$plugin_cache.tmp"
    echo "# Auto-generated dynamic plugin loader" >|"$cache_tmp"

    for name in "${plugin_names[@]}"; do
        local found=""
        for root in "${plugin_roots[@]}"; do
            local -a candidates=(
                "$root/$name/$name.zsh"(N)
                "$root/$name/$name.plugin.zsh"(N)
                "$root/$name/$name.zsh-theme"(N)
                "$root/$name.zsh"(N)
                "$root/$name.plugin.zsh"(N)
            )
            if ((${#candidates} > 0)); then
                found="${candidates[1]}"
                break
            fi
        done

        if [[ -z "$found" ]]; then
            local -a search_dirs=()
            [[ -d "$HOME/.config" ]] && search_dirs+=("$HOME/.config")
            [[ -d "$HOME/.zsh" ]] && search_dirs+=("$HOME/.zsh")
            [[ -d "$HOME/.local" ]] && search_dirs+=("$HOME/.local")
            [[ -d "$termux_prefix/share" ]] && search_dirs+=("$termux_prefix/share")

            if ((${#search_dirs} > 0)); then
                found=$(find "${search_dirs[@]}" -maxdepth 4 \( -name "$name.zsh" -o -name "$name.plugin.zsh" \) 2>/dev/null | head -n 1)
            fi
        fi

        if [[ -n "$found" && -r "$found" ]]; then
            echo "source \"$found\"" >>"$cache_tmp"
        fi
    done

    for custom_plug in "$ZDOTDIR/plugins"/*.zsh(N) "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"/*.zsh(N); do
        if [[ -f "$custom_plug" ]]; then
            echo "source \"$custom_plug\"" >>"$cache_tmp"
        fi
    done

    mv -f "$cache_tmp" "$plugin_cache"
fi

if [[ -s "$plugin_cache" ]]; then
    source "$plugin_cache"
fi

# =============================================================================
# Dynamic Cached Init for CLI Tools (fzf + starship)
# =============================================================================
if (($+commands[fzf])); then
    local fzf_cache="$zcache_dir/fzf_init.zsh"
    if [[ ! -s "$fzf_cache" || "$commands[fzf]" -nt "$fzf_cache" ]]; then
        fzf --zsh >|"$fzf_cache" 2>/dev/null
    fi
    source "$fzf_cache"
fi

if (($+commands[starship])); then
    local starship_cache="$zcache_dir/starship_init.zsh"
    if [[ ! -s "$starship_cache" || "$commands[starship]" -nt "$starship_cache" ]]; then
        starship init zsh >|"$starship_cache" 2>/dev/null
    fi
    source "$starship_cache"
fi
