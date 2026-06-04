#!/usr/bin/env bash
set -euo pipefail

len_us="$(playerctl metadata --format '{{mpris:length}}' 2>/dev/null || true)"
pos_s="$(playerctl position 2>/dev/null || true)"
len_us="${len_us:-0}"
pos_s="${pos_s:-0}"

if ! [[ "$len_us" =~ ^[0-9]+([.][0-9]+)?$ ]] || ! [[ "$pos_s" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  echo "0:00 / 0:00"
  exit 0
fi

python - <<PY
import math
len_us = float("$len_us") if "$len_us".strip() else 0.0
pos_s  = float("$pos_s")  if "$pos_s".strip()  else 0.0

def fmt(sec):
    sec = max(0, int(sec))
    m = sec // 60
    s = sec % 60
    return f"{m}:{s:02d}"

total_s = len_us / 1_000_000.0 if len_us > 0 else 0
print(f"{fmt(pos_s)} / {fmt(total_s)}" if total_s > 0 else "0:00 / 0:00")
PY
