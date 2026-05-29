#!/usr/bin/env bash

set -euo pipefail

# Parse the intended action (Default to 'logout' if nothing is passed)
ACTION="${1:-logout}"

# Validate the argument to prevent typos from hanging the system
if [[ ! "$ACTION" =~ ^(logout|reboot|shutdown)$ ]]; then
  notify-send -u critical "Session Manager" "Error: Invalid action '$ACTION'.\nUse: logout, reboot, or shutdown."
  exit 1
fi

# 2. Fetch all mapped window addresses
readarray -t ADDRESSES < <(hyprctl clients \
  | awk '/^Window/ { addr = $2 } /^[[:space:]]*mapped: 1/ { print "0x" addr }')

# If no windows are open, jump straight to the power action
if [[ ${#ADDRESSES[@]} -eq 0 ]]; then
  EXECUTE_POWER_ACTION=true
else
  # 3. Sequentially focus, close, and poll each window
  for addr in "${ADDRESSES[@]}"; do
    raw_addr="${addr#0x}"

    if ! hyprctl clients | grep -qi "^Window ${raw_addr}"; then
      continue
    fi

    hyprctl dispatch "hl.dsp.focus({ window = 'address:${addr}' })" >/dev/null
    hyprctl dispatch "hl.dsp.window.close({ window = 'address:${addr}' })" >/dev/null

    CLOSED=false

    for i in {1..10}; do
      if ! hyprctl clients | grep -qi "^Window ${raw_addr}"; then
        CLOSED=true
        break
      fi
      sleep 0.5
    done

    if [[ "$CLOSED" == false ]]; then
      notify-send -u critical "Session Manager" "Action cancelled. Application refused to close."
      exit 1
    fi
  done

  EXECUTE_POWER_ACTION=true
fi

# Execute the requested system state
if [[ "$EXECUTE_POWER_ACTION" == true ]]; then
  notify-send "Session Manager" "Apps closed safely. Executing: ${ACTION}..."
  sleep 0.5 # Give the notification a split second to render before teardown

  case "$ACTION" in
    shutdown)
      systemctl poweroff
      ;;
    reboot)
      systemctl reboot
      ;;
    logout)
      uwsm stop
      ;;
  esac
fi

exit 0
