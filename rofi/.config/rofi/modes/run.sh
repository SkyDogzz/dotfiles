#!/usr/bin/env bash
set -euo pipefail

if [ -n "${1:-}" ]; then
    if [[ "$1" == *.desktop ]]; then
        file=$(find /usr/share/applications ~/.local/share/applications -name "$1" 2>/dev/null | head -1)
        if [ -n "$file" ]; then
            exec_line=$(grep -m1 '^Exec=' "$file" | sed 's/^Exec=//; s/%.//g')
            eval exec "$exec_line"
        fi
        exit 1
    fi
    eval exec "$@"
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
