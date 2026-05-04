#!/bin/bash
coords=$(slurp)
icon="/usr/share/icons/breeze-dark/devices/24/camera-photo.svg"

if [ -z "$coords" ]; then
  exit 0
fi

sleep 0.2

filename="$HOME/Pictures/Screenshots/$(date +'%y%m%d_%H%M%S').png"
grim -g "$coords" "$filename"

wl-copy <"$filename"
notify-send "Image Saved" "Screenshot Copied to Clipboard" -a "Screenshot Tool" -i $icon
