# =============================================================================
# Zsh Completions (Fast cached init)
# =============================================================================
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
autoload -Uz compinit
local zcompdump="$XDG_CACHE_HOME/zsh/zcompdump"

# Regenerate dump file if older than 24 hours or missing, otherwise skip check (-C)
if [[ -n "$zcompdump"(#qN.mh+24) || ! -f "$zcompdump" ]]; then
  compinit -d "$zcompdump"
  touch "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi

# Completion Styling & Behavior
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' rehash true
zstyle ':completion:*:*:*:*:processes' command 'ps -u $USER -o pid,user,comm -w -w'

# =============================================================================
# System Plugins (Multi-Distro Dynamic Loader)
# =============================================================================
_source_plugin() {
  for plugin_path in "$@"; do
    if [[ -f "$plugin_path" ]]; then
      source "$plugin_path"
      return 0
    fi
  done
  return 1
}

_source_plugin \
  "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

_source_plugin \
  "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "/home/linuxbrew/.linuxbrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "/usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh"

_source_plugin \
  "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# =============================================================================
# Tool Integrations
# =============================================================================
if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi

if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
