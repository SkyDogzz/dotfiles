#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"

gcd() {
  local a=$1 b=$2
  while (( b )); do
    local tmp=$b
    b=$(( a % b ))
    a=$tmp
  done
  echo "$a"
}

notify() {
  notify-send -a "Hyprland" "Zoom" "$1" 2>/dev/null || true
}

cursor=$(hyprctl cursorpos)
cx=${cursor%%,*}
cy=${cursor#*, }

monitor_list=$(hyprctl monitors -j | jq -c '.[]')

names=(); xs=(); ys=(); ws=(); hs=(); scales_n=(); rr=()
zoomed_idx=-1
idx=0

while IFS= read -r mon; do
  name=$(jq -r '.name'       <<< "$mon")
  x=$(   jq -r '.x'          <<< "$mon")
  y=$(   jq -r '.y'          <<< "$mon")
  w=$(   jq -r '.width'      <<< "$mon")
  h=$(   jq -r '.height'     <<< "$mon")
  scale=$(jq -r '.scale'     <<< "$mon")
  rate=$( jq -r '.refreshRate' <<< "$mon" | jq 'round')

  # n = the actual Hyprland scale denominator (scale = n/120)
  n=$(jq -n "$scale * 120 | round")
  # Reconstruct precise scale from n to avoid hyprctl truncation (1.33 vs 1.333...)
  precise=$(jq -n "$n / 120")
  lw=$(jq -n "$w / $precise | floor")
  lh=$(jq -n "$h / $precise | floor")

  names+=("$name")
  xs+=("$x"); ys+=("$y"); ws+=("$w"); hs+=("$h")
  scales_n+=("$n"); rr+=("$rate")

  if (( zoomed_idx < 0 && cx >= x && cx < x + lw && cy >= y && cy < y + lh )); then
    zoomed_idx=$idx
  fi
  idx=$((idx + 1))
done <<< "$monitor_list"

if (( zoomed_idx < 0 )); then
  notify "No monitor found for cursor"
  exit 1
fi

z_name=${names[zoomed_idx]}
z_w=${ws[zoomed_idx]}
z_h=${hs[zoomed_idx]}
z_x=${xs[zoomed_idx]}
z_y=${ys[zoomed_idx]}
z_n=${scales_n[zoomed_idx]}
z_scale=$(jq -n "$z_n / 120")

g=$(gcd "$z_w" "$z_h")
limit=$((120 * g))

declare -A defaults
defaults["eDP-2"]=1.3333333333

case "$action" in
  in)
    new_n=$z_n
    for ((n = z_n + 1; n <= 360; n++)); do
      if (( limit % n == 0 )); then
        new_n=$n
        break
      fi
    done
    if (( new_n == z_n )); then
      notify "$z_name: déjà au zoom max"
      exit 0
    fi
    ;;
  out)
    new_n=$z_n
    for ((n = z_n - 1; n >= 60; n--)); do
      if (( limit % n == 0 )); then
        new_n=$n
        break
      fi
    done
    if (( new_n == z_n )); then
      notify "$z_name: déjà au zoom min"
      exit 0
    fi
    ;;
  reset)
    default_scale="${defaults[$z_name]:-1}"
    new_n=$(jq -n "$default_scale * 120 | round")
    if (( new_n == z_n )); then
      exit 0
    fi
    ;;
  *)
    echo "usage: $0 {in|out|reset}"
    exit 1
    ;;
esac

new_scale=$(jq -n "$new_n / 120")

# Logical bounds from precise n values, not hyprctl truncated scale
z_lw=$(jq -n "$z_w / ($z_n / 120) | floor")
z_lh=$(jq -n "$z_h / ($z_n / 120) | floor")
new_lw=$(jq -n "$z_w / $new_scale | floor")
new_lh=$(jq -n "$z_h / $new_scale | floor")

dlw=$((new_lw - z_lw))
dlh=$((new_lh - z_lh))
old_right=$((z_x + z_lw))
old_bottom=$((z_y + z_lh))

move_others_first=false
if (( dlw > 0 || dlh > 0 )); then
  move_others_first=true
fi

shift_others() {
  for ((i = 0; i < ${#names[@]}; i++)); do
    if (( i == zoomed_idx )); then continue; fi
    new_x=${xs[i]}
    new_y=${ys[i]}
    if (( xs[i] >= old_right )); then
      new_x=$((xs[i] + dlw))
    fi
    if (( ys[i] >= old_bottom )); then
      new_y=$((ys[i] + dlh))
    fi
    if (( new_x != xs[i] || new_y != ys[i] )); then
      other_scale=$(jq -n "${scales_n[i]} / 120")
      hyprctl keyword monitor "${names[i]},${ws[i]}x${hs[i]}@${rr[i]},${new_x}x${new_y},$other_scale"
    fi
  done
}

if $move_others_first; then
  shift_others
  hyprctl keyword monitor "$z_name,${z_w}x${z_h}@${rr[zoomed_idx]},${z_x}x${z_y},$new_scale"
else
  hyprctl keyword monitor "$z_name,${z_w}x${z_h}@${rr[zoomed_idx]},${z_x}x${z_y},$new_scale"
  shift_others
fi

wallpaper_path=$(grep -oP 'preload\s*=\s*\K\S+' "$HOME/.config/hypr/hyprpaper.conf" | head -1) || true
if [[ -n "$wallpaper_path" ]]; then
  for name in "${names[@]}"; do
    hyprctl hyprpaper wallpaper "$name,$wallpaper_path,fill" 2>/dev/null || true
  done
fi

notify "$z_name: $z_scale → $new_scale"
