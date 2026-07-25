#!/usr/bin/env bash
# shellcheck shell=bash
# =============================================================================
# Stow Manager Module: Registry & Distro Package Mapping
# =============================================================================

# Resolves binary executables/plugins for a given tool name from stow.registry
get_binary_aliases() {
    local tool="$1"
    local aliases=("$tool")

    if [[ -f "$REGISTRY_FILE" ]]; then
        while IFS='=' read -r key val || [[ -n "$key" ]]; do
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

# Helper: returns all tool names defined in stow.registry
get_all_registry_tools() {
    local tools=()
    if [[ -f "$REGISTRY_FILE" ]]; then
        while IFS='=' read -r key val || [[ -n "$key" ]]; do
            key="$(echo "$key" | xargs 2>/dev/null || true)"
            if [[ -n "$key" && ! "$key" =~ ^# && "$key" != *"@"* ]]; then
                tools+=("$key")
            fi
        done < "$REGISTRY_FILE"
    fi
    echo "${tools[*]}"
}

# Check if a tool or plugin is installed on the host system (data-driven via stow.registry)
is_tool_installed() {
    local tool="$1"
    read -r -a aliases <<< "$(get_binary_aliases "$tool")"

    for entry in "${aliases[@]}"; do
        if [[ "$entry" == plugin:* ]]; then
            local plugin_path="${entry#plugin:}"
            if [[ -r "$plugin_path" ]]; then
                return 0
            fi
        else
            if command -v "$entry" >/dev/null 2>&1; then
                return 0
            fi
        fi
    done

    return 1
}
