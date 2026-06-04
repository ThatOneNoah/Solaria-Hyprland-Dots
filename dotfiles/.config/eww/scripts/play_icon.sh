#!/usr/bin/env bash
set -euo pipefail

status="$(playerctl status 2>/dev/null || echo "Stopped")"
if [[ "$status" == "Playing" ]]; then
  echo ""
else
  echo ""
fi
