#!/usr/bin/env bash
set -e

WALL_DIR="$HOME/Pictures/WALLPAPERS"          # put your images here
STATE_FILE="$HOME/.cache/current-wallpaper.txt"

mkdir -p "$(dirname "$STATE_FILE")"

# 1) Build wallpaper list
mapfile -t WALLS < <(find "$WALL_DIR" -maxdepth 1 -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort)

if [ "${#WALLS[@]}" -eq 0 ]; then
  echo "No wallpapers found in $WALL_DIR" >&2
  exit 1
fi

# 2) Figure out "next" wallpaper (simple cycle)
idx=0
if [ -f "$STATE_FILE" ]; then
  current="$(cat "$STATE_FILE")"
  for i in "${!WALLS[@]}"; do
    if [ "${WALLS[$i]}" = "$current" ]; then
      idx=$(( (i + 1) % ${#WALLS[@]} ))
      break
    fi
  done
fi

NEXT="${WALLS[$idx]}"
printf '%s\n' "$NEXT" > "$STATE_FILE"

# 3) wal16 on the chosen image
wal -q -i "$NEXT" --backend wal16
~/.local/bin/patch-waybar-wal16
pkill waybar || true
nohup waybar >/dev/null 2>&1 &



# 4) Set wallpaper via swww
swww img "$NEXT" --transition-type any --transition-duration 0.7 2>/dev/null || true

# 5) Restart dock AFTER wal + swww settle, in the background
(
  sleep 1
  "$HOME/.local/bin/reload-dock-hypr.sh"
) &

exit 0
