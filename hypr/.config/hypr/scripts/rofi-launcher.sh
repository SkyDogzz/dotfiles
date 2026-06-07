#!/usr/bin/env bash
set -euo pipefail

run_mode="$HOME/.config/rofi/modes/run.sh"
clipboard_mode="$HOME/.config/rofi/modes/clipboard.sh"
wallpaper_mode="$HOME/.config/rofi/modes/wallpaper.sh"

case "${1:-run}" in
  run)       default=" Run"           ;;
  clipboard) default="󰅰 Clipboard"     ;;
  wallpaper) default="󰸉 Wallpaper"     ;;
  *)         default=" Run"           ;;
esac

rofi -show "$default" -modi " Run:$run_mode,󰅰 Clipboard:$clipboard_mode,󰸉 Wallpaper:$wallpaper_mode" -sidebar-mode
