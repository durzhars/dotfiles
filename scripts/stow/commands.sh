#!/usr/bin/env bash
# shellcheck shell=bash
# =============================================================================
# Stow Manager Module: Terminal Commands
# =============================================================================

cmd_deps_add() {
    local pkg="$1"
    local dep="$2"
    local type="${3:---optional}"

    if [[ -z "$pkg" || -z "$dep" ]]; then
        error "Usage: $0 deps:add <package> <dependency_name> [--required|--optional|--conflict]"
        return 1
    fi

    local target_key="OPTIONAL"
    if [[ "$type" == "--required" || "$type" == "-r" ]]; then
        target_key="REQUIRED"
    elif [[ "$type" == "--conflict" || "$type" == "-c" ]]; then
        target_key="CONFLICTS"
    fi

    local current_val
    current_val="$(read_manifest_key "$pkg" "$target_key")"

    if [[ " $current_val " == *" $dep "* ]]; then
        warn "Dependency '${dep}' is already in ${target_key} for package '${pkg}'."
        return 0
    fi

    local new_val
    new_val="$(echo "$current_val $dep" | xargs)"
    write_manifest_key "$pkg" "$target_key" "$new_val"
    success "Added '${dep}' as ${target_key} entry for package '${pkg}'."
}

cmd_deps_remove() {
    local pkg="$1"
    local dep="$2"

    if [[ -z "$pkg" || -z "$dep" ]]; then
        error "Usage: $0 deps:remove <package> <dependency_name>"
        return 1
    fi

    local req_val
    local opt_val
    local cnf_val
    req_val="$(read_manifest_key "$pkg" "REQUIRED")"
    opt_val="$(read_manifest_key "$pkg" "OPTIONAL")"
    cnf_val="$(read_manifest_key "$pkg" "CONFLICTS")"

    local new_req
    local new_opt
    local new_cnf
    new_req="$(echo "$req_val" | tr ' ' '\n' | grep -v "^${dep}$" | tr '\n' ' ' | xargs 2>/dev/null || true)"
    new_opt="$(echo "$opt_val" | tr ' ' '\n' | grep -v "^${dep}$" | tr '\n' ' ' | xargs 2>/dev/null || true)"
    new_cnf="$(echo "$cnf_val" | tr ' ' '\n' | grep -v "^${dep}$" | tr '\n' ' ' | xargs 2>/dev/null || true)"

    write_manifest_key "$pkg" "REQUIRED" "$new_req"
    write_manifest_key "$pkg" "OPTIONAL" "$new_opt"
    write_manifest_key "$pkg" "CONFLICTS" "$new_cnf"
    success "Removed '${dep}' from package '${pkg}'."
}

cmd_deps_show() {
    local pkg="$1"
    if [[ -z "$pkg" ]]; then
        error "Usage: $0 deps:show <package>"
        return 1
    fi

    local manifest="$DOTFILES_DIR/$pkg/.stowdeps"
    if [[ ! -f "$manifest" ]]; then
        warn "Package '${pkg}' does not have a '.stowdeps' manifest file."
        return 1
    fi

    echo -e "\n${CYAN}${BOLD}=== Manifest [.stowdeps] for '${pkg}' ===${NC}\n"
    cat "$manifest"
    echo ""
}

cmd_make_package() {
    local pkg="$1"

    if [[ -z "$pkg" ]]; then
        error "Usage: $0 make:package <package_name>"
        return 1
    fi

    local pkg_dir="$DOTFILES_DIR/$pkg"
    if [[ -d "$pkg_dir" ]]; then
        warn "Package directory '${pkg_dir}' already exists."
    else
        mkdir -p "$pkg_dir"
        success "Created package directory: ${pkg_dir}"
    fi

    local manifest="$pkg_dir/.stowdeps"
    if [[ ! -f "$manifest" ]]; then
        cat <<EOF > "$manifest"
# Package Dependency Manifest for '${pkg}'
REQUIRED=""
OPTIONAL=""
CONFLICTS=""
EOF
        success "Created manifest file: ${manifest}"
    fi
}

cmd_registry_add() {
    local tool="$1"
    local aliases="$2"
    local distro_mapping="$3"

    if [[ -z "$tool" || -z "$aliases" ]]; then
        error "Usage: $0 registry:add <tool_name> <binary_aliases> [distro:package_name]"
        return 1
    fi

    echo "${tool} = ${aliases}" >> "$REGISTRY_FILE"
    if [[ -n "$distro_mapping" ]]; then
        local distro="${distro_mapping%%:*}"
        local pkg_name="${distro_mapping#*:}"
        echo "${tool}@${distro} = ${pkg_name}" >> "$REGISTRY_FILE"
    fi
    success "Added '${tool}' mapping to '${REGISTRY_FILE}'"
}
