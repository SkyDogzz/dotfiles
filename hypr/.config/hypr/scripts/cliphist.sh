#!/usr/bin/env bash
set -euo pipefail

history="$(cliphist list | rofi -dmenu -i -p Clipboard)"

if [[ -n "${history:-}" ]]; then
  printf '%s' "$history" | cliphist decode | wl-copy
fi
