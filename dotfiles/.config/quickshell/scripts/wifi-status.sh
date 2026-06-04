#!/usr/bin/env bash
set -euo pipefail

connected="$((nmcli -t -f active,ssid dev wifi 2>/dev/null || true) | awk -F: '$1 == "yes" {print "yes"; exit}')"

if [[ "$connected" == "yes" ]]; then
  printf '󰖩\n'
else
  printf '󰖪\n'
fi
