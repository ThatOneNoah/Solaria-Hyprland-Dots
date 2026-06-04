#!/usr/bin/env bash
set -euo pipefail

artist="$(playerctl metadata --format '{{artist}}' 2>/dev/null || true)"
status="$(playerctl status 2>/dev/null || echo "Stopped")"

if [[ "$status" == "Stopped" ]]; then
  echo ""
else
  echo "$artist"
fi
