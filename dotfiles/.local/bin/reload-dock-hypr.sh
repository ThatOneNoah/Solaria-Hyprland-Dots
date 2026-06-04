#!/usr/bin/env bash

# Kill any running dock instances (ignore if none)
pkill -f "nwg-dock-hyprland" >/dev/null 2>&1 || true

# Let layer-shell release cleanly
sleep 0.4

# IMPORTANT: nwg-dock expects style file name, not full path
nohup nwg-dock-hyprland \
  -x -p bottom -i 24 -ml 10 -mr 10 -mb 5 -mt 5 \
  -s style.css \
  >/tmp/nwg-dock.log 2>&1 &
