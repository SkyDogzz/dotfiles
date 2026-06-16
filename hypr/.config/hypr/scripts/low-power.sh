#!/usr/bin/env bash
set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr/low-power"
enabled_file="$cache_dir/enabled"
profile_file="$cache_dir/profile"
monitors_file="$cache_dir/monitors.json"
brightness_file="$cache_dir/brightness"

usage() {
  printf 'usage: %s {toggle|on|off|status}\n' "${0##*/}" >&2
  exit 1
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

json() {
  jq -cn --arg text "$1" --arg tooltip "$2" --arg class "$3" \
    '{text:$text, tooltip:$tooltip, class:$class}'
}

waybar_signal() {
  pkill -SIGRTMIN+12 waybar 2>/dev/null || true
}

notify_mode() {
  if have_cmd notify-send; then
    notify-send -a "Hyprland" "Low Power Mode" "$1"
  fi
}

current_profile() {
  if have_cmd powerprofilesctl; then
    powerprofilesctl get 2>/dev/null || printf 'unknown'
  else
    printf 'unknown'
  fi
}

reconcile_state() {
  local profile

  [[ -f "$enabled_file" ]] || return 0

  profile="$(current_profile)"
  if [[ "$profile" != "power-saver" && "$profile" != "unknown" ]]; then
    clear_state
  fi
}

current_brightness_percent() {
  local current max

  if ! have_cmd brightnessctl; then
    printf 'unknown'
    return
  fi

  current="$(brightnessctl g 2>/dev/null || printf '0')"
  max="$(brightnessctl m 2>/dev/null || printf '0')"

  awk -v c="$current" -v m="$max" 'BEGIN {
    if (m == 0) {
      print "0"
    } else {
      printf "%.0f", (c / m) * 100
    }
  }'
}

is_enabled() {
  reconcile_state
  [[ -f "$enabled_file" ]]
}

save_state() {
  mkdir -p "$cache_dir"
  current_profile > "$profile_file"

  if have_cmd brightnessctl; then
    current_brightness_percent > "$brightness_file"
  fi

  if have_cmd hyprctl; then
    hyprctl monitors -j > "$monitors_file"
  fi
}

mark_enabled() {
  : > "$enabled_file"
}

clear_state() {
  rm -f "$enabled_file" "$profile_file" "$monitors_file" "$brightness_file"
  rmdir "$cache_dir" 2>/dev/null || true
}

set_power_profile() {
  local profile="$1"

  if have_cmd powerprofilesctl; then
    powerprofilesctl set "$profile" >/dev/null 2>&1
    return $?
  fi

  return 1
}

fallback_profile() {
  local saved="${1:-}"

  if [[ -n "$saved" && "$saved" != "power-saver" ]]; then
    printf '%s\n' "$saved"
  else
    printf 'balanced\n'
  fi
}

apply_monitor_refresh() {
  local source_file="$1"
  local refresh="$2"

  if ! have_cmd hyprctl || ! have_cmd jq || [[ ! -f "$source_file" ]]; then
    return
  fi

  jq -r --arg refresh "$refresh" '
    .[]
    | select(.name and .width != null and .height != null and .x != null and .y != null and .scale != null)
    | [ .name, (.width|tostring), (.height|tostring), $refresh, (.x|tostring), (.y|tostring), (.scale|tostring) ]
    | @tsv
  ' "$source_file" | while IFS=$'\t' read -r name width height current_refresh x y scale; do
    [[ -n "$name" ]] || continue
    hyprctl keyword monitor "${name},${width}x${height}@${current_refresh},${x}x${y},${scale}" >/dev/null 2>&1 || true
  done
}

apply_brightness_cap() {
  local current

  if ! have_cmd brightnessctl; then
    return
  fi

  current="$(current_brightness_percent)"
  if [[ "$current" =~ ^[0-9]+$ ]] && (( current > 60 )); then
    brightnessctl set 60% >/dev/null 2>&1 || true
  fi
}

restore_brightness() {
  local current

  if ! have_cmd brightnessctl || [[ ! -f "$brightness_file" ]]; then
    return
  fi

  current="$(cat "$brightness_file")"
  if [[ "$current" =~ ^[0-9]+$ ]]; then
    brightnessctl set "${current}%" >/dev/null 2>&1 || true
  fi
}

restore_monitor_refresh() {
  if ! have_cmd hyprctl || ! have_cmd jq || [[ ! -f "$monitors_file" ]]; then
    return
  fi

  jq -r '
    .[]
    | select(.name and .width != null and .height != null and .refreshRate != null and .x != null and .y != null and .scale != null)
    | [ .name, (.width|tostring), (.height|tostring), (.refreshRate|tostring), (.x|tostring), (.y|tostring), (.scale|tostring) ]
    | @tsv
  ' "$monitors_file" | while IFS=$'\t' read -r name width height current_refresh x y scale; do
    [[ -n "$name" ]] || continue
    hyprctl keyword monitor "${name},${width}x${height}@${current_refresh},${x}x${y},${scale}" >/dev/null 2>&1 || true
  done
}

enable() {
  if is_enabled; then
    return
  fi

  save_state
  if ! set_power_profile power-saver; then
    clear_state
    notify_mode "Failed: power-profiles-daemon is unavailable"
    return 1
  fi

  apply_monitor_refresh "$monitors_file" "60"
  apply_brightness_cap
  mark_enabled
  notify_mode "Enabled: power-saver profile, 60 Hz display refresh, and brightness cap"
  waybar_signal
}

disable() {
  if ! is_enabled; then
    return
  fi

  local saved_profile target_profile

  if [[ -f "$profile_file" ]]; then
    saved_profile="$(cat "$profile_file")"
    target_profile="$(fallback_profile "$saved_profile")"
  else
    target_profile="balanced"
  fi

  if ! set_power_profile "$target_profile"; then
    notify_mode "Failed: could not switch power profile to ${target_profile}"
    return 1
  fi

  restore_monitor_refresh
  restore_brightness

  clear_state

  notify_mode "Disabled: restored previous power profile, display refresh, and brightness"
  waybar_signal
}

status() {
  local profile text tooltip class

  profile="$(current_profile)"
  reconcile_state

  if [[ -f "$enabled_file" && "$profile" == "power-saver" ]]; then
    text="LP"
    class="on"
    printf -v tooltip 'Low Power Mode: ON\nPower profile: %s\nDisplay refresh: 60 Hz\nClick to restore the previous state' "$profile"
  elif [[ -f "$enabled_file" ]]; then
    text="LP"
    class="stale"
    if [[ "$profile" == "unknown" ]]; then
      printf -v tooltip 'Low Power Mode cache is set, but powerprofilesctl is unreachable\nClick to clear the cached state'
    else
      printf -v tooltip 'Low Power Mode cache is set, but power profile is %s\nClick to clear the cached state' "$profile"
    fi
  else
    text="LP"
    class="off"
    printf -v tooltip 'Low Power Mode: OFF\nPower profile: %s\nClick to enable power-saver mode' "$profile"
  fi

  if ! have_cmd powerprofilesctl; then
    tooltip="${tooltip}"$'\npowerprofilesctl is not installed'
    class="missing"
  fi

  json "$text" "$tooltip" "$class"
}

action="${1:-status}"
case "$action" in
  toggle)
    if is_enabled; then
      disable
    else
      enable
    fi
    ;;
  on)
    enable
    ;;
  off)
    disable
    ;;
  status)
    status
    ;;
  *)
    usage
    ;;
esac
