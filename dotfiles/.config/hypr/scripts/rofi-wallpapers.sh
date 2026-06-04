#!/usr/bin/env bash
set -euo pipefail

WALL_DIR="${HOME}/Pictures/WALLPAPERS"
SETWALL="${HOME}/.config/hypr/scripts/setwall-matugen.sh"

# If rofi is asking us to "run" something, it passes the selection as $1
if [[ "${1-}" != "" ]]; then
  # selection is full path
  "${SETWALL}" "$1"
  exit 0
fi

shopt -s nullglob
for img in "$WALL_DIR"/*.{png,jpg,jpeg,webp}; do
  # rofi dmenu format with icon metadata:
  # label\0icon\x1f/path
  printf '%s\0icon\x1f%s\n' "$img" "$img"
done
