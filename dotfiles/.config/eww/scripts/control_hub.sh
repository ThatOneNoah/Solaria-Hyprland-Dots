#!/usr/bin/env bash
set -euo pipefail

action="${1:-open}"
log="$HOME/.cache/eww/control_hub.log"
mkdir -p "$HOME/.cache/eww"

ensure_daemon() {
  if ! timeout 1s eww ping >/dev/null 2>&1; then
    eww daemon >>"$log" 2>&1 || true
    sleep 0.15
  fi
}

case "$action" in
  open)
    ensure_daemon
    timeout --kill-after=1s 2s eww update hub_hovered=false >>"$log" 2>&1 || true
    timeout --kill-after=1s 2s eww open control_hub >>"$log" 2>&1 || true
    (
      sleep 1
      hovered="$(timeout --kill-after=1s 2s eww get hub_hovered 2>/dev/null || true)"
      if [[ "$hovered" != "true" ]]; then
        timeout --kill-after=1s 2s eww close control_hub >>"$log" 2>&1 || true
      fi
    ) &
    ;;
  close)
    timeout --kill-after=1s 2s eww update hub_hovered=false >>"$log" 2>&1 || true
    timeout --kill-after=1s 2s eww close control_hub >>"$log" 2>&1 || true
    ;;
  close-if-hovered)
    hovered="$(timeout --kill-after=1s 2s eww get hub_hovered 2>/dev/null || true)"
    if [[ "$hovered" == "true" ]]; then
      timeout --kill-after=1s 2s eww update hub_hovered=false >>"$log" 2>&1 || true
      timeout --kill-after=1s 2s eww close control_hub >>"$log" 2>&1 || true
    fi
    ;;
  *)
    echo "usage: $0 {open|close|close-if-hovered}" >&2
    exit 2
    ;;
esac
