# Use Emacs keybindings by default
bindkey -e

# History Substring Search (Up / Down Arrow keys)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
if [[ -n "$terminfo[kcuu1]" ]]; then bindkey "$terminfo[kcuu1]" history-substring-search-up; fi
if [[ -n "$terminfo[kcud1]" ]]; then bindkey "$terminfo[kcud1]" history-substring-search-down; fi

# Standard Line Editing Keybindings (Home, End, Delete)
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[3~' delete-char

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
