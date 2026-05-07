#!/usr/bin/env bash

readarray -t ADDRESSES < <(hyprctl clients -j | jq -r '[.[] | select(.mapped == true)] | reverse | .[].address')

window_addr() {
  hyprctl clients -j | jq -e --arg address "$1" '.[] | select(.address == $address)' >/dev/null
}

for address in "${ADDRESSES[@]}"; do

  if ! window_addr "$address"; then
    continue
  fi

  hyprctl dispatch focuswindow address:"$address"
  hyprctl dispatch closewindow address:"$address"
  CLOSED=false

  for i in {1..10}; do
    if ! window_addr "$address"; then
      CLOSED=true
      break
    fi
    sleep 0.5
  done

  if [[ "$CLOSED" == false ]]; then
    notify-send -u critical "Logout" 'Logout Cancelled!'
    exit 0
  fi
done
exit 0
