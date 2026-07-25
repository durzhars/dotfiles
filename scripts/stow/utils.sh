#!/usr/bin/env bash
# =============================================================================
# Stow Manager Module: Utils & General Helpers
# =============================================================================

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export BOLD='\033[1m'
export NC='\033[0m' # No Color

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
