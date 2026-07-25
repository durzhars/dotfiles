#!/usr/bin/env bash
# shellcheck shell=bash
# =============================================================================
# Stow Manager Module: Core Stow Engine & Conflict Resolver
# =============================================================================

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
    local conflicts
    conflicts="$(read_manifest_key "$target_pkg" "CONFLICTS")"

    if [[ -n "$conflicts" ]]; then
        for conflicting_pkg in $conflicts; do
            if is_package_stowed "$conflicting_pkg"; then
                warn "Package '${target_pkg}' conflicts with currently stowed package '${conflicting_pkg}'."
                info "Auto-unstowing conflicting package '${conflicting_pkg}' first..."
                unstow_package "$conflicting_pkg"
            fi
        done
    fi
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

cmd_stow_all() {
    local packages_to_stow=""

    if [[ -f "$PROFILE_FILE" ]]; then
        while IFS='=' read -r k v || [[ -n "$k" ]]; do
            k="$(echo "$k" | xargs 2>/dev/null || true)"
            if [[ "$k" == "DEFAULT_PACKAGES" ]]; then
                v="${v#\"}"
                v="${v%\"}"
                packages_to_stow="$v"
                break
            fi
        done < "$PROFILE_FILE"
    fi

    if [[ -z "$packages_to_stow" ]]; then
        packages_to_stow="$(get_all_packages)"
    fi

    info "Stowing default profile packages: ${packages_to_stow}"
    for pkg in $packages_to_stow; do
        if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
            stow_package "$pkg"
        fi
    done
}
