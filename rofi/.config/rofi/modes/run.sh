#!/usr/bin/env bash
set -euo pipefail

if [ -n "${1:-}" ]; then
    # ROFI_INFO contains the .desktop filename set via \0info\x1f
    desktop="${ROFI_INFO:-$1}"
    if [[ "$desktop" == *.desktop ]]; then
        for dir in /usr/share/applications ~/.local/share/applications; do
            file="$dir/$desktop"
            if [ -f "$file" ]; then
                exec_line=$(grep -m1 '^Exec=' "$file" | sed 's/^Exec=//; s/%.//g')
                eval "( $exec_line & )"
                exit 0
            fi
        done
        exit 1
    fi
    eval "( $* & )"
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
