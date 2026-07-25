#!/usr/bin/env bash
# =============================================================================
# Framework Stow Package Manager & Dependency Resolver
# =============================================================================
# - Data-driven architecture: zero hardcoded package declarations in script.
# - Reads package manifests (`.stowdeps` per package) and central registry (`stow.registry`).
# - Includes recursive auto-scanner (`./stow.sh scan`) to detect binary dependencies
#   from script shebangs, commands, and aliases inside package files.
# - Resolves Stow directory-folding conflicts by converting directory symlinks
#   into real directory structures so GNU Stow manages file-level symlinks natively.
# - Handles mutually exclusive packages (e.g. `terminal` vs `headless`).
# - Backs up unmanaged conflicting target files before stowing.
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME"
REGISTRY_FILE="$DOTFILES_DIR/stow.registry"
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

# -----------------------------------------------------------------------------
# Helper & Diagnostic Output Functions
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

# Dynamic package discovery: lists all package directories containing dotfiles
get_all_packages() {
    local pkgs=()
    for d in "$DOTFILES_DIR"/*/; do
        if [[ -d "$d" ]]; then
            local base
            base="$(basename "$d")"
            if [[ "$base" != "scratch" && "$base" != ".git"* ]]; then
                pkgs+=("$base")
            fi
        fi
    done
    echo "${pkgs[*]}"
}

# -----------------------------------------------------------------------------
# Central Registry & Manifest Parsing Engine
# -----------------------------------------------------------------------------

# Resolves binary executables for a given tool name from stow.registry or defaults
get_binary_aliases() {
    local tool="$1"
    local aliases=("$tool")

    if [[ -f "$REGISTRY_FILE" ]]; then
        while IFS='=' read -r key val || [[ -n "$key" ]]; do
            # Trim whitespace and skip comments/empty lines
            key="$(echo "$key" | xargs 2>/dev/null || true)"
            val="$(echo "$val" | xargs 2>/dev/null || true)"

            if [[ -n "$key" && ! "$key" =~ ^# && "$key" == "$tool" ]]; then
                IFS='|' read -ra split_aliases <<< "$val"
                aliases=()
                for a in "${split_aliases[@]}"; do
                    a="$(echo "$a" | xargs)"
                    [[ -n "$a" ]] && aliases+=("$a")
                done
                break
            fi
        done < "$REGISTRY_FILE"
    fi

    echo "${aliases[*]}"
}

# Translates tool name to distro package name using stow.registry
get_distro_pkg_name() {
    local tool="$1"
    local distro="$2"
    local pkg_name="$tool"

    if [[ -f "$REGISTRY_FILE" ]]; then
        local match_key="${tool}@${distro}"
        while IFS='=' read -r key val || [[ -n "$key" ]]; do
            key="$(echo "$key" | xargs 2>/dev/null || true)"
            val="$(echo "$val" | xargs 2>/dev/null || true)"

            if [[ -n "$key" && ! "$key" =~ ^# && "$key" == "$match_key" ]]; then
                pkg_name="$val"
                break
            fi
        done < "$REGISTRY_FILE"
    fi

    echo "$pkg_name"
}

# Check if a tool or plugin is installed on the host system
is_tool_installed() {
    local tool="$1"
    read -r -a aliases <<< "$(get_binary_aliases "$tool")"

    for bin in "${aliases[@]}"; do
        if command -v "$bin" >/dev/null 2>&1; then
            return 0
        fi
    done

    # Check Zsh plugin file paths if tool is a zsh plugin
    case "$tool" in
        zsh-autosuggestions)
            [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh || -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh || -r /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && return 0
            ;;
        zsh-syntax-highlighting)
            [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh || -r /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && return 0
            ;;
        zsh-history-substring-search)
            [[ -r /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh || -r /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh || -r /home/linuxbrew/.linuxbrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]] && return 0
            ;;
    esac

    return 1
}

# Reads a key from a package's `.stowdeps` manifest file
read_manifest_key() {
    local pkg="$1"
    local key="$2"
    local manifest="$DOTFILES_DIR/$pkg/.stowdeps"

    if [[ -f "$manifest" ]]; then
        while IFS='=' read -r k v || [[ -n "$k" ]]; do
            k="$(echo "$k" | xargs 2>/dev/null || true)"
            if [[ "$k" == "$key" ]]; then
                v="${v#\"}"
                v="${v%\"}"
                echo "$v"
                return 0
            fi
        done < "$manifest"
    fi
}

# -----------------------------------------------------------------------------
# Recursive Code Scanner (Auto-detects dependencies from package contents)
# -----------------------------------------------------------------------------

scan_package_dependencies() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    if [[ ! -d "$pkg_dir" ]]; then
        error "Package directory '${pkg}' does not exist!"
        return 1
    fi

    info "Recursively scanning package content in '${pkg}' for dependencies..."

    local detected_shebangs=()
    local detected_cmds=()

    # 1. Scan Shebangs (#!/bin/zsh, #!/usr/bin/env bash, etc.)
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            local first_line
            first_line="$(head -n 1 "$file" 2>/dev/null || true)"
            if [[ "$first_line" =~ ^#! ]]; then
                local bin
                bin="$(echo "$first_line" | awk '{print $NF}' | xargs basename 2>/dev/null || true)"
                if [[ -n "$bin" && "$bin" != "env" && "$bin" != "sh" ]]; then
                    detected_shebangs+=("$bin")
                fi
            fi
        fi
    done < <(find "$pkg_dir" -type f 2>/dev/null)

    # 2. Scan command invocations in text config/script files
    local known_tools=("starship" "fastfetch" "fzf" "eza" "bat" "fd" "rg" "kitty" "tmux" "nvim" "hyprland" "uwsm" "noctalia" "mpv" "grim" "slurp" "wl-clipboard" "git" "stow" "curl" "htop" "btop" "lazygit")

    for tool in "${known_tools[@]}"; do
        if grep -rq -E "(command -v ${tool}|exec ${tool}|alias .*=${tool}|${tool} init|${tool} -c)" "$pkg_dir" 2>/dev/null; then
            detected_cmds+=("$tool")
        fi
    done

    # Combine & deduplicate
    read -r -a unique_req <<< "$(echo "${detected_shebangs[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
    read -r -a unique_opt <<< "$(echo "${detected_cmds[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"

    info "Scan Results for package '${pkg}':"
    echo -e "  ${BOLD}Detected Shebangs (Required):${NC} ${unique_req[*]:-none}"
    echo -e "  ${BOLD}Detected Invocations (Optional):${NC} ${unique_opt[*]:-none}\n"

    # Write or update .stowdeps manifest if missing
    local manifest="$pkg_dir/.stowdeps"
    if [[ ! -f "$manifest" ]]; then
        info "Auto-generating '.stowdeps' manifest for '${pkg}'..."
        cat <<EOF > "$manifest"
# Package Dependency Manifest for '${pkg}' (auto-generated by stow.sh scan)
REQUIRED="${unique_req[*]}"
OPTIONAL="${unique_opt[*]}"
EOF
        success "Generated '${manifest}'"
    fi
}

# -----------------------------------------------------------------------------
# Dependency & Optional Plugin Checker
# -----------------------------------------------------------------------------

get_install_cmd() {
    local distro="$1"
    shift
    local raw_pkgs=("$@")
    local distro_pkgs=()

    for p in "${raw_pkgs[@]}"; do
        distro_pkgs+=("$(get_distro_pkg_name "$p" "$distro")")
    done

    case "$distro" in
        arch|manjaro|endeavouros)
            echo "sudo pacman -S --needed ${distro_pkgs[*]}"
            ;;
        ubuntu|debian|pop|mint)
            echo "sudo apt update && sudo apt install -y ${distro_pkgs[*]}"
            ;;
        fedora|rhel|centos)
            echo "sudo dnf install -y ${distro_pkgs[*]}"
            ;;
        alpine)
            echo "sudo apk add ${distro_pkgs[*]}"
            ;;
        macos)
            echo "brew install ${distro_pkgs[*]}"
            ;;
        *)
            echo "Install missing packages manually: ${distro_pkgs[*]}"
            ;;
    esac
}

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

check_dependencies() {
    local target_pkg="$1"
    local distro
    distro=$(detect_distro)
    local missing_required=()
    local missing_optional=()

    read -r -a all_packages <<< "$(get_all_packages)"

    echo -e "\n${CYAN}${BOLD}=== Checking Package Dependencies & Optional Plugins ===${NC}\n"

    for pkg_name in "${all_packages[@]}"; do
        # Skip unrelated packages if a specific package was requested
        if [[ -n "$target_pkg" && "$target_pkg" != "all" && "$pkg_name" != "$target_pkg" ]]; then
            continue
        fi

        # If .stowdeps missing, run scan first
        if [[ ! -f "$DOTFILES_DIR/$pkg_name/.stowdeps" ]]; then
            scan_package_dependencies "$pkg_name"
        fi

        local req_tools
        local opt_tools
        req_tools="$(read_manifest_key "$pkg_name" "REQUIRED")"
        opt_tools="$(read_manifest_key "$pkg_name" "OPTIONAL")"

        echo -e "${BOLD}Package [${pkg_name}]:${NC}"

        # 1. Required Dependencies
        echo -e "  ${BOLD}Required Dependencies:${NC}"
        if [[ -n "$req_tools" ]]; then
            for tool in $req_tools; do
                if is_tool_installed "$tool"; then
                    echo -e "    ${GREEN}✓${NC} ${tool}"
                else
                    echo -e "    ${RED}✗${NC} ${tool} ${RED}(REQUIRED MISSING)${NC}"
                    missing_required+=("$tool")
                fi
            done
        else
            echo -e "    ${GREEN}✓${NC} none"
        fi

        # 2. Optional Plugins & Tools
        echo -e "  ${BOLD}Optional Plugins & Tools:${NC}"
        if [[ -n "$opt_tools" ]]; then
            for tool in $opt_tools; do
                if is_tool_installed "$tool"; then
                    echo -e "    ${GREEN}✓${NC} ${tool}"
                else
                    echo -e "    ${YELLOW}⚡${NC} ${tool} ${YELLOW}(optional missing)${NC}"
                    missing_optional+=("$tool")
                fi
            done
        else
            echo -e "    ${GREEN}✓${NC} none"
        fi
        echo ""
    done

    # De-duplicate arrays
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

    while IFS= read -r relative_file; do
        local target_path="$TARGET_DIR/$relative_file"
        local parent_dir
        parent_dir="$(dirname "$target_path")"

        mkdir -p "$parent_dir"

        if [[ -L "$target_path" ]]; then
            info "Removing existing symlink: ${target_path}"
            rm -f "$target_path"
        elif [[ -f "$target_path" || -d "$target_path" ]]; then
            warn "Backing up unmanaged file conflict: ${target_path} -> ${target_path}.bak.${TIMESTAMP}"
            mv "$target_path" "${target_path}.bak.${TIMESTAMP}"
        fi
    done < <(cd "$pkg_dir" && find . ! -type d -a ! -name '.stowdeps' 2>/dev/null | sed 's|^\./||')
}

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

is_package_stowed() {
    local pkg="$1"
    local pkg_dir="$DOTFILES_DIR/$pkg"

    if [[ ! -d "$pkg_dir" ]]; then
        return 1
    fi

    while IFS= read -r relative_path; do
        local target_path="$TARGET_DIR/$relative_path"
        if [[ -L "$target_path" ]]; then
            local link_dest
            link_dest="$(readlink -f "$target_path" 2>/dev/null || true)"
            if [[ "$link_dest" == "$pkg_dir"* ]]; then
                return 0
            fi
        fi
    done < <(cd "$pkg_dir" && find . ! -type d -a ! -name '.stowdeps' 2>/dev/null | sed 's|^\./||')

    return 1
}

# -----------------------------------------------------------------------------
# Stow Actions
# -----------------------------------------------------------------------------

stow_package() {
    local pkg="$1"
    info "Stowing package '${pkg}'..."

    check_dependencies "$pkg"
    handle_mutual_exclusions "$pkg"
    unfold_directory_symlinks
    prepare_target_conflicts "$pkg"

    if stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" --no-folding --ignore='\.stowdeps' -v -R "$pkg"; then
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

    if stow -d "$DOTFILES_DIR" -t "$TARGET_DIR" --no-folding --ignore='\.stowdeps' -v -D "$pkg"; then
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

# -----------------------------------------------------------------------------
# Main Entry Point
# -----------------------------------------------------------------------------

show_help() {
    echo -e "${BOLD}Dotfiles Framework Stow Manager & Dependency Resolver${NC}"
    echo -e "Usage: $0 [options] <command> [package]\n"
    echo -e "Options:"
    echo -e "  ${CYAN}-y, --install${NC}       Auto-confirm installation of missing dependencies/plugins"
    echo -e "\nCommands:"
    echo -e "  ${CYAN}check${NC} [pkg]         Detect missing dependencies & optional plugins"
    echo -e "  ${CYAN}scan${NC} [pkg]          Recursively scan package content to detect & auto-generate .stowdeps"
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
        scan)
            if [[ -n "$pkg" ]]; then
                scan_package_dependencies "$pkg"
            else
                read -r -a packages <<< "$(get_all_packages)"
                for p in "${packages[@]}"; do
                    scan_package_dependencies "$p"
                done
            fi
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
