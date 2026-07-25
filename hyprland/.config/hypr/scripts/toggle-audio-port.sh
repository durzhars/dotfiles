#!/usr/bin/env bash

# 1. Get the default sink name (very fast)
DEFAULT_SINK=$(pactl get-default-sink)

# 2. Use a single awk process. The 'exit' command ensures it stops
# reading the massive pactl output the moment it finds what it needs.
ACTIVE_PORT=$(pactl list sinks | awk -v sink="$DEFAULT_SINK" '
    $1 == "Name:" { is_target = ($2 == sink) }
    is_target && $1 == "Active" && $2 == "Port:" { print $3; exit }
')

if [ "$ACTIVE_PORT" = "analog-output-speaker" ]; then
  pactl set-sink-port @DEFAULT_SINK@ analog-output-headphones
  notify-send -t 1500 -a "Audio" "Switched to Headphones 🎧"
else
  pactl set-sink-port @DEFAULT_SINK@ analog-output-speaker
  notify-send -t 1500 -a "Audio" "Switched to Speakers 🔊"
fi
