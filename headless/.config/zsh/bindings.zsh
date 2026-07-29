# Headless Zsh Keybindings

bindkey -e # Default Emacs keymap

# Resolve Up/Down keys across terminfo & escape sequence variations (OpenSSH, PuTTY, Kitty, tmux, serial TTY)
local -a up_keys=("${terminfo[kcuu1]}" "^[[A" "^OA" "^[OA")
local -a down_keys=("${terminfo[kcud1]}" "^[[B" "^OB" "^[OB")

if (($+widgets[history - substring - search - up])); then
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

# Universal Navigation & Editing Keys
bindkey '^[[H' beginning-of-line  # Home
bindkey '^[[F' end-of-line        # End
bindkey '^[[3~' delete-char       # Delete
bindkey '^?' backward-delete-char # Backspace
