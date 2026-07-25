#!/usr/bin/env bash
# =============================================================================
# Stow Manager Module: Dependency & Optional Plugin Checker
# =============================================================================

get_install_cmd() {
    local distro="$1"
    shift
    local raw_pkgs=("$@")
    local distro_pkgs=()

    for p in "${raw_pkgs[@]}"; do
        distro_pkgs+=("$(get_distro_pkg_name "$p" "$distro")")
    done

    case "$distro" in
        arch | manjaro | endeavouros)
            echo "sudo pacman -S --needed ${distro_pkgs[*]}"
            ;;
        ubuntu | debian | pop | mint)
            echo "sudo apt update && sudo apt install -y ${distro_pkgs[*]}"
            ;;
        fedora | rhel | centos)
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

    read -r -a all_packages <<<"$(get_all_packages)"

    echo -e "\n${CYAN}${BOLD}=== Checking Package Dependencies & Optional Plugins ===${NC}\n"

    for pkg_name in "${all_packages[@]}"; do
        if [[ -n "$target_pkg" && "$target_pkg" != "all" && "$pkg_name" != "$target_pkg" ]]; then
            continue
        fi

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
        read -r -a unique_req <<<"$(echo "${missing_required[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
    fi
    if [[ ${#missing_optional[@]} -gt 0 ]]; then
        read -r -a unique_opt <<<"$(echo "${missing_optional[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')"
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
