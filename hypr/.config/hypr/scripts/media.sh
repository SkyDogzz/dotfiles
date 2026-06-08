#!/usr/bin/env bash
set -euo pipefail

json() {
  jq -cn --arg text "$1" --arg tooltip "$2" --arg class "$3" \
    '{text:$text, tooltip:$tooltip, class:$class}'
}

current_player() {
  local player

  player="$(playerctl -l 2>/dev/null | awk '$0 != "playerctld" { print; exit }')"
  if [[ -z "$player" ]]; then
    player="$(playerctl -l 2>/dev/null | head -n1)"
  fi

  printf '%s\n' "$player"
}

status() {
  local player player_status title artist icon text tooltip class

  if ! command -v playerctl >/dev/null 2>&1; then
    json "󰝛" "playerctl is not installed" "idle"
    return
  fi

  player="$(current_player)"
  if [[ -z "$player" ]]; then
    json "󰝛" "No active media player" "idle"
    return
  fi

  player_status="$(playerctl -p "$player" status 2>/dev/null || true)"
  title="$(playerctl -p "$player" metadata --format '{{title}}' 2>/dev/null || true)"
  artist="$(playerctl -p "$player" metadata --format '{{artist}}' 2>/dev/null || true)"

  case "$player_status" in
    Playing)
      icon="󰏤"
      class="playing"
      ;;
    Paused)
      icon="󰐊"
      class="paused"
      ;;
    Stopped)
      icon="󰐊"
      class="paused"
      ;;
    *)
      icon="󰝛"
      class="idle"
      ;;
  esac

  if [[ -z "$title" ]]; then
    title="Unknown track"
  fi

  if [[ -n "$artist" ]]; then
    text="$icon $artist - $title"
  else
    text="$icon $title"
  fi

  tooltip="$player_status\n$artist\n$title"
  json "$text" "$tooltip" "$class"
}

control() {
  local action="$1" player

  if ! command -v playerctl >/dev/null 2>&1; then
    return 0
  fi

  player="$(current_player)"
  if [[ -z "$player" ]]; then
    return 0
  fi

  playerctl -p "$player" "$action"
  pkill -SIGRTMIN+11 waybar 2>/dev/null || true
}

action="${1:-status}"
case "$action" in
  status) status ;;
  play-pause|next|previous) control "$action" ;;
  *) printf 'usage: %s {status|play-pause|next|previous}\n' "${0##*/}" >&2; exit 1 ;;
esac
