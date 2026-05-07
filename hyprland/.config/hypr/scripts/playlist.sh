#!/usr/bin/env bash

PLAYLIST=$(realpath "$1")
SOCKET="/tmp/mpv-music-daemon.sock"

if [[ -z "$PLAYLIST" || ! -f "$PLAYLIST" ]]; then
  notify-send "Music Daemon" "Error: Playlist not found"
  exit 1
fi

if socat - UNIX-CONNECT:"$SOCKET" <<<'{"command": ["get_property", "mpv-version"]}' >/dev/null 2>&1; then
  socat - UNIX-CONNECT:"$SOCKET" <<<"{\"command\": [\"loadlist\", \"$PLAYLIST\", \"replace\"]}"
  socat - UNIX-CONNECT:"$SOCKET" <<<'{"command": ["set_property", "playlist-pos", 0]}'
  socat - UNIX-CONNECT:"$SOCKET" <<<'{"command": ["set_property", "pause", false]}'
  notify-send "Music Daemon" "Switched playlist: $(basename "$PLAYLIST")"
else
  rm -f "$SOCKET"
  notify-send "Music Daemon" "Starting new session: $(basename "$PLAYLIST")"
  mpv --no-video --idle=yes --input-ipc-server="$SOCKET" "$PLAYLIST" &
fi
