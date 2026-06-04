#!/usr/bin/env bash
set -euo pipefail

if ! command -v bluetoothctl >/dev/null 2>&1; then
  printf '󰂲\n'
  exit 0
fi

show="$(bluetoothctl show 2>/dev/null || true)"
powered="$(printf '%s\n' "$show" | awk '/Powered:/ {print $2; exit}')"
if [[ "$powered" != "yes" ]]; then
  printf '󰂲\n'
  exit 0
fi

device="$((bluetoothctl devices Connected 2>/dev/null || true) | cut -d' ' -f3- | head -n1)"
if [[ -n "$device" ]]; then
  printf '󰂱\n'
else
  printf '󰂯\n'
fi
