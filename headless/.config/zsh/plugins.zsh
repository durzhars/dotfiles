# Headless Zsh Plugins & Completions (Performance Tuned)

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
export ZSH_AUTOSUGGEST_USE_ASYNC=1           # Run suggestions in background (prevents typing lag)
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1       # Disable heavy widget rebinding
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)    # Lightweight syntax highlighting (main token only)

# Load System Plugins (first matching path per plugin)
local -a autosug_paths=(
    "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
    "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    "${PREFIX:-}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
)
for p in "${autosug_paths[@]}"; do
    if [[ -r "$p" ]]; then source "$p"; break; fi
done

local -a subsearch_paths=(
    "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh"
    "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
    "/usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
    "${PREFIX:-}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
)
for p in "${subsearch_paths[@]}"; do
    if [[ -r "$p" ]]; then source "$p"; break; fi
done

local -a highlight_paths=(
    "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "${PREFIX:-}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
)
for p in "${highlight_paths[@]}"; do
    if [[ -r "$p" ]]; then source "$p"; break; fi
done

# -----------------------------------------------------------------------------
# Cached Init for CLI Tools (avoids subshell exec on every shell startup)
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

