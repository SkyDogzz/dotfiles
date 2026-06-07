#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"
step=0.25
min_scale=0.5
max_scale=3.0

declare -A defaults
defaults["eDP-2"]=1.3333333333

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

case "$action" in
  in)
    new_scale=$(jq -n "$current_scale + $step")
    new_scale=$(jq -n "if $new_scale > $max_scale then $max_scale else $new_scale end")
    ;;
  out)
    new_scale=$(jq -n "$current_scale - $step")
    new_scale=$(jq -n "if $new_scale < $min_scale then $min_scale else $new_scale end")
    ;;
  reset)
    new_scale="${defaults[$current_monitor]:-1}"
    ;;
  *)
    echo "usage: $0 {in|out|reset}"
    exit 1
    ;;
esac

res=$(jq -r '"\(.width)x\(.height)@\(.refreshRate | round)"' <<< "$monitor_json")
pos=$(jq -r '"\(.x)x\(.y)"' <<< "$monitor_json")
hyprctl keyword monitor "$current_monitor,$res,$pos,$new_scale"

wallpaper_path=$(grep -oP 'preload\s*=\s*\K\S+' "$HOME/.config/hypr/hyprpaper.conf" | head -1)
if [[ -n "$wallpaper_path" ]]; then
  hyprctl hyprpaper wallpaper "$current_monitor,$wallpaper_path,fill"
fi

notify-send -a "Hyprland" "Zoom" "$current_monitor: $current_scale → $new_scale"
