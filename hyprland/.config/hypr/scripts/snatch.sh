#!/bin/bash

# Define where the bloated plugin stores its assets and where we want them to live natively
PLUGIN_DIR="$HOME/.config/noctalia/plugins/hyprland-visual-editor/assets/animations"
TARGET_DIR="$HOME/.config/hypr/animations"

# Create our clean directory
mkdir -p "$TARGET_DIR"

# Ensure the plugin directory actually exists
if [ ! -d "$PLUGIN_DIR" ]; then
  echo "Error: HVE Plugin directory not found. Did you uninstall it already?"
  exit 1
fi

# Loop through every preset, strip the metadata, and save it
for file in "$PLUGIN_DIR"/*.conf; do
  filename=$(basename "$file")

  # sed '/^# @/d' means "find lines starting with '# @' and Delete them"
  sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$file" >"$TARGET_DIR/$filename"

  echo "Cleaned and extracted: $filename"
done

echo "Extraction complete! You can now safely delete the HVE plugin."
