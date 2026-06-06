#!/usr/bin/env bash

models=(
  "qwen3.5:9b"
  "qwen2.5-coder:7b"
  "deepseek-r1:7b"
  "qwen3:8b"
  "qwen3.5:4b"
  "mistral:7b"
)

missing=0
available_list=$(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}')

for m in "${models[@]}"; do
  if echo "$available_list" | grep -qx "$m"; then
    size=$(ollama list | grep "$m" | awk '{print $3}')
    echo "  $m  $size"
  else
    echo "  $m  MISSING"
    missing=1
  fi
done

echo ""
if [ "$missing" -eq 0 ]; then
  echo "All models present."
else
  echo "Some models are missing. Run: ollama pull <model>"
fi
