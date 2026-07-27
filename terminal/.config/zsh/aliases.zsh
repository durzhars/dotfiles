# =============================================================================
# Eza / Exa / LS Aliases
# =============================================================================
if (( $+commands[eza] )); then
  alias ls='eza --icons=always --color=always --group-directories-first'
  alias ll='eza -lh --icons=always --color=always --group-directories-first --git'
  alias la='eza -lha --icons=always --color=always --group-directories-first --git'
  alias lsa='eza -a --icons=always --color=always --group-directories-first'
  alias tree='eza --tree --icons=always'
elif (( $+commands[exa] )); then
  alias ls='exa --icons=always --color=always --group-directories-first'
  alias ll='exa -lh --icons=always --color=always --group-directories-first --git'
  alias la='exa -lha --icons=always --color=always --group-directories-first --git'
  alias lsa='exa -a --icons=always --color=always --group-directories-first'
  alias tree='exa --tree --icons=always'
else
  alias ls='ls --color=auto --group-directories-first'
  alias ll='ls -lh'
  alias la='ls -lha'
  alias lsa='ls -a'
fi

# =============================================================================
# Bat / Cat & Ripgrep Aliases
# =============================================================================
if (( $+commands[bat] )); then
  alias cat='bat'
elif (( $+commands[batcat] )); then
  alias cat='batcat'
fi

if (( $+commands[rg] )); then
  alias rg='rg --hidden --glob "!.git"'
else
  alias grep='grep --color=auto'
fi

if ! (( $+commands[fd] )) && (( $+commands[fdfind] )); then
  alias fd='fdfind'
fi

if (( $+commands[btop] )); then
  alias top='btop'
elif (( $+commands[htop] )); then
  alias top='htop'
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
alias reload='exec $SHELL -l'
alias path='echo -e "${PATH//:/\\n}"'
alias ports='ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null || lsof -i'
alias myip='curl -s https://ifconfig.me || curl -s https://api.ipify.org'
alias meminfo='free -m -l -t 2>/dev/null || top -l 1 | head -n 10'
alias diskinfo='df -hT 2>/dev/null || df -h'

if (( $+commands[kitten] )); then
  alias icat='kitten icat'
  [[ "$TERM" == "xterm-kitty" ]] && alias ssh="kitty +kitten ssh"
fi

