#!/usr/bin/env bash
# =============================================================================
# Entrypoint launcher for stow-manager binary
# =============================================================================

if command -v stow-manager >/dev/null 2>&1; then
    exec stow-manager "$@"
elif [[ -x "$HOME/.local/bin/stow-manager" ]]; then
    exec "$HOME/.local/bin/stow-manager" "$@"
else
    echo "[ERROR] stow-manager binary not found! Please install from ~/Projects/stow-manager" >&2
    exit 1
fi
