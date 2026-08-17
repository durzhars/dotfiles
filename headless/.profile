# ~/.profile — Sourced by login shells (sh, bash, SSH login)

# User-specific PATH (prioritizing ~/.local/bin)
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi
export PATH

# Set default editor if not already set
if [ -z "$EDITOR" ]; then
    if command -v nvim >/dev/null 2>&1; then
        export EDITOR="nvim"
    elif command -v vim >/dev/null 2>&1; then
        export EDITOR="vim"
    fi
fi

# Source .bashrc if running interactive bash
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
