#!/usr/bin/env bash
set -e

IMG="$1"
[ -z "$IMG" ] && exit 1
[ ! -f "$IMG" ] && exit 1

# 1) wal16 on the chosen image
wal -q -i "$IMG" --backend wal16
~/.local/bin/patch-waybar-wal16
pkill waybar || true
nohup waybar >/dev/null 2>&1 &


# 2) Set wallpaper via swww
swww img "$IMG" --transition-type any --transition-duration 0.7 2>/dev/null || true

# 3) Restart dock AFTER wal + swww settle, in the background
(
  sleep 1
  "$HOME/.local/bin/reload-dock-hypr.sh"
) &

exit 0
