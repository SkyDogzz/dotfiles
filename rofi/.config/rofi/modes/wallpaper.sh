#!/usr/bin/env bash
set -euo pipefail

wallpaper_dir="$HOME/.config/hypr/wallpapers"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr"
state_file="$cache_dir/current_wallpaper"
hyprpaper_conf="$HOME/.config/hypr/hyprpaper.conf"

list() {
    find "$wallpaper_dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort | while read -r f; do
        basename "$f"
    done
}

ensure_hyprpaper() {
    if pgrep -x hyprpaper >/dev/null 2>&1; then
        return 0
    fi

    hyprpaper -c "$hyprpaper_conf" &
    disown

    for _ in {1..20}; do
        if pgrep -x hyprpaper >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.1
    done
}

set_wallpaper() {
    local name="$1"
    local path="$wallpaper_dir/$name"
    [[ -f "$path" ]] || exit 1

    mkdir -p "$cache_dir"
    printf '%s' "$path" > "$state_file"

    cat > "$hyprpaper_conf" <<EOF
preload = $path

wallpaper {
    monitor = ${MONITOR:-eDP-2}
    path = $path
    fit_mode = fill
}
EOF

    ensure_hyprpaper

    for _ in {1..20}; do
        failed=false
        while IFS= read -r monitor; do
            if ! hyprctl hyprpaper wallpaper "$monitor,$path,fill" >/dev/null 2>&1; then
                failed=true
            fi
        done < <(hyprctl monitors -j | jq -r '.[].name')
        if ! $failed; then
            break
        fi
        sleep 0.1
    done

    notify-send -a "Hyprland" "Wallpaper" "$name"
}

if [[ $# -eq 0 ]]; then
    list
else
    set_wallpaper "$*"
fi
