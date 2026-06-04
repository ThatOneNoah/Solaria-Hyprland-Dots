#!/usr/bin/env bash
set -euo pipefail

name="${USER:-noah}"
os="$(
  . /etc/os-release 2>/dev/null
  printf '%s' "${PRETTY_NAME:-Linux}"
)"
cpu="$(awk -F: '/model name/ {gsub(/^ /, "", $2); print $2; exit}' /proc/cpuinfo 2>/dev/null || true)"
de="${XDG_CURRENT_DESKTOP:-Hyprland}"
runtime="$(uptime -p 2>/dev/null | sed 's/^up //')"

printf 'Name: %s\n' "$name"
printf 'OS: %s\n' "$os"
printf 'CPU: %s\n' "${cpu:-unknown}"
printf 'DE: %s\n' "$de"
printf 'Runtime: %s\n' "${runtime:-unknown}"
