#!/usr/bin/env bash
# shellcheck shell=bash
# =============================================================================
# Stow Manager Module: Registry & Distro Package Mapping
# =============================================================================

# Resolves binary executables for a given tool name from stow.registry or defaults
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
