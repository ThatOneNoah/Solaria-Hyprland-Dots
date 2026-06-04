#!/usr/bin/env bash
set -euo pipefail

mode="${1:-temp}"
cache_dir="$HOME/.cache/eww"
zip_file="$cache_dir/weather_zip"
json_file="$cache_dir/weather.json"
stamp_file="$cache_dir/weather.updated"
mkdir -p "$cache_dir"

[[ -s "$zip_file" ]] || printf '10001\n' > "$zip_file"
zip="$(tr -cd '0-9' < "$zip_file" | cut -c1-5)"
[[ -n "$zip" ]] || zip="10001"

now="$(date +%s)"
last="0"
[[ -f "$stamp_file" ]] && last="$(cat "$stamp_file" 2>/dev/null || echo 0)"

if [[ ! -s "$json_file" || $((now - last)) -gt 600 ]]; then
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --max-time 5 "https://wttr.in/${zip}?format=j1" -o "$json_file.tmp" 2>/dev/null && {
      mv "$json_file.tmp" "$json_file"
      printf '%s\n' "$now" > "$stamp_file"
    } || rm -f "$json_file.tmp"
  fi
fi

if [[ ! -s "$json_file" ]] || ! command -v jq >/dev/null 2>&1; then
  case "$mode" in
    icon) printf '○\n' ;;
    desc) printf 'weather unavailable\n' ;;
    *) printf '%s\n' '--°F' ;;
  esac
  exit 0
fi

temp="$(jq -r '.current_condition[0].temp_F // "--"' "$json_file" 2>/dev/null || echo "--")"
desc="$(jq -r '.current_condition[0].weatherDesc[0].value // "unknown"' "$json_file" 2>/dev/null || echo "unknown")"
hour="$(date +%H)"
desc_lc="$(printf '%s' "$desc" | tr '[:upper:]' '[:lower:]')"

icon='☀'
case "$desc_lc" in
  *thunder*|*storm*) icon='ϟ' ;;
  *rain*|*drizzle*|*shower*) icon='☂' ;;
  *snow*|*sleet*|*ice*) icon='❄' ;;
  *fog*|*mist*|*haze*) icon='≋' ;;
  *overcast*) icon='☁' ;;
  *cloud*|*partly*) icon='◐' ;;
  *clear*|*sunny*) icon='☀' ;;
esac

if [[ "$icon" == "☀" && ( "$hour" -ge 19 || "$hour" -lt 6 ) ]]; then
  icon='☾'
fi

case "$mode" in
  icon) printf '%s\n' "$icon" ;;
  desc) printf '%s\n' "$desc" ;;
  *) printf '%s°F\n' "$temp" ;;
esac
