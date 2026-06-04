#!/usr/bin/env bash
set -euo pipefail

exec-once = ~/.config/hypr/scripts/launch-dock.sh

pkill -f nwg-dock-hyprland 2>/dev/null || true
sleep 0.1

cd "$HOME/.config/nwg-dock-hyprland"
nwg-dock-hyprland -x -p bottom -i 22 -mt 0 -mb 12 -ml 0 -s style.css &
disown
