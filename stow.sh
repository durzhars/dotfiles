#!/usr/bin/env bash
# =============================================================================
# Stow Package Manager & Conflict Resolver for Dotfiles
# =============================================================================
# - Auto-detects required dependencies AND optional plugins/tools per package.
# - Interactively prompts user to install missing required tools & optional plugins.
# - Resolves Stow directory-folding conflicts by converting directory symlinks
#   into real directory structures so GNU Stow manages file-level symlinks natively.
# - Handles mutually exclusive packages (e.g. `terminal` vs `headless`).
# - Backs up unmanaged conflicting target files before stowing.
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
AUTO_INSTALL=false

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
MUTUAL_EXCLUSIONS=(
    "headless:terminal"
    "terminal:headless"
)

# Required Dependencies per Package
PACKAGE_REQUIRED_DEPS=(
    "common|stow git"
    "terminal|zsh bash"
    "headless|zsh bash tmux"
    "nvim|nvim git"
    "hyprland|hyprland"
)

# Optional Plugins & Tools per Package
PACKAGE_OPTIONAL_PLUGINS=(
    "common|curl"
    "terminal|starship fastfetch fzf eza bat fd rg kitty zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search"
    "headless|starship fastfetch fzf eza bat fd rg htop btop zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search"
    "nvim|fd rg lazygit gcc make npm python3"
    "hyprland|uwsm noctalia mpv grim slurp wl-clipboard"
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

# Check if a tool or plugin is installed on the host system
is_tool_installed() {
    local item="$1"

    case "$item" in
        wl-clipboard)
            if command -v wl-copy >/dev/null 2>&1 || command -v wl-paste >/dev/null 2>&1; then
                return 0
            fi
            ;;
        fd)
            if command -v fd >/dev/null 2>&1 || command -v fdfind >/dev/null 2>&1; then
                return 0
            fi
            ;;
        zsh-autosuggestions)
            if [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh || -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh || -r /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
                return 0
            fi
            ;;
        zsh-syntax-highlighting)
            if [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || -r /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
                return 0
            fi
            ;;
        zsh-history-substring-search)
            if [[ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh || -r /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh || -r /home/linuxbrew/.linuxbrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]]; then
                return 0
            fi
            ;;
        *)
            if command -v "$item" >/dev/null 2>&1; then
                return 0
            fi
            ;;
    esac

    return 1
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
            local deb_pkgs=()
            for p in "${pkgs[@]}"; do
                case "$p" in
                    fd) deb_pkgs+=("fd-find") ;;
                    rg) deb_pkgs+=("ripgrep") ;;
                    *) deb_pkgs+=("$p") ;;
                esac
            done
            echo "sudo apt update && sudo apt install -y ${deb_pkgs[*]}"
            ;;
        fedora|rhel|centos)
            local dnf_pkgs=()
            for p in "${pkgs[@]}"; do
                case "$p" in
                    fd) dnf_pkgs+=("fd-find") ;;
                    rg) dnf_pkgs+=("ripgrep") ;;
                    *) dnf_pkgs+=("$p") ;;
                esac
            done
            echo "sudo dnf install -y ${dnf_pkgs[*]}"
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

# Execute installation command for missing packages
install_packages() {
    local distro="$1"
    shift
    local pkgs=("$@")

    local cmd
    cmd="$(get_install_cmd "$distro" "${pkgs[@]}")"

    info "Executing package installation command:"
    echo -e "${CYAN}${BOLD}${cmd}${NC}\n"

    if eval "$cmd"; then
        success "Package installation completed successfully!"
    else
        error "Package installation failed or was aborted."
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Dependency & Optional Plugin Checker
# -----------------------------------------------------------------------------

check_dependencies() {
    local target_pkg="$1"
    local distro
    distro=$(detect_distro)
    local missing_required=()
    local missing_optional=()

    echo -e "\n${CYAN}${BOLD}=== Checking Package Dependencies & Optional Plugins ===${NC}\n"

    # Scan all relevant packages
    for entry in "${PACKAGE_REQUIRED_DEPS[@]}"; do
        local pkg_name="${entry%%|*}"
        local req_tools="${entry#*|}"

        # Skip unrelated packages if a specific package was requested
        if [[ -n "$target_pkg" && "$target_pkg" != "all" && "$pkg_name" != "common" && "$pkg_name" != "$target_pkg" ]]; then
            continue
        fi

        echo -e "${BOLD}Package [${pkg_name}]:${NC}"

        # 1. Check Required Dependencies
        echo -e "  ${BOLD}Required Dependencies:${NC}"
        for tool in $req_tools; do
            if is_tool_installed "$tool"; then
                echo -e "    ${GREEN}✓${NC} ${tool}"
            else
                echo -e "    ${RED}✗${NC} ${tool} ${RED}(REQUIRED MISSING)${NC}"
                missing_required+=("$tool")
            fi
        done

        # 2. Check Optional Plugins & Tools
        local opt_tools=""
        for opt_entry in "${PACKAGE_OPTIONAL_PLUGINS[@]}"; do
            if [[ "${opt_entry%%|*}" == "$pkg_name" ]]; then
                opt_tools="${opt_entry#*|}"
                break
            fi
        done

        if [[ -n "$opt_tools" ]]; then
            echo -e "  ${BOLD}Optional Plugins & Tools:${NC}"
            for tool in $opt_tools; do
                if is_tool_installed "$tool"; then
                    echo -e "    ${GREEN}✓${NC} ${tool}"
                else
                    echo -e "    ${YELLOW}⚡${NC} ${tool} ${YELLOW}(optional missing)${NC}"
                    missing_optional+=("$tool")
                fi
            done
        fi
        echo ""
    done

    # De-duplicate missing arrays
    local unique_req=()
    local unique_opt=()
    if [[ ${#missing_required[@]} -gt 0 ]]; then
        read -r -a unique_req <<< "$(echo "${missing_required[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
    fi
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        read -r -a unique_opt <<< "$(echo "${missing_optional[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
    fi

    # Interactive / Automatic Installation Prompts
    if [[ ${#unique_req[@]} -gt 0 ]]; then
        error "Missing REQUIRED dependencies: ${unique_req[*]}"
        local req_cmd
        req_cmd="$(get_install_cmd "$distro" "${unique_req[@]}")"
        echo -e "${BOLD}Installation Command (${distro}):${NC} ${CYAN}${req_cmd}${NC}\n"

        if [[ "$AUTO_INSTALL" == true ]]; then
            install_packages "$distro" "${unique_req[@]}"
        elif [[ -t 0 ]]; then
            read -p "Would you like to install missing REQUIRED dependencies now? [Y/n] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ || -z $REPLY ]]; then
                install_packages "$distro" "${unique_req[@]}"
            fi
        fi
    fi

    if [[ ${#unique_opt[@]} -gt 0 ]]; then
        warn "Missing OPTIONAL plugins & tools: ${unique_opt[*]}"
        local opt_cmd
        opt_cmd="$(get_install_cmd "$distro" "${unique_opt[@]}")"
        echo -e "${BOLD}Installation Command (${distro}):${NC} ${CYAN}${opt_cmd}${NC}\n"

        if [[ "$AUTO_INSTALL" == true ]]; then
            install_packages "$distro" "${unique_opt[@]}"
        elif [[ -t 0 ]]; then
            read -p "Would you like to install missing OPTIONAL plugins & tools now? [y/N] " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_packages "$distro" "${unique_opt[@]}"
            fi
        fi
    fi

    if [[ ${#unique_req[@]} -eq 0 && ${#unique_opt[@]} -eq 0 ]]; then
        success "All required dependencies and optional plugins are installed!"
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

    # Check dependencies & plugins first
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
    echo -e "Usage: $0 [options] <command> [package]\n"
    echo -e "Options:"
    echo -e "  ${CYAN}-y, --install${NC}       Auto-confirm installation of missing dependencies/plugins"
    echo -e "\nCommands:"
    echo -e "  ${CYAN}check${NC} [pkg]         Detect missing dependencies & optional plugins"
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
    # Parse options
    while [[ "$1" == -* ]]; do
        case "$1" in
            -y|--install)
                AUTO_INSTALL=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                break
                ;;
        esac
    done

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
