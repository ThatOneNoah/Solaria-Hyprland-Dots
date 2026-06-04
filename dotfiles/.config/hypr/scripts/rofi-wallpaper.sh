#!/usr/bin/env bash
set -euo pipefail

WALLDIR="${WALLDIR:-$HOME/Pictures/WALLPAPERS}"

# rofi script mode contract:
# ROFI_RETV=0 -> list entries
# ROFI_RETV=1 -> user selected an entry (ROFI_INFO contains info if we set it, but we'll just use the text)

if [[ "${ROFI_RETV:-0}" == "0" ]]; then
  find "$WALLDIR" -maxdepth 2 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) \
    -printf '%f\n' | sort
  exit 0
fi

SEL="${1:-}"
[[ -z "$SEL" ]] && exit 0

WALL="$WALLDIR/$SEL"
if [[ -f "$WALL" ]]; then
  "$HOME/.config/hypr/scripts/setwall-matugen.sh" "$WALL"
fi
