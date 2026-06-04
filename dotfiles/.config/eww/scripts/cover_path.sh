#!/usr/bin/env bash
set -euo pipefail

OUT="$HOME/.cache/eww/cover.jpg"
EMPTY="$HOME/.config/eww/empty-cover.png"
mkdir -p "$HOME/.cache/eww"

url="$(playerctl metadata --format '{{mpris:artUrl}}' 2>/dev/null || true)"

# No art
if [[ -z "$url" ]]; then
  echo "$EMPTY"
  exit 0
fi

# Local file://
if [[ "$url" == file://* ]]; then
  path="${url#file://}"
  if [[ -f "$path" ]]; then
    echo "$path"
  else
    echo "$EMPTY"
  fi
  exit 0
fi

# Remote http(s): download to cache
if [[ "$url" == http://* || "$url" == https://* ]]; then
  # Only re-download if URL changed
  urlfile="$HOME/.cache/eww/cover_url.txt"
  old="$(cat "$urlfile" 2>/dev/null || true)"
  if [[ "$url" != "$old" ]]; then
    echo "$url" > "$urlfile"
    curl -L -s "$url" -o "$OUT" || true
  fi
  [[ -f "$OUT" ]] && echo "$OUT" || echo "$EMPTY"
  exit 0
fi

echo "$EMPTY"
