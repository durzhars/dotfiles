#!/usr/bin/env bash
# =============================================================================
# Artisan-Style Modular Dotfiles Framework Stow Manager
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts/stow"
TARGET_DIR="$HOME"
REGISTRY_FILE="$DOTFILES_DIR/stow.registry"
PROFILE_FILE="$DOTFILES_DIR/stow.profile"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
AUTO_INSTALL=false

# Source modular libraries
source "$SCRIPTS_DIR/utils.sh"
source "$SCRIPTS_DIR/registry.sh"
source "$SCRIPTS_DIR/manifest.sh"
source "$SCRIPTS_DIR/dependencies.sh"
source "$SCRIPTS_DIR/scanner.sh"
source "$SCRIPTS_DIR/stow_engine.sh"
source "$SCRIPTS_DIR/artisan.sh"
source "$SCRIPTS_DIR/ui.sh"

# Run main CLI router
run_cli "$@"
