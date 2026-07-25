# Zsh Completion
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# System Plugin Detection (Arch / Debian / Fedora / Homebrew)
for plugin_path in \
    "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
    "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
    "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" \
    "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh" \
    "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
    "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
do
    [[ -r "$plugin_path" ]] && source "$plugin_path"
done

# Tool Integrations
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh 2>/dev/null)"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh 2>/dev/null)"
fi
