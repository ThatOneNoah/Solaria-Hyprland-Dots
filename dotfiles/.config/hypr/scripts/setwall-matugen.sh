#!/usr/bin/env bash
set -euo pipefail

WALL="$1"

exec "$HOME/.local/bin/apply-wallpaper-matugen" "$WALL"
