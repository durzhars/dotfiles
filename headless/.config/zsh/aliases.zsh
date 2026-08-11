# Headless Zsh Aliases

# Dynamic ls / eza / exa
if (($+commands[eza])); then
    alias ls='eza --icons=always --color=always --group-directories-first'
    alias ll='eza -lh --icons=always --color=always --group-directories-first --git'
    alias la='eza -lha --icons=always --color=always --group-directories-first --git'
    alias lsa='eza -a --icons=always --color=always --group-directories-first'
    alias tree='eza --tree --icons=always'
elif (($+commands[exa])); then
    alias ls='exa --icons=always --color=always --group-directories-first'
    alias ll='exa -lh --icons=always --color=always --group-directories-first --git'
    alias la='exa -lha --icons=always --color=always --group-directories-first --git'
    alias lsa='exa -a --icons=always --color=always --group-directories-first'
    alias tree='exa --tree --icons=always'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF --color=auto'
    alias la='ls -A --color=auto'
    alias lsa='ls -A --color=auto'
fi

# Dynamic cat / bat / batcat
if (($+commands[bat])); then
    alias cat='bat'
elif (($+commands[batcat])); then
    alias cat='batcat'
fi

# Dynamic rg / grep
if (($+commands[rg])); then
    alias rg='rg --hidden --glob "!.git"'
else
    alias grep='grep --color=auto'
fi

# Dynamic fd / fdfind
if ! (($+commands[fd])) && (($+commands[fdfind])); then
    alias fd='fdfind'
fi

# Process monitors
if (($+commands[btop])); then
    alias top='btop'
elif (($+commands[htop])); then
    alias top='htop'
fi

# Safe file operations
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -I'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Headless / Server Helpers
alias ports='ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null || lsof -i'
alias myip='curl -s https://ifconfig.me || curl -s https://api.ipify.org'
alias reload='exec $SHELL -l'
alias meminfo='free -m -l -t 2>/dev/null || top -l 1 | head -n 10'
alias diskinfo='df -hT 2>/dev/null || df -h'

# Fetch missing Zsh plugins for environments without package manager plugin repos (e.g., Termux)
plugins-fetch() {
    local plugin_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"
    mkdir -p "$plugin_dir"

    local -A repos=(
        [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
        [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
        [zsh-history-substring-search]="https://github.com/zsh-users/zsh-history-substring-search.git"
        [zsh-completions]="https://github.com/zsh-users/zsh-completions.git"
        [fzf-tab]="https://github.com/Aloxaf/fzf-tab.git"
    )

    echo "Checking and fetching Zsh plugins into $plugin_dir..."
    for name repo in "${(@kv)repos}"; do
        if [[ ! -d "$plugin_dir/$name" ]]; then
            echo "Cloning $name..."
            git clone --depth 1 "$repo" "$plugin_dir/$name"
        else
            echo "Plugin '$name' is already installed."
        fi
    done

    local cache_file="${ZDOTDIR:-$HOME/.config/zsh}/cache/plugins_found.zsh"
    [[ -f "$cache_file" ]] && rm -f "$cache_file"
    echo "Done! Run 'reload' or restart Zsh to load plugins."
}

# Update all git-cloned Zsh plugins in ~/.config/zsh/plugins
plugins-update() {
    local plugin_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/plugins"
    if [[ ! -d "$plugin_dir" ]]; then
        echo "No custom plugin directory found at $plugin_dir."
        return 1
    fi

    echo "Updating Zsh plugins in $plugin_dir..."
    local updated=0
    for git_dir in "$plugin_dir"/*/.git(N/); do
        local p_name="${git_dir:h:t}"
        echo "Updating $p_name..."
        if git -C "${git_dir:h}" pull --ff-only; then
            updated=1
        fi
    done

    if ((updated)); then
        local cache_file="${ZDOTDIR:-$HOME/.config/zsh}/cache/plugins_found.zsh"
        [[ -f "$cache_file" ]] && rm -f "$cache_file"
        echo "Plugins updated! Run 'reload' or restart Zsh to refresh."
    else
        echo "No git-cloned plugins found to update."
    fi
}

alias plugins-pull='plugins-update'

# Fetch Popular Nerd Font TTF files into ~/.local/share/fonts
font-fetch() {
    local font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
    mkdir -p "$font_dir"

    local -A fonts=(
        [symbols]="patched-fonts/NerdFontsSymbolsOnly/SymbolsNerdFont-Regular.ttf|SymbolsNerdFont-Regular.ttf"
        [jetbrains]="patched-fonts/JetBrainsMono/Ligatures/JetBrainsMonoNerdFont-Regular.ttf|JetBrainsMonoNerdFont-Regular.ttf"
        [jetbrains-mono]="patched-fonts/JetBrainsMono/Ligatures/JetBrainsMonoNerdFontMono-Regular.ttf|JetBrainsMonoNerdFontMono-Regular.ttf"
        [firacode]="patched-fonts/FiraCode/FiraCodeNerdFont-Regular.ttf|FiraCodeNerdFont-Regular.ttf"
        [firacode-mono]="patched-fonts/FiraCode/FiraCodeNerdFontMono-Regular.ttf|FiraCodeNerdFontMono-Regular.ttf"
        [hack]="patched-fonts/Hack/HackNerdFont-Regular.ttf|HackNerdFont-Regular.ttf"
        [cascadia]="patched-fonts/CascadiaCode/CaskaydiaCoveNerdFont-Regular.ttf|CaskaydiaCoveNerdFont-Regular.ttf"
    )

    local target_font="${1:-all}"
    local base_url="https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master"

    if [[ "$target_font" != "all" && -z "${fonts[$target_font]}" ]]; then
        echo "Unknown font '$target_font'."
        echo "Usage: font-fetch [font_name]"
        echo "Available options: all, ${(j:, :)${(k)fonts}}"
        return 1
    fi

    local -a font_keys=()
    if [[ "$target_font" == "all" ]]; then
        font_keys=("${(@k)fonts}")
    else
        font_keys=("$target_font")
    fi

    echo "Downloading font(s) to $font_dir..."
    for key in "${font_keys[@]}"; do
        local val="${fonts[$key]}"
        local rel_path="${val%%|*}"
        local filename="${val##*|}"
        local target_file="$font_dir/$filename"
        local url="$base_url/$rel_path"

        if [[ -f "$target_file" ]]; then
            echo "✓ $filename is already downloaded."
            continue
        fi

        echo "Downloading $filename..."
        if command -v curl >/dev/null 2>&1; then
            curl -fLo "$target_file" --create-dirs "$url"
        elif command -v wget >/dev/null 2>&1; then
            wget -O "$target_file" "$url"
        fi
    done

    echo ""
    echo "Done! Font file(s) saved to: $font_dir"
    echo "You can copy/move font files where needed (e.g., cp '$font_dir/SymbolsNerdFont-Regular.ttf' ~/.termux/font.ttf)."
}




