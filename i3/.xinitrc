#!/bin/sh
# =============================================================================
# ~/.xinitrc — X11 Session Startup for i3 Window Manager
# =============================================================================

# Load X resources if present
if [ -f "$HOME/.Xresources" ]; then
    xrdb -merge "$HOME/.Xresources"
fi

# Ensure D-Bus session bus is running
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && command -v dbus-launch >/dev/null 2>&1; then
    eval "$(dbus-launch --sh-syntax --exit-with-session)"
fi

# Set cursor theme and speed if xset is available
if command -v xset >/dev/null 2>&1; then
    xset r rate 300 50
    xset s off -dpms 2>/dev/null || true
fi

# Start i3
exec i3
