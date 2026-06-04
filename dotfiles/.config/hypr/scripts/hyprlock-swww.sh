#!/usr/bin/env bash

# Update symlink to current wallpaper, then run hyprlock

img="$(
  swww query 2>/dev/null \
    | awk -F'image: ' '/currently displaying: image:/ {print $2; exit}'
)"
if [ -z "$img" ] || [ ! -f "$img" ]; then
  img="$(
    awww query 2>/dev/null \
      | awk -F'image: ' '/image:/ {print $2; exit}'
  )"
fi

if [ -n "$img" ] && [ -f "$img" ]; then
  mkdir -p "$HOME/.config/hypr"
  ln -sf "$img" "$HOME/.config/hypr/current_wallpaper"
fi

exec hyprlock "$@"
