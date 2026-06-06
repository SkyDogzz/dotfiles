#!/usr/bin/env bash
set -euo pipefail

entries=(
  "  Lock"
  "󰍃  Logout"
  "󰒲  Suspend"
  "  Reboot"
  "⏻  Shutdown"
)

chosen=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -p "Power" -theme ~/.config/rofi/config.rasi)

case "$chosen" in
  "  Lock")    hyprlock ;;
  "󰍃  Logout")  hyprctl dispatch exit ;;
  "󰒲  Suspend") systemctl suspend ;;
  "  Reboot")  systemctl reboot ;;
  "⏻  Shutdown") systemctl poweroff ;;
esac
