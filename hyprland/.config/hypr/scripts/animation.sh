#!/bin/bash

ANIM_DIR="$HOME/.config/hypr/animations"
# The single file Hyprland will actually look at
SYMLINK="$HOME/.config/hypr/animations.conf"

# If no argument is provided, list the available presets
if [ -z "$1" ]; then
  echo "Usage: $0 <preset_name>"
  echo "Available presets:"
  # List files without the .conf extension
  ls -1 "$ANIM_DIR" | sed 's/\.conf$//'
  exit 1
fi

TARGET_FILE="$ANIM_DIR/$1.conf"

if [ ! -f "$TARGET_FILE" ]; then
  echo "Error: Animation preset '$1' does not exist."
  exit 1
fi

# Here is the JaKooLit magic: Force (-f) a Symbolic (-s) link to overwrite the old one
ln -sf "$TARGET_FILE" "$SYMLINK"

# Hyprland's file watcher doesn't always trigger when a symlink target changes,
# so we manually tell it to reload to apply the curves instantly.
hyprctl reload

# Let's reuse your notification daemon knowledge!
notify-send -a "Hyprland Theme" -i preferences-desktop-theme "Animation Switched" "Loaded: $1"
