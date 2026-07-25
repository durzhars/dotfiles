#!/usr/bin/env bash
set -euo pipefail

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
css_chrome="$config_dir/noctalia/zen-browser/zen-userChrome.css"
css_content="$config_dir/noctalia/zen-browser/zen-userContent.css"

find "${XDG_CONFIG_HOME:-$HOME/.config}/zen" "$HOME/.zen" -mindepth 2 -maxdepth 2 -type d -name chrome -print0 2>/dev/null \
  | while IFS= read -r -d '' dir; do
    user_chrome="$dir/userChrome.css"
    user_content="$dir/userContent.css"

    mkdir -p "$dir"

    if [ -f "$css_chrome" ]; then
      cat "$css_chrome" >"$user_chrome"
    fi

    if [ -f "$css_content" ]; then
      cat "$css_content" >"$user_content"
    fi
  done
