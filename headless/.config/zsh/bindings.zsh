# Headless Zsh Keybindings

bindkey -e

# History substring search bindings (if loaded)
if (( $+widgets[history-substring-search-up] )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^P' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^N' history-substring-search-down
fi

