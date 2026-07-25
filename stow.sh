#!/usr/bin/env bash
# =============================================================================
# Wrapper script for C Dotfiles Stow Manager (bin/stow-manager)
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY="$DOTFILES_DIR/bin/stow-manager"

if [[ ! -x "$BINARY" ]]; then
    make -C "$DOTFILES_DIR" >/dev/null 2>&1 || make -C "$DOTFILES_DIR"
fi

exec "$BINARY" "$@"
