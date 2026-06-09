#!/usr/bin/env bash

DIR="${1:-.}"

find "$DIR" \
  \( -type d \( -name ".git" -o -name "node_modules" \) -prune \) -o \
  -type f -name "*.*" -print |
awk '
{
  name = $0
  sub(/^.*\//, "", name)

  if (name ~ /^\.[^.]+$/) next

  ext = name
  sub(/^.*\./, "", ext)

  if (ext != name)
    count[ext]++
}
END {
  for (ext in count)
    print "." ext, count[ext]
}
' | sort
