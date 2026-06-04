#!/usr/bin/env bash
set -euo pipefail

title="$(playerctl metadata --format '{{title}}' 2>/dev/null || true)"
status="$(playerctl status 2>/dev/null || echo "Stopped")"

if [[ "$status" == "Stopped" || -z "$title" ]]; then
  echo "No music"
else
  echo "$title"
fi
