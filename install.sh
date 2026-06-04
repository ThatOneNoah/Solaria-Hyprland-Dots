#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$REPO_DIR/dotfiles"
WALLPAPERS_DIR="$REPO_DIR/wallpapers"
DEFAULT_WALLPAPER="122440215_p0.png"
BACKUP_ROOT="$HOME/.rice-backups/noah-hyprland-rice-$(date +%Y%m%d-%H%M%S)"

ASSUME_YES=0
INSTALL_PACKAGES="ask"
INSTALL_FLATPAKS="ask"
INSTALL_WALLPAPERS=1
BACKUP_MADE=0
INSTALLED_TARGETS=()

PACMAN_PACKAGES=(
  hyprland
  hyprlock
  hypridle
  xdg-desktop-portal-hyprland
  swww
  hyprpaper
  waybar
  rofi-wayland
  mako
  ghostty
  kitty
  foot
  fish
  dolphin
  kate
  network-manager-applet
  blueman
  bluez
  bluez-utils
  power-profiles-daemon
  pipewire
  wireplumber
  pipewire-pulse
  pavucontrol
  playerctl
  brightnessctl
  grim
  slurp
  wl-clipboard
  libnotify
  jq
  curl
  imagemagick
  file
  fastfetch
  cava
  qt5ct
  qt6ct
  kvantum
  nwg-look
  flatpak
  noto-fonts
  ttf-jetbrains-mono-nerd
  ttf-nerd-fonts-symbols
  ttf-nerd-fonts-symbols-mono
  ttf-inter
)

AUR_PACKAGES=(
  quickshell-git
  eww
  matugen-bin
  wlogout
  nwg-bar
  nwg-dock-hyprland
  awww-git
  gpu-screen-recorder
  pywal16
  python-pywalfox
)

FLATPAK_APPS=(
  com.valvesoftware.Steam
  com.spotify.Client
  org.vinegarhq.Sober
)

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  -y, --yes          Answer yes to installer prompts.
  --packages         Install Arch/AUR packages without prompting.
  --no-packages      Skip package installation.
  --flatpaks         Install optional Flatpak apps without prompting.
  --no-flatpaks      Skip optional Flatpak apps.
  --no-wallpapers    Do not copy wallpapers.
  -h, --help         Show this help text.
EOF
}

log() {
  printf '[rice] %s\n' "$*"
}

warn() {
  printf '[rice] warning: %s\n' "$*" >&2
}

ask_yes() {
  local prompt="$1"
  if [[ "$ASSUME_YES" -eq 1 ]]; then
    return 0
  fi

  local answer
  read -r -p "$prompt [Y/n] " answer
  case "${answer,,}" in
    n|no) return 1 ;;
    *) return 0 ;;
  esac
}

ask_no() {
  local prompt="$1"
  if [[ "$ASSUME_YES" -eq 1 ]]; then
    return 0
  fi

  local answer
  read -r -p "$prompt [y/N] " answer
  case "${answer,,}" in
    y|yes) return 0 ;;
    *) return 1 ;;
  esac
}

run_pacman() {
  if [[ "$EUID" -eq 0 ]]; then
    pacman "$@"
  else
    sudo pacman "$@"
  fi
}

install_arch_packages() {
  if ! command -v pacman >/dev/null 2>&1; then
    warn "pacman was not found; package install is Arch-only. Skipping packages."
    return 0
  fi

  log "Installing pacman packages. Missing or renamed packages will be reported and skipped."
  local failed=()
  local pkg
  for pkg in "${PACMAN_PACKAGES[@]}"; do
    if pacman -Qi "$pkg" >/dev/null 2>&1; then
      continue
    fi

    if ! run_pacman -S --needed --noconfirm "$pkg"; then
      failed+=("$pkg")
    fi
  done

  if [[ "${#failed[@]}" -gt 0 ]]; then
    warn "pacman could not install: ${failed[*]}"
  fi

  local helper=""
  if command -v yay >/dev/null 2>&1; then
    helper="yay"
  elif command -v paru >/dev/null 2>&1; then
    helper="paru"
  fi

  if [[ -z "$helper" ]]; then
    warn "no AUR helper found. Install these manually if needed: ${AUR_PACKAGES[*]}"
    return 0
  fi

  if [[ "$EUID" -eq 0 ]]; then
    warn "AUR helpers should not run as root. Skipping AUR packages: ${AUR_PACKAGES[*]}"
    return 0
  fi

  log "Installing AUR packages with $helper."
  failed=()
  for pkg in "${AUR_PACKAGES[@]}"; do
    if pacman -Qi "$pkg" >/dev/null 2>&1; then
      continue
    fi

    if ! "$helper" -S --needed --noconfirm "$pkg"; then
      failed+=("$pkg")
    fi
  done

  if [[ "${#failed[@]}" -gt 0 ]]; then
    warn "$helper could not install: ${failed[*]}"
  fi
}

install_flatpaks() {
  if ! command -v flatpak >/dev/null 2>&1; then
    warn "flatpak was not found; skipping optional Flatpak apps."
    return 0
  fi

  flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak install --user -y flathub "${FLATPAK_APPS[@]}"
}

backup_existing() {
  local target="$1"
  if [[ ! -e "$target" && ! -L "$target" ]]; then
    return 0
  fi

  local rel="${target#$HOME/}"
  local backup_target="$BACKUP_ROOT/$rel"
  mkdir -p "$(dirname "$backup_target")"
  mv "$target" "$backup_target"
  BACKUP_MADE=1
}

install_one() {
  local source="$1"
  local target="$2"

  backup_existing "$target"
  mkdir -p "$(dirname "$target")"
  cp -a "$source" "$target"
  INSTALLED_TARGETS+=("$target")
}

install_configs() {
  log "Installing config folders."
  mkdir -p "$HOME/.config"

  local source
  shopt -s nullglob
  for source in "$DOTFILES_DIR/.config"/*; do
    install_one "$source" "$HOME/.config/$(basename "$source")"
  done
  shopt -u nullglob
}

install_local_bin() {
  log "Installing helper scripts."
  mkdir -p "$HOME/.local/bin"

  local source
  shopt -s nullglob
  for source in "$DOTFILES_DIR/.local/bin"/*; do
    install_one "$source" "$HOME/.local/bin/$(basename "$source")"
  done
  shopt -u nullglob

  find "$HOME/.local/bin" -maxdepth 1 -type f -exec chmod +x {} +
}

install_fonts() {
  if [[ ! -d "$DOTFILES_DIR/.local/share/fonts" ]]; then
    return 0
  fi

  log "Installing bundled fonts."
  mkdir -p "$HOME/.local/share/fonts"
  cp -a "$DOTFILES_DIR/.local/share/fonts/." "$HOME/.local/share/fonts/"

  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
  fi
}

install_extra_scripts() {
  if [[ ! -d "$REPO_DIR/extras/scripts" ]]; then
    return 0
  fi

  log "Installing extra scripts."
  mkdir -p "$HOME/scripts"

  local source
  shopt -s nullglob
  for source in "$REPO_DIR/extras/scripts"/*; do
    install_one "$source" "$HOME/scripts/$(basename "$source")"
  done
  shopt -u nullglob
}

copy_wallpapers() {
  [[ "$INSTALL_WALLPAPERS" -eq 1 ]] || return 0
  [[ -d "$WALLPAPERS_DIR" ]] || return 0

  log "Copying wallpapers without overwriting existing files."
  mkdir -p "$HOME/Pictures/WALLPAPERS"

  local rel source target
  while IFS= read -r -d '' rel; do
    source="$WALLPAPERS_DIR/$rel"
    target="$HOME/Pictures/WALLPAPERS/$rel"
    mkdir -p "$(dirname "$target")"
    if [[ ! -e "$target" ]]; then
      cp -a "$source" "$target"
    fi
  done < <(cd "$WALLPAPERS_DIR" && find . -type f -printf '%P\0')

  if [[ -f "$HOME/Pictures/WALLPAPERS/$DEFAULT_WALLPAPER" ]]; then
    ln -sf "$HOME/Pictures/WALLPAPERS/$DEFAULT_WALLPAPER" "$HOME/.config/hypr/current_wallpaper"
  fi
}

replace_home_placeholders() {
  if [[ "${#INSTALLED_TARGETS[@]}" -eq 0 ]]; then
    return 0
  fi

  log "Rewriting home-directory placeholders."
  local file
  while IFS= read -r -d '' file; do
    HOME_REPL="$HOME" perl -0pi -e 's#__HOME__#$ENV{HOME_REPL}#g; s#/home/noah#$ENV{HOME_REPL}#g' "$file"
  done < <(grep -RIlZ -e '__HOME__' -e '/home/noah' "${INSTALLED_TARGETS[@]}" 2>/dev/null || true)
}

fix_permissions() {
  log "Fixing script permissions."
  find "$HOME/.config/hypr/scripts" "$HOME/.config/quickshell/scripts" "$HOME/.config/eww/scripts" \
    -type f -exec chmod +x {} + 2>/dev/null || true
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -y|--yes)
      ASSUME_YES=1
      ;;
    --packages)
      INSTALL_PACKAGES="yes"
      ;;
    --no-packages)
      INSTALL_PACKAGES="no"
      ;;
    --flatpaks)
      INSTALL_FLATPAKS="yes"
      ;;
    --no-flatpaks)
      INSTALL_FLATPAKS="no"
      ;;
    --no-wallpapers)
      INSTALL_WALLPAPERS=0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

case "$INSTALL_PACKAGES" in
  yes)
    install_arch_packages
    ;;
  ask)
    if ask_yes "Install Arch/AUR packages for the rice?"; then
      install_arch_packages
    fi
    ;;
esac

case "$INSTALL_FLATPAKS" in
  yes)
    install_flatpaks
    ;;
  ask)
    if ask_no "Install optional Flatpak apps used in the dock?"; then
      install_flatpaks
    fi
    ;;
esac

install_configs
install_local_bin
install_fonts
install_extra_scripts
replace_home_placeholders
copy_wallpapers
fix_permissions

log "Install finished."
if [[ "$BACKUP_MADE" -eq 1 ]]; then
  log "Backups were saved to $BACKUP_ROOT"
fi
log "Log out and start Hyprland, or run: hyprctl reload"
log "Edit ~/.config/hypr/hyprland.conf if your monitors need custom names or refresh rates."
