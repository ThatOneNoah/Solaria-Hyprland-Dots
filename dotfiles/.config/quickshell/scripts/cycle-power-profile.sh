#!/usr/bin/env bash
set -euo pipefail

current="$(powerprofilesctl get 2>/dev/null || echo balanced)"

case "$current" in
  performance) next="balanced" ;;
  balanced) next="power-saver" ;;
  *) next="performance" ;;
esac

powerprofilesctl set "$next" >/dev/null 2>&1 || true
