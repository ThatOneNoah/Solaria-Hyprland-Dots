#!/usr/bin/env bash
set -euo pipefail

zip="$(printf '%s' "${1:-}" | tr -cd '0-9' | cut -c1-5)"
[[ ${#zip} -eq 5 ]] || exit 0

mkdir -p "$HOME/.cache/eww"
printf '%s\n' "$zip" > "$HOME/.cache/eww/weather_zip"
rm -f "$HOME/.cache/eww/weather.json" "$HOME/.cache/eww/weather.updated"

if command -v eww >/dev/null 2>&1; then
  eww update weather_zip="$zip" \
    weather_icon="$("$HOME/.config/eww/scripts/weather.sh" icon)" \
    weather_temp="$("$HOME/.config/eww/scripts/weather.sh" temp)" \
    weather_desc="$("$HOME/.config/eww/scripts/weather.sh" desc)" >/dev/null 2>&1 || true
fi
