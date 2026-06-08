#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"
sink='@DEFAULT_AUDIO_SINK@'
source='@DEFAULT_AUDIO_SOURCE@'

notify_volume() {
  local info volume percent muted
  info="$(wpctl get-volume "$sink")"
  volume="$(awk '{print $2}' <<<"$info")"
  percent="$(awk -v v="$volume" 'BEGIN { printf "%.0f", v * 100 }')"
  if grep -q 'MUTED' <<<"$info"; then
    muted=" (muted)"
  else
    muted=""
  fi
  notify-send -a "Hyprland" "Volume" "${percent}%${muted}"
}

notify_mic() {
  local info volume percent muted
  info="$(wpctl get-volume "$source")"
  volume="$(awk '{print $2}' <<<"$info")"
  percent="$(awk -v v="$volume" 'BEGIN { printf "%.0f", v * 100 }')"
  if grep -q 'MUTED' <<<"$info"; then
    muted=" (muted)"
  else
    muted=""
  fi
  notify-send -a "Hyprland" "Microphone" "${percent}%${muted}"
}

case "$action" in
  up)
    wpctl set-volume "$sink" 5%+ --limit 1.0
    notify_volume
    ;;
  down)
    wpctl set-volume "$sink" 5%-
    notify_volume
    ;;
  mute)
    wpctl set-mute "$sink" toggle
    notify_volume
    ;;
  mic-mute)
    wpctl set-mute "$source" toggle
    notify_mic
    ;;
  *)
    printf 'usage: %s {up|down|mute|mic-mute}\n' "${0##*/}" >&2
    exit 1
    ;;
esac
