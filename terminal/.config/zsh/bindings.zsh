# Use Emacs keybindings by default
bindkey -e

# Dynamically resolve up/down keys across terminfo & escape sequence variations
local -a up_keys=("${terminfo[kcuu1]}" "^[[A" "^OA" "^[OA")
local -a down_keys=("${terminfo[kcud1]}" "^[[B" "^OB" "^[OB")

if (( $+widgets[history-substring-search-up] )); then
    for k in "${up_keys[@]}"; do
        [[ -n "$k" ]] && bindkey "$k" history-substring-search-up 2>/dev/null
    done
    for k in "${down_keys[@]}"; do
        [[ -n "$k" ]] && bindkey "$k" history-substring-search-down 2>/dev/null
    done
    bindkey '^P' history-substring-search-up
    bindkey '^N' history-substring-search-down
else
    # Native Zsh history search fallback
    autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
    zle -N up-line-or-beginning-search
    zle -N down-line-or-beginning-search
    for k in "${up_keys[@]}"; do
        [[ -n "$k" ]] && bindkey "$k" up-line-or-beginning-search 2>/dev/null
    done
    for k in "${down_keys[@]}"; do
        [[ -n "$k" ]] && bindkey "$k" down-line-or-beginning-search 2>/dev/null
    done
fi

# Standard Line Editing Keybindings (Home, End, Delete)
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[3~' delete-char
bindkey '^?' backward-delete-char

# Navigation by Word (Ctrl + Left / Ctrl + Right)
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word

# Word Deletion
bindkey '^H' backward-kill-word

# Shift-Tab for Reverse Completion Menu
bindkey '^[[Z' reverse-menu-complete

# Edit Command Line in $EDITOR (Ctrl+X, Ctrl+E)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

