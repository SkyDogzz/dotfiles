#!/usr/bin/env bash
set -euo pipefail

wallpaper_dir="$HOME/.config/hypr/wallpapers"
hyprpaper_conf="$HOME/.config/hypr/hyprpaper.conf"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr"
state_file="$cache_dir/current_wallpaper"

get_wallpapers() {
  find "$wallpaper_dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort
}

get_current() {
  if [[ -f "$state_file" ]]; then
    cat "$state_file"
  else
    get_wallpapers | head -1
  fi
}

set_wallpaper() {
  local path="$1"
  mkdir -p "$cache_dir"
  printf '%s' "$path" > "$state_file"

  cat > "$hyprpaper_conf" <<EOF
preload = $path
wallpaper = ,$path
splash = false
EOF

  if ! pgrep -x hyprpaper >/dev/null 2>&1; then
    hyprpaper -c "$hyprpaper_conf" &
    disown
  fi

  for _ in {1..20}; do
    failed=false
    while IFS= read -r monitor; do
      if ! hyprctl hyprpaper reload "$monitor,$path" >/dev/null 2>&1; then
        failed=true
      fi
    done < <(hyprctl monitors -j | jq -r '.[].name')
    if ! $failed; then
      break
    fi
    sleep 0.25
  done

  local name
  name="$(basename "$path")"
  notify-send -a "Hyprland" "Wallpaper" "$name"
}

action="${1:-}"

case "$action" in
  next)
    mapfile -t wallpapers < <(get_wallpapers)
    current="$(get_current)"
    next=""
    for i in "${!wallpapers[@]}"; do
      if [[ "${wallpapers[$i]}" == "$current" ]]; then
        next="${wallpapers[$(( (i + 1) % ${#wallpapers[@]} ))]}"
        break
      fi
    done
    if [[ -z "$next" ]]; then
      next="${wallpapers[0]}"
    fi
    set_wallpaper "$next"
    ;;
  prev)
    mapfile -t wallpapers < <(get_wallpapers)
    current="$(get_current)"
    prev=""
    for i in "${!wallpapers[@]}"; do
      if [[ "${wallpapers[$i]}" == "$current" ]]; then
        prev="${wallpapers[$(( (i - 1 + ${#wallpapers[@]}) % ${#wallpapers[@]} ))]}"
        break
      fi
    done
    if [[ -z "$prev" ]]; then
      prev="${wallpapers[-1]}"
    fi
    set_wallpaper "$prev"
    ;;
  *)
    printf 'usage: %s {next|prev}\n' "${0##*/}" >&2
    exit 1
    ;;
esac
