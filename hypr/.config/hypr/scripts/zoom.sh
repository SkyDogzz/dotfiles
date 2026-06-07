#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"
min_scale=0.5
max_scale=3.0

gcd() {
  local a=$1 b=$2
  while (( b )); do
    local tmp=$b
    b=$(( a % b ))
    a=$tmp
  done
  echo "$a"
}

cursor=$(hyprctl cursorpos)
cx=${cursor%%,*}
cy=${cursor#*, }

current_monitor=""
current_scale=""
monitor_json=""
while IFS= read -r mon; do
  name=$(jq -r '.name' <<< "$mon")
  x=$(jq -r '.x' <<< "$mon")
  y=$(jq -r '.y' <<< "$mon")
  w=$(jq -r '.width' <<< "$mon")
  h=$(jq -r '.height' <<< "$mon")
  scale=$(jq -r '.scale' <<< "$mon")

  logical_w=$(jq -n "$w / $scale | floor")
  logical_h=$(jq -n "$h / $scale | floor")
  if (( cx >= x && cx < x + logical_w && cy >= y && cy < y + logical_h )); then
    current_monitor="$name"
    current_scale="$scale"
    monitor_json="$mon"
    break
  fi
done < <(hyprctl monitors -j | jq -c '.[]')

if [[ -z "$current_monitor" ]]; then
  notify-send -a "Hyprland" "Zoom" "No monitor found for cursor"
  exit 1
fi

w=$(jq -r '.width' <<< "$monitor_json")
h=$(jq -r '.height' <<< "$monitor_json")
g=$(gcd "$w" "$h")
limit=$((120 * g))

declare -A defaults
defaults["eDP-2"]=1.3333333333

current_n=$(jq -n "$current_scale * 120 | round")

case "$action" in
  in)
    new_n=$current_n
    for ((n = current_n + 1; n <= 360; n++)); do
      if (( limit % n == 0 )); then
        new_n=$n
        break
      fi
    done
    if (( new_n == current_n )); then
      notify-send -a "Hyprland" "Zoom" "$current_monitor: déjà au zoom max"
      exit 0
    fi
    ;;
  out)
    new_n=$current_n
    for ((n = current_n - 1; n >= 60; n--)); do
      if (( limit % n == 0 )); then
        new_n=$n
        break
      fi
    done
    if (( new_n == current_n )); then
      notify-send -a "Hyprland" "Zoom" "$current_monitor: déjà au zoom min"
      exit 0
    fi
    ;;
  reset)
    default_scale="${defaults[$current_monitor]:-1}"
    new_n=$(jq -n "$default_scale * 120 | round")
    if (( new_n == current_n )); then
      exit 0
    fi
    ;;
  *)
    echo "usage: $0 {in|out|reset}"
    exit 1
    ;;
esac

new_scale=$(jq -n "$new_n / 120")

res=$(jq -r '"\(.width)x\(.height)@\(.refreshRate | round)"' <<< "$monitor_json")
pos=$(jq -r '"\(.x)x\(.y)"' <<< "$monitor_json")
hyprctl keyword monitor "$current_monitor,$res,$pos,$new_scale"

wallpaper_path=$(grep -oP 'preload\s*=\s*\K\S+' "$HOME/.config/hypr/hyprpaper.conf" | head -1)
if [[ -n "$wallpaper_path" ]]; then
  hyprctl hyprpaper wallpaper "$current_monitor,$wallpaper_path,fill"
fi

notify-send -a "Hyprland" "Zoom" "$current_monitor: $current_scale → $new_scale"
