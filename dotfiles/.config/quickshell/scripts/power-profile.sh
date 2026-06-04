#!/usr/bin/env bash
set -euo pipefail

profile="$(powerprofilesctl get 2>/dev/null || echo balanced)"

case "$profile" in
  performance) printf '󰓅\n' ;;
  power-saver) printf '󰾆\n' ;;
  *) printf '󰾅\n' ;;
esac
