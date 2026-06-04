# Distro Support

The dotfile copy step works on any Linux system with Bash, `cp`, `find`, `grep`, and `perl`.

Package installation is best-effort. Hyprland itself is widely packaged now, but some rice tools, especially Quickshell, Eww, Matugen, Awww, NWG helpers, Pywal16, and GPU Screen Recorder, may require an AUR helper, COPR, source builds, Nix, or Flatpak depending on the distro release.

## Arch Linux

Best supported.

```bash
./install.sh --packages --flatpaks
```

The installer uses:

- `pacman` for repo packages.
- `yay` or `paru` for AUR packages, when available.

Manual packages if no AUR helper exists:

```text
quickshell-git eww matugen-bin wlogout nwg-bar nwg-dock-hyprland awww-git gpu-screen-recorder pywal16 python-pywalfox
```

## Debian

```bash
./install.sh --packages
```

The installer uses `apt-get` for packages that exist in Debian repos. On stable Debian, several Hyprland ecosystem packages may be missing or older. Use Debian testing/unstable, backports, source builds, Flatpak, or Nix for missing tools.

Common manual tools:

```text
quickshell eww matugen wlogout nwg-bar nwg-dock-hyprland awww gpu-screen-recorder pywal16 pywalfox ghostty
```

## Ubuntu

```bash
./install.sh --packages
```

Ubuntu package availability depends heavily on the Ubuntu release. Newer releases have better Hyprland coverage. If `apt` reports missing packages, install those manually from source, third-party packages, Flatpak, or Nix.

Common manual tools:

```text
quickshell eww matugen wlogout nwg-bar nwg-dock-hyprland awww gpu-screen-recorder pywal16 pywalfox ghostty
```

## Fedora

```bash
./install.sh --packages
```

The installer uses `dnf` for Fedora packages and skips anything unavailable. Some tools may need COPR, source builds, Flatpak, or Nix.

Common manual tools:

```text
quickshell eww matugen nwg-bar nwg-dock-hyprland awww gpu-screen-recorder pywal16 pywalfox
```

## NixOS

Do not use the package installer step for NixOS. Add the packages declaratively, rebuild, then copy the rice dotfiles:

```bash
sudo cp extras/nixos/configuration-example.nix /etc/nixos/noah-hyprland-rice.nix
```

Then import it from `/etc/nixos/configuration.nix`:

```nix
{
  imports = [
    ./hardware-configuration.nix
    ./noah-hyprland-rice.nix
  ];
}
```

Rebuild:

```bash
sudo nixos-rebuild switch
```

Then install the rice files:

```bash
./install.sh --no-packages
```

If a package is missing on stable NixOS, use `nixos-unstable` for this rice package set.

## After Install

The shared Hyprland config defaults to:

```text
monitor = ,preferred,auto,1
```

Edit `~/.config/hypr/hyprland.conf` for your real monitor names and refresh rates.
