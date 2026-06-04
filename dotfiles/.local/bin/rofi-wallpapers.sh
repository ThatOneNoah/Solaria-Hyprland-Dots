#!/usr/bin/env bash

WALL_DIR="$HOME/Pictures/WALLPAPERS"

mapfile -t WALLS < <(
  find "$WALL_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
    | sort
)

if [ "${#WALLS[@]}" -eq 0 ]; then
  echo "No wallpapers found in $WALL_DIR"
  exit 1
fi

case "${ROFI_RETV:-0}" in
  0)
    # First call: show entries with preview icons
    for w in "${WALLS[@]}"; do
      base="$(basename "$w")"
      printf '%s\0icon\x1f%s\n' "$base" "$w"
    done
    ;;

  1)
    # User picked an item
    CHOICE="${1:-}"
    SELECTED=""

    for w in "${WALLS[@]}"; do
      if [ "$(basename "$w")" = "$CHOICE" ]; then
        SELECTED="$w"
        break
      fi
    done

    [ -z "$SELECTED" ] && exit 1

    # Launch in background directly (NOT via hyprctl dispatch exec)
    # This avoids quoting/path issues from rofi script mode.
    nohup bash "$HOME/.local/bin/apply-wallpaper-matugen" "$SELECTED" \
      >/tmp/rofi-wallpaper-apply.log 2>&1 &
    ;;
esac
