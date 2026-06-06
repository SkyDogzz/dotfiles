#!/usr/bin/env bash
set -euo pipefail

screenshot_dir="${SCREENSHOT_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$screenshot_dir"

filename="Screenshot_$(date +%Y%m%d_%H%M%S).png"
filepath="$screenshot_dir/$filename"

notify() {
  local title="$1"
  local body="$2"
  dunstify -a "Screenshot" "$title" "$body"
}

capture_full() {
  grim "$filepath"
  wl-copy < "$filepath"
  notify "Fullscreen" "$filepath"
}

capture_window() {
  local geom
  geom=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
  if [[ -z "$geom" || "$geom" == "null,null nullxnull" ]]; then
    notify "Error" "Could not get active window geometry"
    exit 1
  fi
  grim -g "$geom" "$filepath"
  wl-copy < "$filepath"
  notify "Window" "$filepath"
}

capture_region() {
  local geom
  geom=$(slurp)
  if [[ -z "$geom" ]]; then
    exit 1
  fi
  grim -g "$geom" "$filepath"
  wl-copy < "$filepath"
  notify "Region" "$filepath"
}

capture_region_edit() {
  local geom
  geom=$(slurp)
  if [[ -z "$geom" ]]; then
    exit 1
  fi
  grim -g "$geom" "$filepath"
  wl-copy < "$filepath"
  swappy -f "$filepath" -o "$filepath"
  notify "Region (edited)" "$filepath"
}

action="${1:-}"

case "$action" in
  full|fullscreen|screen)
    capture_full
    ;;
  window|win|active)
    capture_window
    ;;
  region|area|select)
    capture_region
    ;;
  edit|region-edit)
    capture_region_edit
    ;;
  *)
    printf 'usage: %s {full|window|region|edit}\n' "${0##*/}" >&2
    exit 1
    ;;
esac
