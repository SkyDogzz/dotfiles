#!/usr/bin/env bash
set -euo pipefail

launch_detached() {
    nohup "$@" >/dev/null 2>&1 &
}

launch_in_kitty() {
    launch_detached kitty -e bash -lc "$*"
}

desktop_field() {
    local field="$1"
    local file="$2"
    grep -m1 "^${field}=" "$file" | sed "s/^${field}=//"
}

launch_desktop() {
    local desktop_id="$1"
    local desktop_file="$2"
    local terminal exec_line

    terminal="$(desktop_field Terminal "$desktop_file")"
    if [[ "$terminal" == true ]]; then
        exec_line="$(desktop_field Exec "$desktop_file")"
        exec_line="${exec_line//%[fFuUdDnNickvm]/}"
        launch_in_kitty "$exec_line"
    else
        launch_detached gtk-launch "${desktop_id%.desktop}"
    fi
}

if [ -n "${1:-}" ]; then
    # ROFI_INFO contains the .desktop filename set via \0info\x1f
    desktop="${ROFI_INFO:-$1}"
    if [[ "$desktop" == *.desktop ]]; then
        for dir in /usr/share/applications ~/.local/share/applications; do
            file="$dir/$desktop"
            if [ -f "$file" ]; then
                launch_desktop "$desktop" "$file"
                exit 0
            fi
        done
        exit 1
    fi
    launch_in_kitty "$*"
    exit 0
fi

for dir in /usr/share/applications ~/.local/share/applications; do
    [ -d "$dir" ] || continue
    for file in "$dir"/*.desktop; do
        [ -f "$file" ] || continue
        grep -q '^NoDisplay=true' "$file" && continue
        name=$(grep -m1 '^Name=' "$file" | sed 's/^Name=//')
        icon=$(grep -m1 '^Icon=' "$file" | sed 's/^Icon=//')
        id=$(basename "$file")
        [ -z "$name" ] && continue
        printf "%s\0icon\x1f%s\x1finfo\x1f%s\n" "$name" "$icon" "$id"
    done
done | sort -u
