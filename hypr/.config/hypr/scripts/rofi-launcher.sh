#!/usr/bin/env bash
set -euo pipefail

modes="run,clipboard:$HOME/.config/rofi/modes/clipboard.sh,wallpaper:$HOME/.config/rofi/modes/wallpaper.sh"
default="${1:-run}"

rofi -show "$default" -modi "$modes" -sidebar-mode
