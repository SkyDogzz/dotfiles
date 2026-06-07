#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
    cliphist list
else
    printf '%s' "$*" | cliphist decode | wl-copy
fi
