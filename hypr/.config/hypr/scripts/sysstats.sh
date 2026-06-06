#!/usr/bin/env bash
set -euo pipefail

dgpu_busy="/sys/class/drm/card2/device/gpu_busy_percent"
dgpu_temp="/sys/class/drm/card2/device/hwmon/hwmon5/temp1_input"
igpu_temp_sensors="amdgpu-pci-0300"

get_cpu() {
  local line idle total idle2 total2 usage
  read -r line < /proc/stat
  set -- $line; shift
  idle=$4
  total=$(awk '{for(i=1;i<=NF;i++) s+=$i} END {print s}' <<< "$*")
  sleep 0.1
  read -r line < /proc/stat
  set -- $line; shift
  idle2=$4
  total2=$(awk '{for(i=1;i<=NF;i++) s+=$i} END {print s}' <<< "$*")
  echo $(( 100 * (total2 - total - (idle2 - idle)) / (total2 - total) ))
}

get_ram() {
  local total available
  total=$(awk '/MemTotal/{print $2}' /proc/meminfo)
  available=$(awk '/MemAvailable/{print $2}' /proc/meminfo)
  echo $(( (total - available) * 100 / total ))
}

get_gpu_stats() {
  local dgpu_pct dgpu_temp_c igpu_temp_c
  dgpu_pct=$(cat "$dgpu_busy" 2>/dev/null || echo 0)
  dgpu_temp_c=$(( $(cat "$dgpu_temp" 2>/dev/null || echo 0) / 1000 ))

  igpu_temp_c=""
  if output=$(sensors -u "$igpu_temp_sensors" 2>/dev/null); then
    local val
    val=$(awk '/temp1_input/{print $2}' <<< "$output" 2>/dev/null || true)
    if [[ -n "$val" ]]; then
      igpu_temp_c=$(printf '%.0f' "$val")
    fi
  fi

  echo "$dgpu_pct $dgpu_temp_c ${igpu_temp_c:-}"
}

cpu=$(get_cpu)
ram=$(get_ram)
read -r dgpu_pct dgpu_temp igpu_temp <<< "$(get_gpu_stats)"

text="${cpu}%  ${ram}% 󰾲 ${dgpu_pct}%"
tooltip="CPU ${cpu}%  RAM ${ram}%  dGPU ${dgpu_pct}% ${dgpu_temp}°C"
if [[ -n "${igpu_temp:-}" ]]; then
  tooltip+="  iGPU ${igpu_temp}°C"
fi

case "${1:-status}" in
  status) printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip" ;;
  *) printf 'usage: %s {status}\n' "${0##*/}" >&2; exit 1 ;;
esac
