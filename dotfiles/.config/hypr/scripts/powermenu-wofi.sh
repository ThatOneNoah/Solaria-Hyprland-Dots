#!/usr/bin/env bash

choice=$(
  printf "Lock\nLogout\nSuspend\nHibernate\nShutdown\nReboot\n" \
    | wofi --dmenu \
           --prompt "" \
           --cache-file /dev/null \
           --style "$HOME/.config/wofi/powermenu.css" \
           --columns 3 \
           --lines 2 \
           --hide-scroll \
           --width 100% \
           --height 100% \
           --location center
)

case "$choice" in
  "Lock")
    "$HOME/.config/hypr/scripts/hyprlock-swww.sh"
    ;;
  "Logout")
    hyprctl dispatch exit
    ;;
  "Suspend")
    systemctl suspend
    ;;
  "Hibernate")
    systemctl hibernate
    ;;
  "Shutdown")
    systemctl poweroff
    ;;
  "Reboot")
    systemctl reboot
    ;;
  *)
    exit 0
    ;;
esac
