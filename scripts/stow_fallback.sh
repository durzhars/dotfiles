#!/usr/bin/env bash
# =============================================================================
# Dotfiles Stow Manager - Pure Shell Fallback Script
# =============================================================================
# Used automatically when the compiled C binary (stow-manager) is not present.
# Uses pure Bash parameter expansions (zero subshell forks in loops).
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$HOME"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
AUTO_INSTALL=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}${BOLD}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[SUCCESS]${NC} $1"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARNING]${NC} $1"; }
error()   { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; }

trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        local ID=""
        while IFS='=' read -r k v || [[ -n "$k" ]]; do
            if [[ "$k" == "ID" ]]; then
                v="${v#\"}"
                v="${v%\"}"
                echo "$v"
                return
            fi
        done < /etc/os-release
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
            local base="${d%/}"
            base="${base##*/}"
            if [[ "$base" != "scratch" && "$base" != "scripts" && "$base" != ".git"* && "$base" != "misc" ]]; then
                pkgs+=("$base")
            fi
        fi
    done
    echo "${pkgs[*]}"
}

is_tool_installed() {
    local tool="$1"
    case "$tool" in
        wl-clipboard)
            command -v wl-copy >/dev/null 2>&1 || command -v wl-paste >/dev/null 2>&1
            ;;
        fd)
            command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1
            ;;
        zsh-autosuggestions)
            [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh || \
               -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh || \
               -r /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]
            ;;
        zsh-syntax-highlighting)
            [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || \
               -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || \
               -r /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]
            ;;
        zsh-history-substring-search)
            [[ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh || \
               -r /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh || \
               -r /home/linuxbrew/.linuxbrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]]
            ;;
        *)
            command -v "$tool" >/dev/null 2>&1
            ;;
    esac
}

read_manifest_key() {
    local pkg="$1"
    local target_key="$2"
    local manifest="$DOTFILES_DIR/$pkg/.stowdeps"

    if [[ -f "$manifest" ]]; then
        while IFS='=' read -r k v || [[ -n "$k" ]]; do
            k="${k#"${k%%[![:space:]]*}"}"
            k="${k%"${k##*[![:space:]]}"}"
            if [[ "$k" == "$target_key" ]]; then
                v="${v#"${v%%[![:space:]]*}"}"
                v="${v%"${v##*[![:space:]]}"}"
                v="${v#\"}"
                v="${v%\"}"
                printf '%s' "$v"
                return 0
            fi
        done < "$manifest"
    fi
}

unfold_directory_symlinks() {
    info "Scanning for directory symlinks that cause Stow folding conflicts..."
    local unfolded_count=0

    while IFS= read -r symlink_path; do
        if [[ -L "$symlink_path" && -d "$symlink_path" ]]; then
            local target
            target="$(readlink -f "$symlink_path" 2>/dev/null || true)"

            if [[ "$target" == "$DOTFILES_DIR"* ]]; then
                warn "Unfolding directory symlink: ${symlink_path} -> ${target}"
                rm -f "$symlink_path"
                mkdir -p "$symlink_path"
                unfolded_count=$((unfolded_count + 1))
            fi
        fi
    done < <(find "$HOME" -maxdepth 6 -type l 2>/dev/null)

    if [[ $unfolded_count -gt 0 ]]; then
        success "Successfully unfolded ${unfolded_count} directory symlinks into real directories!"
    else
        info "No directory symlinks required unfolding."
    fi
}

prepare_target_conflicts() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    if [[ ! -d "$pkg_dir" ]]; then
        error "Package directory '${pkg}' does not exist!"
        return 1
    fi

    info "Preparing target paths and resolving conflicts for package '${pkg}'..."

    while IFS= read -r file; do
        local relative_file="${file#$pkg_dir/}"
        local target_path="$TARGET_DIR/$relative_file"
        local parent_dir="${target_path%/*}"

        mkdir -p "$parent_dir"

        if [[ -L "$target_path" ]]; then
            info "Removing existing symlink: ${target_path}"
            rm -f "$target_path"
        elif [[ -f "$target_path" || -d "$target_path" ]]; then
            warn "Backing up unmanaged file conflict: ${target_path} -> ${target_path}.bak.${TIMESTAMP}"
            mv "$target_path" "${target_path}.bak.${TIMESTAMP}"
        fi
    done < <(find "$pkg_dir" ! -type d -a ! -name '.stowdeps' 2>/dev/null)
}

is_package_stowed() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    if [[ ! -d "$pkg_dir" ]]; then
        return 1
    fi

    while IFS= read -r file; do
        local relative_path="${file#$pkg_dir/}"
        local target_path="$TARGET_DIR/$relative_path"
        if [[ -L "$target_path" ]]; then
            local link_dest
            link_dest="$(readlink -f "$target_path" 2>/dev/null || true)"
            if [[ "$link_dest" == "$pkg_dir"* ]]; then
                return 0
            fi
        fi
    done < <(find "$pkg_dir" ! -type d -a ! -name '.stowdeps' 2>/dev/null)

    return 1
}

stow_package() {
    local pkg="$1"
    info "Stowing package '${pkg}' (fallback mode)..."

    unfold_directory_symlinks
    prepare_target_conflicts "$pkg"

    if stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" --no-folding --ignore='\.stowdeps' -v -R "$pkg"; then
        success "Successfully stowed package '${pkg}'!"
    else
        error "Failed to stow package '${pkg}'."
        return 1
    fi
}

list_packages() {
    echo -e "\n${CYAN}${BOLD}=== Available Dotfiles Packages (Fallback Mode) ===${NC}\n"

    read -r -a packages <<< "$(get_all_packages)"
    for pkg in "${packages[@]}"; do
        if is_package_stowed "$pkg"; then
            echo -e "  ${GREEN}●${NC} ${BOLD}${pkg}${NC} ${GREEN}(stowed)${NC}"
        else
            echo -e "  ${RED}○${NC} ${pkg} (not stowed)"
        fi
    done
    echo ""
}

main() {
    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        list)
            list_packages
            ;;
        stow)
            stow_package "$1"
            ;;
        *)
            if [[ -d "$DOTFILES_DIR/$cmd" ]]; then
                stow_package "$cmd"
            else
                list_packages
            fi
            ;;
    esac
}

main "$@"
