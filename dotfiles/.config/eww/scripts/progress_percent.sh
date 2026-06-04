#!/usr/bin/env bash
set -euo pipefail

len_us="$(playerctl metadata --format '{{mpris:length}}' 2>/dev/null || true)"
pos_s="$(playerctl position 2>/dev/null || true)"
len_us="${len_us:-0}"
pos_s="${pos_s:-0}"

if ! [[ "$len_us" =~ ^[0-9]+([.][0-9]+)?$ ]] || ! [[ "$pos_s" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  echo 0
  exit 0
fi

# len_us is microseconds, pos_s is seconds (float)
if [[ "$len_us" == "0" || -z "$len_us" ]]; then
  echo 0
  exit 0
fi

awk -v len_us="$len_us" -v pos_s="$pos_s" 'BEGIN {
  pct = int((pos_s * 1000000.0 / len_us) * 100.0)
  if (pct < 0) pct = 0
  if (pct > 100) pct = 100
  print pct
}'
