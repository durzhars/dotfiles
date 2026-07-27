# =============================================================================
# Eza / LS Aliases
# =============================================================================
if command -v eza &>/dev/null; then
  alias ls='eza --icons=always --color=always --group-directories-first'
  alias ll='eza -lh --icons=always --color=always --group-directories-first --git'
  alias la='eza -lha --icons=always --color=always --group-directories-first --git'
  alias lsa='eza -a --icons=always --color=always --group-directories-first'
  alias tree='eza --tree --icons=always'
else
  alias ls='ls --color=auto --group-directories-first'
  alias ll='ls -lh'
  alias la='ls -lha'
  alias lsa='ls -a'
fi

# =============================================================================
# Bat / Cat & Ripgrep Aliases
# =============================================================================
if command -v bat &>/dev/null; then
  alias cat='bat'
elif command -v batcat &>/dev/null; then
  alias cat='batcat'
fi

if command -v rg &>/dev/null; then
  alias rg='rg --hidden --glob "!.git"'
fi

# =============================================================================
# Safe File Operations & Quick Directory Navigation
# =============================================================================
alias cp='cp -iv'       # Prompt before overwrite, show copied file
alias mv='mv -iv'       # Prompt before overwrite, show moved file
alias rm='rm -I'        # Prompts when deleting >3 files or recursively
alias mkdir='mkdir -pv' # Make parent directories with verbosity

alias -- -='cd -'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# =============================================================================
# Git Short-Cut Aliases
# =============================================================================
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gaa='git add -A'
alias gc='git commit -m'

# =============================================================================
# Shell Helpers & Kitty Integration
# =============================================================================
alias zshconfig='${EDITOR:-nvim} "$ZDOTDIR/.zshrc"'
alias reload='exec zsh'
alias path='echo -e "${PATH//:/\\n}"'

if command -v kitten &>/dev/null; then
  alias icat='kitten icat'
  [[ "$TERM" == "xterm-kitty" ]] && alias ssh="kitty +kitten ssh"
fi
