#!/usr/bin/env bash
# shellcheck shell=bash
# =============================================================================
# Stow Manager Module: Utils & General Helpers
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}${BOLD}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}${BOLD}[ERROR]${NC} $1"
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        echo "$ID"
    elif command -v brew >/dev/null 2>&1; then
        echo "macos"
    else
        echo "unknown"
    fi
}

get_all_packages() {
    local pkgs=()
    for d in "$DOTFILES_DIR"/*/; do
        if [[ -d "$d" ]]; then
            local base
            base="$(basename "$d")"
            if [[ "$base" != "scratch" && "$base" != "scripts" && "$base" != ".git"* ]]; then
                pkgs+=("$base")
            fi
        fi
    done
    echo "${pkgs[*]}"
}
