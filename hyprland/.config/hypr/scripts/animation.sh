#!/bin/bash

ANIM_DIR="$HOME/.config/hypr/animations"
SYMLINK="$HOME/.config/hypr/animations.conf"

if [ -z "$1" ]; then
  echo "Usage: $0 <preset_name>"
  echo "Available presets:"
  ls -1 "$ANIM_DIR" | sed 's/\.conf$//'
  exit 1
fi

TARGET_FILE="$ANIM_DIR/$1.conf"

if [ ! -f "$TARGET_FILE" ]; then
  echo "Error: Animation preset '$1' does not exist."
  exit 1
fi

ln -sf "$TARGET_FILE" "$SYMLINK"

hyprctl reload

notify-send -a "Hyprland Theme" -i preferences-desktop-theme "Animation Switched" "Loaded: $1"
