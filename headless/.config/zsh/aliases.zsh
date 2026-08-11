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

    local -a requested=("$@")
    ((${#requested} == 0)) && requested=("${(@k)repos}")

    local -a targets=()
    for arg in "${requested[@]}"; do
        if [[ -n "${repos[$arg]}" ]]; then
            targets+=("$arg")
        else
            echo "Unknown plugin '$arg' (Skipping). Available: ${(j:, :)${(k)repos}}" >&2
        fi
    done

    targets=("${(u)targets[@]}")
    ((${#targets} == 0)) && return 1

    echo "Checking and fetching Zsh plugin(s) into $plugin_dir..."
    for name in "${targets[@]}"; do
        local repo="${repos[$name]}"
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

    local -a requested=("$@")
    ((${#requested} == 0)) && requested=("all")

    local -a font_keys=()
    for arg in "${requested[@]}"; do
        if [[ "$arg" == "all" ]]; then
            font_keys+=("${(@k)fonts}")
        elif [[ -n "${fonts[$arg]}" ]]; then
            font_keys+=("$arg")
        else
            echo "Unknown font '$arg' (Skipping). Available: all, ${(j:, :)${(k)fonts}}" >&2
        fi
    done

    font_keys=("${(u)font_keys[@]}")
    ((${#font_keys} == 0)) && return 1

    local base_url="https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master"

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

# Remove downloaded Nerd Font TTF file(s) from ~/.local/share/fonts
font-remove() {
    local font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
    local -a requested=("$@")

    if ((${#requested} == 0)); then
        echo "Usage: font-remove <font_name1> [font_name2...] | all"
        echo "Available options: all, symbols, jetbrains, jetbrains-mono, firacode, firacode-mono, hack, cascadia"
        return 1
    fi

    local -A font_files=(
        [symbols]="SymbolsNerdFont-Regular.ttf"
        [jetbrains]="JetBrainsMonoNerdFont-Regular.ttf"
        [jetbrains-mono]="JetBrainsMonoNerdFontMono-Regular.ttf"
        [firacode]="FiraCodeNerdFont-Regular.ttf"
        [firacode-mono]="FiraCodeNerdFontMono-Regular.ttf"
        [hack]="HackNerdFont-Regular.ttf"
        [cascadia]="CaskaydiaCoveNerdFont-Regular.ttf"
    )

    local -a font_keys=()
    for arg in "${requested[@]}"; do
        if [[ "$arg" == "all" ]]; then
            font_keys+=("${(@k)font_files}")
        elif [[ -n "${font_files[$arg]}" ]]; then
            font_keys+=("$arg")
        else
            echo "Unknown font '$arg' (Skipping). Available: all, ${(j:, :)${(k)font_files}}" >&2
        fi
    done

    font_keys=("${(u)font_keys[@]}")
    ((${#font_keys} == 0)) && return 1

    for key in "${font_keys[@]}"; do
        local file="${font_files[$key]}"
        if [[ -f "$font_dir/$file" ]]; then
            rm -f "$font_dir/$file"
            echo "Removed $file from $font_dir."
        else
            echo "Font $file was not found in $font_dir."
        fi
    done
}

# Zsh Shell Completions for Helper Functions
if (($+functions[compdef])); then
    _font_fetch_completion() {
        local -a fonts=(
            'all:All available Nerd Fonts'
            'symbols:Symbols Nerd Font (Icon glyphs only)'
            'jetbrains:JetBrains Mono Nerd Font'
            'jetbrains-mono:JetBrains Mono Nerd Font Mono (Fixed-width icons)'
            'firacode:Fira Code Nerd Font'
            'firacode-mono:Fira Code Nerd Font Mono (Fixed-width icons)'
            'hack:Hack Nerd Font'
            'cascadia:Caskaydia Cove / Cascadia Code Nerd Font'
        )
        _describe -t fonts 'Nerd Font' fonts
    }
    compdef _font_fetch_completion font-fetch font-remove

    _plugins_fetch_completion() {
        local -a plugins=(
            'zsh-autosuggestions:Fish-like fast autosuggestions'
            'zsh-syntax-highlighting:Fish-like syntax highlighting'
            'zsh-history-substring-search:Up/down arrow substring search'
            'zsh-completions:Additional zsh completion definitions'
            'fzf-tab:Fzf tab completion menu'
        )
        _describe -t plugins 'Zsh Plugin' plugins
    }
    compdef _plugins_fetch_completion plugins-fetch
fi







