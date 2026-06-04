#!/usr/bin/env bash
set -euo pipefail

WALL="$HOME/.config/hypr/current_wallpaper"
if [[ -z "${WALL}" || ! -f "${WALL}" ]]; then
  WALL="$(swww query 2>/dev/null | sed -nE 's/^.*image: ([^,]+).*$/\1/p' | head -n1)"
fi
if [[ -z "${WALL}" || ! -f "${WALL}" ]]; then
  WALL="$(awww query 2>/dev/null | sed -nE 's/^.*image: ([^,]+).*$/\1/p' | head -n1)"
fi
if [[ -z "${WALL}" || ! -f "${WALL}" ]]; then
  WALL="$HOME/Pictures/WALLPAPERS/wall-06.png"
fi

TMP="/tmp/hyprlock-generated.conf"

# Use specific faces (this is what actually renders Mojangles in hyprlock v0.9.2)
FONT_TIME="Mojangles Bold"
FONT_UI="Mojangles"

cat >"$TMP" <<EOF
general {
  hide_cursor = true
  immediate_render = true
}

background {
  monitor =
  path = $WALL
  blur_passes = 2
  blur_size = 5
  noise = 0.02
  contrast = 1.0
  brightness = 1.0
}

# ---- TIME (12-hour, no outline box) ----
label {
  monitor =
  text = cmd[update:1000] date +"%-I:%M %p"
  color = rgba(255, 255, 255, 1.0)
  font_size = 96
  font_family = $FONT_TIME

  position = 0, 150
  halign = center
  valign = center
  zindex = 2
}

# ---- DATE (no outline) ----
label {
  monitor =
  text = cmd[update:1000] date +"%a %b %d"
  color = rgba(255, 255, 255, 1.0)
  font_size = 28
  font_family = $FONT_UI

  position = 0, 70
  halign = center
  valign = center
  zindex = 2
}

# ---- PASSWORD FIELD (square + outline) ----
input-field {
  monitor =
  size = 380, 56
  position = 0, -90
  halign = center
  valign = center

  rounding = 0
  outline_thickness = 2

  inner_color = rgba(0, 0, 0, 0.35)
  outer_color = rgba(255, 255, 255, 0.95)
  font_color  = rgba(255, 255, 255, 1.0)

  font_family = $FONT_UI
  dots_center = true
  dots_rounding = 0

  placeholder_text = <i>Password...</i>
}
EOF

exec hyprlock -c "$TMP"
