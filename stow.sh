#!/usr/bin/env bash
# =============================================================================
# Dotfiles Stow Manager - Entrypoint Launcher & Shell Fallback
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Primary: Run compiled C binary if installed
if command -v stow-manager >/dev/null 2>&1; then
    exec stow-manager "$@"
elif [[ -x "$HOME/.local/bin/stow-manager" ]]; then
    exec "$HOME/.local/bin/stow-manager" "$@"
elif [[ -x "$DOTFILES_DIR/bin/stow-manager" ]]; then
    exec "$DOTFILES_DIR/bin/stow-manager" "$@"
fi

# 2. Fallback: Run pure Shell manager if C binary is not installed
if [[ -x "$DOTFILES_DIR/scripts/stow_fallback.sh" ]]; then
    exec "$DOTFILES_DIR/scripts/stow_fallback.sh" "$@"
elif [[ -f "$DOTFILES_DIR/scripts/stow_fallback.sh" ]]; then
    exec bash "$DOTFILES_DIR/scripts/stow_fallback.sh" "$@"
else
    echo "[ERROR] Neither stow-manager binary nor scripts/stow_fallback.sh found!" >&2
    exit 1
fi
