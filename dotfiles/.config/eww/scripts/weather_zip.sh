#!/usr/bin/env bash
set -euo pipefail

zip_file="$HOME/.cache/eww/weather_zip"
mkdir -p "${zip_file%/*}"

if [[ ! -s "$zip_file" ]]; then
  printf '10001\n' > "$zip_file"
fi

tr -cd '0-9' < "$zip_file" | cut -c1-5
printf '\n'
