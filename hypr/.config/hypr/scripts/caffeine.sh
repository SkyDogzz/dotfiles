#!/usr/bin/env bash
set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr"
state_file="$cache_dir/caffeine"

usage() {
  printf 'usage: %s {toggle|on|off|status}\n' "${0##*/}" >&2
  exit 1
}

is_on() {
  [[ -f "$state_file" ]]
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

restore_brightness() {
  if have_cmd brightnessctl; then
    brightnessctl -r >/dev/null 2>&1 || true
  fi
}

turn_display_on() {
  if have_cmd hyprctl; then
    hyprctl dispatch dpms on >/dev/null 2>&1 || true
  fi
}

enable() {
  mkdir -p "$cache_dir"
  touch "$state_file"
  pkill hypridle 2>/dev/null || true
  turn_display_on
  restore_brightness
  notify-send -a "Hyprland" "Caffeine" "Enabled — idle and dimming disabled"
}

disable() {
  rm -f "$state_file"
  if ! pgrep -x hypridle >/dev/null 2>&1; then
    hypridle &
    disown
  fi
  notify-send -a "Hyprland" "Caffeine" "Disabled — idle restored"
}

toggle() {
  if is_on; then
    disable
  else
    enable
  fi
  pkill -SIGRTMIN+10 waybar 2>/dev/null || true
}

status() {
  if is_on; then
    printf '{"text":"☕","tooltip":"Caffeine: ON","class":"on"}\n'
  else
    printf '{"text":"☕","tooltip":"Caffeine: OFF","class":"off"}\n'
  fi
}

action="${1:-status}"
case "$action" in
  toggle|on|off) "$action" ;;
  status)        status ;;
  *)             usage ;;
esac
