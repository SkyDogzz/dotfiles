#!/usr/bin/env bash
set -euo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr/low-power"
enabled_file="$cache_dir/enabled"
profile_file="$cache_dir/profile"
monitors_file="$cache_dir/monitors.json"
brightness_file="$cache_dir/brightness"
cpu_state_file="$cache_dir/cpu-state.tsv"
cpu_boost_file="$cache_dir/cpu-boost"
gpu_state_file="$cache_dir/gpu-state.tsv"

usage() {
  printf 'usage: %s {toggle|on|off|status}\n' "${0##*/}" >&2
  exit 1
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

write_value() {
  local path="$1"
  local value="$2"

  if [[ -w "$path" ]]; then
    printf '%s' "$value" > "$path"
    return 0
  fi

  if have_cmd pkexec; then
    pkexec /bin/sh -c 'printf %s "$2" > "$1"' sh "$path" "$value" >/dev/null 2>&1 && return 0
  fi

  if have_cmd sudo; then
    sudo -n /bin/sh -c 'printf %s "$2" > "$1"' sh "$path" "$value" >/dev/null 2>&1 && return 0
  fi

  return 1
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

read_value() {
  cat "$1" 2>/dev/null || true
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

  save_cpu_state
  save_gpu_state
}

mark_enabled() {
  : > "$enabled_file"
}

clear_state() {
  rm -f "$enabled_file" "$profile_file" "$monitors_file" "$brightness_file" "$cpu_state_file" "$cpu_boost_file" "$gpu_state_file"
  rmdir "$cache_dir" 2>/dev/null || true
}

save_cpu_state() {
  local policy epp gov

  : > "$cpu_state_file"

  if [[ -e /sys/devices/system/cpu/cpufreq/boost ]]; then
    read_value /sys/devices/system/cpu/cpufreq/boost > "$cpu_boost_file"
  fi

  for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [[ -d "$policy" ]] || continue

    epp="$policy/energy_performance_preference"
    gov="$policy/scaling_governor"

    if [[ -e "$epp" ]]; then
      printf '%s\t%s\t%s\n' \
        "$epp" \
        "$(read_value "$epp")" \
        "$(read_value "$gov")" >> "$cpu_state_file"
    elif [[ -e "$gov" ]]; then
      printf '%s\t%s\t%s\n' \
        "$gov" \
        "$(read_value "$gov")" \
        "" >> "$cpu_state_file"
    fi
  done
}

save_gpu_state() {
  local device perf control vendor

  : > "$gpu_state_file"

  for device in /sys/class/drm/card*/device; do
    [[ -d "$device" ]] || continue
    vendor="$(read_value "$device/vendor")"
    [[ "$vendor" == "0x1002" ]] || continue

    perf="$device/power_dpm_force_performance_level"
    control="$device/power/control"

    if [[ -e "$perf" ]]; then
      printf '%s\t%s\t%s\n' \
        "$perf" \
        "$(read_value "$perf")" \
        "$(read_value "$control")" >> "$gpu_state_file"
    elif [[ -e "$control" ]]; then
      printf '%s\t%s\t%s\n' \
        "$control" \
        "$(read_value "$control")" \
        "" >> "$gpu_state_file"
    fi
  done
}

set_power_profile() {
  local profile="$1"

  if have_cmd powerprofilesctl; then
    powerprofilesctl set "$profile" >/dev/null 2>&1
    return $?
  fi

  return 1
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

apply_cpu_low_power() {
  local policy epp gov

  if [[ -e /sys/devices/system/cpu/cpufreq/boost ]]; then
    write_value /sys/devices/system/cpu/cpufreq/boost 0 || true
  fi

  for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    [[ -d "$policy" ]] || continue

    epp="$policy/energy_performance_preference"
    gov="$policy/scaling_governor"

    if [[ -e "$epp" ]]; then
      write_value "$epp" power || true
    fi

    if [[ -e "$gov" ]] && grep -q '\bpowersave\b' "$policy/scaling_available_governors" 2>/dev/null; then
      write_value "$gov" powersave || true
    fi
  done
}

apply_gpu_low_power() {
  local device perf control vendor

  for device in /sys/class/drm/card*/device; do
    [[ -d "$device" ]] || continue
    vendor="$(read_value "$device/vendor")"
    [[ "$vendor" == "0x1002" ]] || continue

    perf="$device/power_dpm_force_performance_level"
    control="$device/power/control"

    if [[ -e "$perf" ]]; then
      write_value "$perf" low || true
    fi

    if [[ -e "$control" ]]; then
      write_value "$control" auto || true
    fi
  done
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

restore_cpu_state() {
  local path value gov

  if [[ -e /sys/devices/system/cpu/cpufreq/boost && -f "$cpu_boost_file" ]]; then
    write_value /sys/devices/system/cpu/cpufreq/boost "$(read_value "$cpu_boost_file")" || true
  fi

  if [[ ! -f "$cpu_state_file" ]]; then
    return
  fi

  while IFS=$'\t' read -r path value gov; do
    [[ -n "$path" ]] || continue
    [[ -e "$path" ]] || continue
    write_value "$path" "$value" || true
    if [[ -n "$gov" && "$path" == *"/energy_performance_preference" ]]; then
      local gov_path="${path%/energy_performance_preference}/scaling_governor"
      [[ -e "$gov_path" ]] && write_value "$gov_path" "$gov" || true
    fi
  done < "$cpu_state_file"
}

restore_gpu_state() {
  local path value control

  if [[ ! -f "$gpu_state_file" ]]; then
    return
  fi

  while IFS=$'\t' read -r path value control; do
    [[ -n "$path" ]] || continue
    [[ -e "$path" ]] || continue
    write_value "$path" "$value" || true
    if [[ -n "$control" && "$path" == *"/power_dpm_force_performance_level" ]]; then
      local control_path="${path%/power_dpm_force_performance_level}/power/control"
      [[ -e "$control_path" ]] && write_value "$control_path" "$control" || true
    fi
  done < "$gpu_state_file"
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

  mark_enabled
  apply_cpu_low_power
  apply_gpu_low_power
  apply_monitor_refresh "$monitors_file" "60"
  apply_brightness_cap
  notify_mode "Enabled: power-saver profile, 60 Hz display refresh, and brightness cap"
  waybar_signal
}

disable() {
  if ! is_enabled; then
    return
  fi

  if [[ -f "$profile_file" ]]; then
    set_power_profile "$(cat "$profile_file")"
  fi

  restore_cpu_state
  restore_gpu_state
  restore_monitor_refresh
  restore_brightness

  clear_state

  notify_mode "Disabled: restored previous power profile, display refresh, and brightness"
  waybar_signal
}

status() {
  local profile text tooltip class

  profile="$(current_profile)"

  if is_enabled; then
    text="LP"
    class="on"
    printf -v tooltip 'Low Power Mode: ON\nPower profile: %s\nDisplay refresh: 60 Hz\nClick to restore the previous state' "$profile"
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
