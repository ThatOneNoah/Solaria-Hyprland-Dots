#!/usr/bin/env bash
set -euo pipefail

volume=""
muted="no"

if command -v wpctl >/dev/null 2>&1; then
  line="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
  raw="$(awk '{print $2}' <<<"$line")"
  [[ "$line" == *"[MUTED]"* ]] && muted="yes"
  if [[ "$raw" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    volume="$(awk -v v="$raw" 'BEGIN { printf "%d", (v * 100) + 0.5 }')"
  fi
elif command -v pactl >/dev/null 2>&1; then
  sink="$(pactl get-default-sink 2>/dev/null || true)"
  if [[ -n "$sink" ]]; then
    volume="$(pactl get-sink-volume "$sink" 2>/dev/null | awk -F'/' 'NR == 1 { gsub(/[^0-9]/, "", $2); print $2; exit }')"
    muted="$(pactl get-sink-mute "$sink" 2>/dev/null | awk '{print $2}')"
  fi
fi

volume="${volume:-0}"
(( volume > 100 )) && volume=100

if [[ "$muted" == "yes" || "$volume" -eq 0 ]]; then
  icon="󰝟"
elif (( volume < 34 )); then
  icon="󰕿"
elif (( volume < 67 )); then
  icon="󰖀"
else
  icon="󰕾"
fi

printf '%s %s%%\n' "$icon" "$volume"
