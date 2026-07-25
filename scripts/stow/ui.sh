#!/usr/bin/env bash
# shellcheck shell=bash
# =============================================================================
# Stow Manager Module: UI, Help Menus & Main Router
# =============================================================================

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

show_help() {
    echo -e "${BOLD}Artisan-Style Modular Dotfiles Framework Manager${NC}"
    echo -e "Usage: $0 [options] <command> [arguments]\n"
    echo -e "Options:"
    echo -e "  ${CYAN}-y, --install${NC}                  Auto-confirm installation of missing dependencies/plugins"
    echo -e "\nDependency Management Commands (Artisan-style):"
    echo -e "  ${CYAN}deps:add${NC} <pkg> <dep> [--opt]   Add a dependency/conflict to package manifest"
    echo -e "  ${CYAN}deps:remove${NC} <pkg> <dep>        Remove a dependency from package manifest"
    echo -e "  ${CYAN}deps:show${NC} <pkg>               Display package manifest contents"
    echo -e "  ${CYAN}make:package${NC} <name>            Scaffold a new Stow package directory & manifest"
    echo -e "  ${CYAN}registry:add${NC} <tool> <alias>    Add binary alias/distro mapping to stow.registry"
    echo -e "\nPackage & Stow Operations:"
    echo -e "  ${CYAN}check${NC} [pkg]                    Detect missing dependencies & optional plugins"
    echo -e "  ${CYAN}scan${NC} [pkg]                     Recursively scan package files to auto-detect dependencies"
    echo -e "  ${CYAN}list${NC}                           List all packages and stowed status"
    echo -e "  ${CYAN}stow${NC} <pkg>                     Stow a package with auto conflict resolution"
    echo -e "  ${CYAN}unstow${NC} <pkg>                   Unstow a package"
    echo -e "  ${CYAN}restow${NC} <pkg>                   Restow a package"
    echo -e "  ${CYAN}fix-conflicts${NC}                  Unfold directory symlinks & resolve conflicts"
    echo -e "  ${CYAN}all${NC}                            Stow default environment profile packages"
    echo -e "  ${CYAN}help${NC}                           Show this help menu"
}

run_cli() {
    while [[ "$1" == -* ]]; do
        case "$1" in
            -y|--install)
                export AUTO_INSTALL=true
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
    shift || true

    case "$cmd" in
        deps:add)
            cmd_deps_add "$1" "$2" "$3"
            ;;
        deps:remove|deps:rm)
            cmd_deps_remove "$1" "$2"
            ;;
        deps:show|deps:list)
            cmd_deps_show "$1"
            ;;
        make:package|make:pkg)
            cmd_make_package "$1"
            ;;
        registry:add)
            cmd_registry_add "$1" "$2" "$3"
            ;;
        check)
            check_dependencies "$1"
            ;;
        scan)
            if [[ -n "$1" ]]; then
                scan_package_dependencies "$1"
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
            if [[ -z "$1" ]]; then
                error "Please specify a package name to stow!"
                exit 1
            fi
            stow_package "$1"
            ;;
        unstow)
            if [[ -z "$1" ]]; then
                error "Please specify a package name to unstow!"
                exit 1
            fi
            unstow_package "$1"
            ;;
        restow)
            if [[ -z "$1" ]]; then
                error "Please specify a package name to restow!"
                exit 1
            fi
            restow_package "$1"
            ;;
        fix-conflicts)
            unfold_directory_symlinks
            ;;
        all)
            cmd_stow_all
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
