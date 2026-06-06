#!/usr/bin/env bash
set -euo pipefail

get_status() {
  local iface ssid signal tooltip class text

  iface="$(iw dev | awk '/Interface/{print $2}' | head -1)"
  if [[ -z "$iface" ]]; then
    printf '{"text":"󰤭","tooltip":"No interface","class":"disconnected"}\n'
    return
  fi

  if iw dev "$iface" link 2>/dev/null | grep -q 'Not connected'; then
    printf '{"text":"󰤮","tooltip":"Disconnected","class":"disconnected"}\n'
    return
  fi

  ssid="$(iw dev "$iface" link | awk '/SSID/{print $2}')"
  signal="$(iw dev "$iface" link | awk '/signal/{print $2}' | sed 's/-//')"

  if [[ -z "$ssid" ]]; then
    printf '{"text":"󰤨","tooltip":"Connected","class":"connected"}\n'
    return
  fi

  if (( signal < 50 )); then
    text="󰤨"
  elif (( signal < 65 )); then
    text="󰤥"
  elif (( signal < 75 )); then
    text="󰤢"
  else
    text="󰤟"
  fi

  printf '{"text":"%s","tooltip":"%s (%s%%)","class":"connected"}\n' \
    "$text" "$ssid" "$(( 100 - signal ))"
}

action="${1:-status}"
case "$action" in
  status) get_status ;;
  toggle) iwgtk ;;
  *) printf 'usage: %s {status|toggle}\n' "${0##*/}" >&2; exit 1 ;;
esac
