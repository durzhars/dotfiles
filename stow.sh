#!/usr/bin/env bash
# =============================================================================
# Dotfiles Stow Manager
# =============================================================================

set -e

export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPTS_DIR="$DOTFILES_DIR/scripts/stow"
export TARGET_DIR="$HOME"
export REGISTRY_FILE="$DOTFILES_DIR/stow.registry"
export PROFILE_FILE="$DOTFILES_DIR/stow.profile"
export TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
export AUTO_INSTALL=false

# Source modular libraries
# shellcheck source=scripts/stow/utils.sh
source "$SCRIPTS_DIR/utils.sh"

# shellcheck source=scripts/stow/registry.sh
source "$SCRIPTS_DIR/registry.sh"

# shellcheck source=scripts/stow/manifest.sh
source "$SCRIPTS_DIR/manifest.sh"

# shellcheck source=scripts/stow/dependencies.sh
source "$SCRIPTS_DIR/dependencies.sh"

# shellcheck source=scripts/stow/scanner.sh
source "$SCRIPTS_DIR/scanner.sh"

# shellcheck source=scripts/stow/stow_engine.sh
source "$SCRIPTS_DIR/stow_engine.sh"

# shellcheck source=scripts/stow/commands.sh
source "$SCRIPTS_DIR/commands.sh"

# shellcheck source=scripts/stow/ui.sh
source "$SCRIPTS_DIR/ui.sh"

# Run main CLI router
run_cli "$@"
