#!/usr/bin/env bash
# =============================================================================
# Stow Package Manager & Conflict Resolver for Dotfiles
# =============================================================================
# - Auto-detects missing CLI / GUI dependencies based on host OS/distro.
# - Resolves Stow directory-folding conflicts by converting directory symlinks
#   into real directory structures so GNU Stow manages file-level symlinks natively.
# - Handles mutually exclusive packages (e.g. `terminal` vs `headless`).
# - Backs up unmanaged conflicting target files before stowing.
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Package Mutually Exclusive Mapping
# format: "pkg1:pkg2" means stowing pkg1 will auto-unstow pkg2 if present
MUTUAL_EXCLUSIONS=(
    "headless:terminal"
    "terminal:headless"
)

# Package Dependency Mapping
# format: "pkg_name|cmd1 cmd2 cmd3..."
PACKAGE_DEPS=(
    "common|stow git"
    "terminal|zsh bash starship fastfetch fzf eza bat fd rg kitty"
    "headless|zsh bash starship fastfetch fzf eza bat fd rg tmux"
    "nvim|nvim git fd rg"
    "hyprland|hyprland uwsm noctalia mpv"
)

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

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

# Detect Host Distro
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

# Display package installation command recommendation
get_install_cmd() {
    local distro="$1"
    shift
    local pkgs=("$@")

    case "$distro" in
        arch|manjaro|endeavouros)
            echo "sudo pacman -S --needed ${pkgs[*]}"
            ;;
        ubuntu|debian|pop|mint)
            echo "sudo apt update && sudo apt install -y ${pkgs[*]}"
            ;;
        fedora|rhel|centos)
            echo "sudo dnf install -y ${pkgs[*]}"
            ;;
        alpine)
            echo "sudo apk add ${pkgs[*]}"
            ;;
        macos)
            echo "brew install ${pkgs[*]}"
            ;;
        *)
            echo "Install missing packages manually: ${pkgs[*]}"
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Dependency Checker
# -----------------------------------------------------------------------------

check_dependencies() {
    local target_pkg="$1"
    local distro
    distro=$(detect_distro)
    local missing_all=()

    echo -e "\n${CYAN}${BOLD}=== Checking System Dependencies ===${NC}\n"

    for entry in "${PACKAGE_DEPS[@]}"; do
        local pkg_name="${entry%%|*}"
        local tools="${entry#*|}"

        # If a specific package was requested, skip unrelated packages (except common)
        if [[ -n "$target_pkg" && "$target_pkg" != "all" && "$pkg_name" != "common" && "$pkg_name" != "$target_pkg" ]]; then
            continue
        fi

        echo -e "${BOLD}Package [${pkg_name}]:${NC}"

        for tool in $tools; do
            if command -v "$tool" >/dev/null 2>&1; then
                echo -e "  ${GREEN}✓${NC} ${tool}"
            else
                echo -e "  ${RED}✗${NC} ${tool} ${YELLOW}(missing)${NC}"
                missing_all+=("$tool")
            fi
        done
        echo ""
    done

    if [[ ${#missing_all[@]} -gt 0 ]]; then
        read -r -a unique_missing <<< "$(echo "${missing_all[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
        warn "Missing dependencies detected for your environment!"
        echo -e "${BOLD}Recommended installation command (${distro}):${NC}"
        echo -e "  ${CYAN}$(get_install_cmd "$distro" "${unique_missing[@]}")${NC}\n"
    else
        success "All required dependencies are installed!"
    fi
}

# -----------------------------------------------------------------------------
# Directory Unfolder & Conflict Resolver
# -----------------------------------------------------------------------------

# Unfolds directory symlinks in $HOME pointing into $DOTFILES_DIR
# Converts directory symlinks into real directories so Stow can manage file symlinks.
unfold_directory_symlinks() {
    info "Scanning for directory symlinks that cause Stow folding conflicts..."
    local unfolded_count=0

    # Search for symlinks in $HOME and $HOME/.config up to depth 6 pointing into $DOTFILES_DIR
    while IFS= read -r symlink_path; do
        if [[ -L "$symlink_path" && -d "$symlink_path" ]]; then
            local target
            target="$(readlink -f "$symlink_path" 2>/dev/null || true)"

            # Check if target is inside dotfiles directory
            if [[ "$target" == "$DOTFILES_DIR"* ]]; then
                warn "Unfolding directory symlink: ${symlink_path} -> ${target}"

                # Remove the directory symlink
                rm -f "$symlink_path"

                # Recreate as a real directory
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

# Prepares target paths for a package: removes old symlinks and backs up real file conflicts
prepare_target_conflicts() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    if [[ ! -d "$pkg_dir" ]]; then
        error "Package directory '${pkg}' does not exist!"
        return 1
    fi

    info "Preparing target paths and resolving conflicts for package '${pkg}'..."

    # Find all non-directory items (files and symlinks) inside the package
    while IFS= read -r relative_file; do
        local target_path="$TARGET_DIR/$relative_file"
        local parent_dir
        parent_dir="$(dirname "$target_path")"

        # Ensure parent directory exists as a real directory
        mkdir -p "$parent_dir"

        # If target path exists or is a symlink
        if [[ -L "$target_path" ]]; then
            # Any existing symlink at target path is removed so stow can link cleanly
            info "Removing existing symlink: ${target_path}"
            rm -f "$target_path"
        elif [[ -f "$target_path" || -d "$target_path" ]]; then
            # Real unmanaged file or directory blocking stow
            warn "Backing up unmanaged file conflict: ${target_path} -> ${target_path}.bak.${TIMESTAMP}"
            mv "$target_path" "${target_path}.bak.${TIMESTAMP}"
        fi
    done < <(cd "$pkg_dir" && find . ! -type d 2>/dev/null | sed 's|^\./||')
}

# Handle mutually exclusive packages
handle_mutual_exclusions() {
    local target_pkg="$1"

    for rule in "${MUTUAL_EXCLUSIONS[@]}"; do
        local pkg="${rule%%:*}"
        local conflicting_pkg="${rule#*:}"

        if [[ "$target_pkg" == "$pkg" ]]; then
            if is_package_stowed "$conflicting_pkg"; then
                warn "Package '${pkg}' conflicts with currently stowed package '${conflicting_pkg}'."
                info "Auto-unstowing conflicting package '${conflicting_pkg}' first..."
                unstow_package "$conflicting_pkg"
            fi
        fi
    done
}

# Check if a package is currently stowed
is_package_stowed() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    if [[ ! -d "$pkg_dir" ]]; then
        return 1
    fi

    # Check if any file in target points into this package in dotfiles
    while IFS= read -r relative_path; do
        local target_path="$TARGET_DIR/$relative_path"
        if [[ -L "$target_path" ]]; then
            local link_dest
            link_dest="$(readlink -f "$target_path" 2>/dev/null || true)"
            if [[ "$link_dest" == "$pkg_dir"* ]]; then
                return 0
            fi
        fi
    done < <(cd "$pkg_dir" && find . ! -type d 2>/dev/null | sed 's|^\./||')

    return 1
}

# -----------------------------------------------------------------------------
# Stow Actions
# -----------------------------------------------------------------------------

stow_package() {
    local pkg="$1"
    info "Stowing package '${pkg}'..."

    # Check dependencies first
    check_dependencies "$pkg"

    # Handle mutual exclusions (e.g. terminal vs headless)
    handle_mutual_exclusions "$pkg"

    # Unfold any directory symlinks in $HOME
    unfold_directory_symlinks

    # Prepare target paths & backup unmanaged conflicting files
    prepare_target_conflicts "$pkg"

    # Execute stow with --no-folding to prevent future folder-level conflicts
    if stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" --no-folding -v -R "$pkg"; then
        success "Successfully stowed package '${pkg}'!"
    else
        error "Failed to stow package '${pkg}'."
        return 1
    fi
}

unstow_package() {
    local pkg="$1"
    info "Unstowing package '${pkg}'..."

    unfold_directory_symlinks

    if stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" --no-folding -v -D "$pkg"; then
        success "Successfully unstowed package '${pkg}'!"
    else
        error "Failed to unstow package '${pkg}'."
        return 1
    fi
}

restow_package() {
    local pkg="$1"
    info "Restowing package '${pkg}'..."
    stow_package "$pkg"
}

list_packages() {
    echo -e "\n${CYAN}${BOLD}=== Available Dotfiles Packages ===${NC}\n"

    for dir in "$DOTFILES_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            local pkg
            pkg="$(basename "$dir")"
            if is_package_stowed "$pkg"; then
                echo -e "  ${GREEN}●${NC} ${BOLD}${pkg}${NC} ${GREEN}(stowed)${NC}"
            else
                echo -e "  ${RED}○${NC} ${pkg} (not stowed)"
            fi
        fi
    done
    echo ""
}

# -----------------------------------------------------------------------------
# Main Entry Point
# -----------------------------------------------------------------------------

show_help() {
    echo -e "${BOLD}Dotfiles Stow Sync & Conflict Resolver${NC}"
    echo -e "Usage: $0 <command> [package]\n"
    echo -e "Commands:"
    echo -e "  ${CYAN}check${NC} [pkg]         Auto-detect missing CLI/GUI dependencies"
    echo -e "  ${CYAN}list${NC}                List all packages and stowed status"
    echo -e "  ${CYAN}stow${NC} <pkg>          Stow a package with auto conflict resolution"
    echo -e "  ${CYAN}unstow${NC} <pkg>        Unstow a package"
    echo -e "  ${CYAN}restow${NC} <pkg>        Restow a package"
    echo -e "  ${CYAN}fix-conflicts${NC}       Unfold directory symlinks & resolve conflicts"
    echo -e "  ${CYAN}terminal${NC}            Stow desktop terminal package (unstows headless)"
    echo -e "  ${CYAN}headless${NC}            Stow headless terminal package (unstows terminal)"
    echo -e "  ${CYAN}all${NC}                 Stow standard desktop environment packages"
    echo -e "  ${CYAN}help${NC}                Show this help menu"
}

main() {
    local cmd="${1:-help}"
    local pkg="$2"

    case "$cmd" in
        check)
            check_dependencies "$pkg"
            ;;
        list)
            list_packages
            ;;
        stow)
            if [[ -z "$pkg" ]]; then
                error "Please specify a package name to stow!"
                exit 1
            fi
            stow_package "$pkg"
            ;;
        unstow)
            if [[ -z "$pkg" ]]; then
                error "Please specify a package name to unstow!"
                exit 1
            fi
            unstow_package "$pkg"
            ;;
        restow)
            if [[ -z "$pkg" ]]; then
                error "Please specify a package name to restow!"
                exit 1
            fi
            restow_package "$pkg"
            ;;
        fix-conflicts)
            unfold_directory_symlinks
            ;;
        terminal)
            stow_package "terminal"
            ;;
        headless)
            stow_package "headless"
            ;;
        all)
            stow_package "terminal"
            stow_package "nvim"
            stow_package "hyprland"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            if [[ -d "$DOTFILES_DIR/$cmd" ]]; then
                stow_package "$cmd"
            else
                error "Unknown command or package '${cmd}'"
                show_help
                exit 1
            fi
            ;;
    esac
}

main "$@"
