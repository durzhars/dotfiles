#!/usr/bin/env bash

SAVE_DIR="$HOME/Pictures/Screenshots"
ICON="/usr/share/icons/breeze-dark/devices/24/camera-photo.svg"

mkdir -p "$SAVE_DIR"

coords=$(slurp) || exit 0

sleep 0.2

base_name="$(date +'%y%m%d_%H%M%S').png"
filename="$SAVE_DIR/$base_name"

if grim -g "$coords" "$filename"; then
  wl-copy -t image/png <"$filename"
  notify-send "Image Saved" "Screenshot $base_name Copied to Clipboard" \
    -a "Screenshot Tool" -i $ICON
else
  notify-send "Screenshot Failed" "Could not capture image." \
    -a "Screenshot Tool" -u critical
fi
