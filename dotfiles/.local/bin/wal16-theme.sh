#!/usr/bin/env bash
set -e

WALL="$1"
WALL_DIR="$HOME/Pictures/WALLPAPERS"
PYWAL_CACHE="$HOME/.cache/wal"
GHOSTTY_CONF="$HOME/.config/ghostty"

if [[ -z "$WALL" || ! -f "$WALL" ]]; then
  # pick random wallpaper if none given
  WALL="$(find "$WALL_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | shuf -n 1)"
fi

# 1) set wallpaper (Hyprland + swww)
swww init 2>/dev/null || true
swww img "$WALL" --transition-type any --transition-duration 0.4

# 2) generate palette with pywal16 (no wallpaper setting, quiet)
wal -n -q -i "$WALL"

# 3) keep a small text file with current wallpaper for rofi theme/script
echo "$WALL" > "$PYWAL_CACHE/current_wallpaper"

# 4) Ghostty theme symlink
mkdir -p "$GHOSTTY_CONF/themes"
ln -sf "$PYWAL_CACHE/ghostty-wal16.conf" "$GHOSTTY_CONF/themes/wal16.conf"

# 5) kick Hyprland + Waybar
hyprctl reload >/dev/null 2>&1 || true

# (GTK will pick up the CSS on next app restart; no need to reload)

PYWAL_CACHE="$HOME/.cache/wal"

# If pywal16 generated a Hyprland file, copy it over our wal-colors.conf
if [ -f "$PYWAL_CACHE/hyprland-wal16.conf" ]; then
    cp "$PYWAL_CACHE/hyprland-wal16.conf" "$HOME/.config/hypr/wal-colors.conf"
fi

# Update a tiny rofi snippet with current wallpaper as background
ROFI_SNIPPET="$PYWAL_CACHE/rofi-preview-wallpaper.rasi"
cat > "$ROFI_SNIPPET" <<EOF
textbox-preview {
    background-image: url("$WALL");
    background-size: cover;
    background-position: center;
}
EOF
