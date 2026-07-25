#!/usr/bin/env bash
# shellcheck shell=bash
# =============================================================================
# Stow Manager Module: Manifest [.stowdeps] Parser & Mutator
# =============================================================================

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

# Writes/updates a key in a package's `.stowdeps` manifest file
write_manifest_key() {
    local pkg="$1"
    local key="$2"
    local new_val="$3"
    local manifest="$DOTFILES_DIR/$pkg/.stowdeps"

    mkdir -p "$DOTFILES_DIR/$pkg"

    if [[ ! -f "$manifest" ]]; then
        cat <<EOF > "$manifest"
# Package Dependency Manifest for '$pkg'
REQUIRED=""
OPTIONAL=""
CONFLICTS=""
EOF
    fi

    if grep -q "^${key}=" "$manifest" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=\"${new_val}\"|" "$manifest"
    else
        echo "${key}=\"${new_val}\"" >> "$manifest"
    fi
}
