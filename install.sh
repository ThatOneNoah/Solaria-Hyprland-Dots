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
  rofi
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

DEBIAN_PACKAGES=(
  hyprland
  hyprlock
  hypridle
  xdg-desktop-portal-hyprland
  swww
  waybar
  rofi
  mako-notifier
  kitty
  foot
  fish
  dolphin
  kate
  network-manager-gnome
  blueman
  bluez
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
  libnotify-bin
  jq
  curl
  imagemagick
  file
  fastfetch
  cava
  qt5ct
  qt6ct
  qt5-style-kvantum
  qt6-style-kvantum
  nwg-look
  flatpak
  fonts-noto-core
  fonts-jetbrains-mono
  fonts-inter
)

DEBIAN_MANUAL_PACKAGES=(
  quickshell
  eww
  matugen
  wlogout
  nwg-bar
  nwg-dock-hyprland
  awww
  gpu-screen-recorder
  pywal16
  pywalfox
  ghostty
)

FEDORA_PACKAGES=(
  hyprland
  hyprlock
  hypridle
  xdg-desktop-portal-hyprland
  swww
  hyprpaper
  waybar
  rofi-wayland
  mako
  wlogout
  ghostty
  kitty
  foot
  fish
  dolphin
  kate
  network-manager-applet
  blueman
  bluez
  power-profiles-daemon
  pipewire
  wireplumber
  pipewire-pulseaudio
  pavucontrol
  playerctl
  brightnessctl
  grim
  slurp
  wl-clipboard
  libnotify
  jq
  curl
  ImageMagick
  file
  fastfetch
  cava
  qt5ct
  qt6ct
  kvantum
  nwg-look
  flatpak
  google-noto-sans-fonts
  jetbrains-mono-fonts
  rsms-inter-fonts
)

FEDORA_MANUAL_PACKAGES=(
  quickshell
  eww
  matugen
  nwg-bar
  nwg-dock-hyprland
  awww
  gpu-screen-recorder
  pywal16
  pywalfox
)

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  -y, --yes          Answer yes to installer prompts.
  --packages         Install distro packages without prompting.
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

run_root() {
  if [[ "$EUID" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
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
  run_root pacman "$@"
}

distro_id() {
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    printf '%s\n' "${ID:-unknown}"
  else
    printf 'unknown\n'
  fi
}

distro_like() {
  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    printf '%s\n' "${ID_LIKE:-}"
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

install_debian_packages() {
  if ! command -v apt-get >/dev/null 2>&1; then
    warn "apt-get was not found. Skipping Debian/Ubuntu package install."
    return 0
  fi

  log "Installing apt packages. Missing or renamed packages will be reported and skipped."
  run_root apt-get update || warn "apt-get update failed; continuing with package attempts."

  local failed=()
  local pkg
  for pkg in "${DEBIAN_PACKAGES[@]}"; do
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q 'install ok installed'; then
      continue
    fi

    if ! run_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"; then
      failed+=("$pkg")
    fi
  done

  if [[ "${#failed[@]}" -gt 0 ]]; then
    warn "apt could not install: ${failed[*]}"
  fi
  warn "Debian/Ubuntu may need these installed from source, third-party repos, Flatpak, or Nix: ${DEBIAN_MANUAL_PACKAGES[*]}"
}

install_fedora_packages() {
  if ! command -v dnf >/dev/null 2>&1; then
    warn "dnf was not found. Skipping Fedora package install."
    return 0
  fi

  log "Installing dnf packages. Missing or renamed packages will be reported and skipped."
  local failed=()
  local pkg
  for pkg in "${FEDORA_PACKAGES[@]}"; do
    if rpm -q "$pkg" >/dev/null 2>&1; then
      continue
    fi

    if ! run_root dnf install -y "$pkg"; then
      failed+=("$pkg")
    fi
  done

  if [[ "${#failed[@]}" -gt 0 ]]; then
    warn "dnf could not install: ${failed[*]}"
  fi
  warn "Fedora may need these installed from source, COPR, Flatpak, or Nix: ${FEDORA_MANUAL_PACKAGES[*]}"
}

install_nixos_packages() {
  warn "NixOS package installation is declarative; this script will not edit /etc/nixos/configuration.nix."
  warn "Use extras/nixos/configuration-example.nix, then run ./install.sh --no-packages to copy the dotfiles."
}

install_distro_packages() {
  local id like
  id="$(distro_id)"
  like="$(distro_like)"

  case "$id:$like" in
    arch:*|endeavouros:*|manjaro:*)
      install_arch_packages
      ;;
    debian:*|ubuntu:*|pop:*|linuxmint:*|*:debian*|*:ubuntu*)
      install_debian_packages
      ;;
    fedora:*|nobara:*|*:fedora*)
      install_fedora_packages
      ;;
    nixos:*)
      install_nixos_packages
      ;;
    *)
      warn "Unsupported distro '$id'. Copying dotfiles still works; install packages manually from docs/DISTROS.md."
      ;;
  esac
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

install_applications() {
  if [[ ! -d "$DOTFILES_DIR/.local/share/applications" ]]; then
    return 0
  fi

  log "Installing desktop launchers."
  mkdir -p "$HOME/.local/share/applications"

  local source
  shopt -s nullglob
  for source in "$DOTFILES_DIR/.local/share/applications"/*.desktop; do
    install_one "$source" "$HOME/.local/share/applications/$(basename "$source")"
  done
  shopt -u nullglob

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
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

seed_solaria_profile() {
  local data_home profile
  data_home="${XDG_DATA_HOME:-"$HOME/.local/share"}"
  profile="$data_home/solaria-dots/profiles/solaria"

  if [[ -d "$profile" ]]; then
    log "Dot profile 'solaria' already exists; leaving it unchanged."
    return 0
  fi

  log "Creating built-in dot profile: solaria"
  mkdir -p "$profile"
  cp -a "$DOTFILES_DIR" "$profile/dotfiles"
  if [[ -d "$WALLPAPERS_DIR" ]]; then
    cp -a "$WALLPAPERS_DIR" "$profile/wallpapers"
  else
    mkdir -p "$profile/wallpapers"
  fi

  cat >"$profile/profile.conf" <<EOF
name=solaria
source=repo
created_at=$(date -Iseconds)
default_wallpaper=$DEFAULT_WALLPAPER
EOF
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
    install_distro_packages
    ;;
  ask)
    if ask_yes "Install distro packages for the rice?"; then
      install_distro_packages
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
install_applications
install_extra_scripts
replace_home_placeholders
copy_wallpapers
seed_solaria_profile
fix_permissions

log "Install finished."
if [[ "$BACKUP_MADE" -eq 1 ]]; then
  log "Backups were saved to $BACKUP_ROOT"
fi
log "Log out and start Hyprland, or run: hyprctl reload"
log "Edit ~/.config/hypr/hyprland.conf if your monitors need custom names or refresh rates."
