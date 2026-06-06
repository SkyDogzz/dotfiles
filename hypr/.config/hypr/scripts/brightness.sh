#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"

notify_brightness() {
  local current max percent
  current="$(brightnessctl g)"
  max="$(brightnessctl m)"
  percent="$(awk -v c="$current" -v m="$max" 'BEGIN {
    if (m == 0) {
      print "0"
    } else {
      printf "%.0f", (c / m) * 100
    }
  }')"
  notify-send -a "Hyprland" "Brightness" "${percent}%"
}

case "$action" in
  up)
    brightnessctl set 5%+
    notify_brightness
    ;;
  down)
    brightnessctl set 5%-
    notify_brightness
    ;;
  *)
    printf 'usage: %s {up|down}\n' "${0##*/}" >&2
    exit 1
    ;;
esac
