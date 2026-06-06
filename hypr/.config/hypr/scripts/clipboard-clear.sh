#!/usr/bin/env bash
set -euo pipefail

action="${1:-clear}"

case "$action" in
  clear)
    wl-copy ""
    notify-send -a "Hyprland" "Clipboard" "Cleared"
    ;;
  wipe)
    wl-copy ""
    cliphist wipe
    notify-send -a "Hyprland" "Clipboard" "Cleared + history wiped"
    ;;
  *)
    printf 'usage: %s {clear|wipe}\n' "${0##*/}" >&2
    exit 1
    ;;
esac
