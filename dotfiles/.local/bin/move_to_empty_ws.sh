#!/usr/bin/env bash
set -e
hyprctl dispatch movetoworkspace e+1
# tiny delay helps on some setups so the second dispatch doesn't race
sleep 0.05
hyprctl dispatch workspace e+1
