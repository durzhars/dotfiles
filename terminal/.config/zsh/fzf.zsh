# =============================================================================
# Interactive FZF Helper Functions & Utilities
# =============================================================================

if command -v fzf &>/dev/null; then

  # 1. Interactive Ripgrep Search (fif - Find In File)
  # Live-search file content with ripgrep, preview with bat, open in $EDITOR at line
  fif() {
    if ! command -v rg &>/dev/null; then
      echo "ripgrep (rg) is required for fif" >&2
      return 1
    fi

    local file
    file="$(
      rg --column --line-number --no-heading --color=always --smart-case -- "${1:-}" 2>/dev/null | \
      fzf --ansi \
          --delimiter : \
          --preview 'bat --color=always --style=numbers --highlight-line {2} {1} 2>/dev/null || cat {1}' \
          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
    )"
    
    if [[ -n "$file" ]]; then
      local target_file line col
      target_file="$(echo "$file" | cut -d: -f1)"
      line="$(echo "$file" | cut -d: -f2)"
      col="$(echo "$file" | cut -d: -f3)"
      "${EDITOR:-nvim}" "+call cursor($line, $col)" "$target_file"
    fi
  }

  # 2. Interactive Directory Switcher (fcd)
  # Search directories using fd, preview directory tree with eza, cd into target
  fcd() {
    local dir
    local cmd='fd --type d --hidden --exclude .git'
    if ! command -v fd &>/dev/null; then
      cmd='find . -type d -not -path "*/.*"'
    fi

    dir=$(eval "$cmd" | fzf --preview 'eza --tree --color=always {} 2>/dev/null | head -200' --height=50%)
    if [[ -n "$dir" ]]; then
      cd "$dir" || return
    fi
  }

  # 3. Interactive File Opener (fe)
  # Select file with fzf and open in $EDITOR
  fe() {
    local files
    local cmd='fd --type f --hidden --exclude .git'
    if ! command -v fd &>/dev/null; then
      cmd='find . -type f -not -path "*/.*"'
    fi

    files=$(eval "$cmd" | fzf --preview 'bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}' --multi)
    if [[ -n "$files" ]]; then
      # Handled array splitting for multiple files safely in zsh
      "${EDITOR:-nvim}" "${(f)files}"
    fi
  }

  # 4. Interactive Process Killer (fkill)
  fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m --header='[kill process]' --preview 'echo {}' | awk '{print $2}')
    if [[ -n "$pid" ]]; then
      echo "$pid" | xargs kill -9
      echo "Killed process(es): $pid"
    fi
  }

  # 5. Interactive Git Log Viewer (fgl)
  fgl() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
      echo "Not inside a git repository." >&2
      return 1
    fi
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | \
    fzf --ansi --no-sort --reverse --tier=1 \
        --preview 'git show --color=always $(echo {} | grep -o "[a-f0-9]\{7\}" | head -1)' \
        --bind 'enter:execute(git show --color=always $(echo {} | grep -o "[a-f0-9]\{7\}" | head -1) | bat --color=always)'
  }

fi
