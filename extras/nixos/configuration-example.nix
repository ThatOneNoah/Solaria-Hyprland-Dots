{ config, pkgs, lib, ... }:

let
  optionalPkg = name:
    lib.optional (lib.hasAttr name pkgs) (lib.getAttr name pkgs);

  optionalPkgs = names:
    lib.concatMap optionalPkg names;

  optionalKdePkg = name:
    lib.optional
      (lib.hasAttr "kdePackages" pkgs && lib.hasAttr name pkgs.kdePackages)
      (lib.getAttr name pkgs.kdePackages);

  optionalQt5Pkg = name:
    lib.optional
      (lib.hasAttr "libsForQt5" pkgs && lib.hasAttr name pkgs.libsForQt5)
      (lib.getAttr name pkgs.libsForQt5);
in
{
  programs.hyprland.enable = true;
  security.polkit.enable = true;
  services.dbus.enable = true;
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.power-profiles-daemon.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = optionalPkgs [
      "xdg-desktop-portal-hyprland"
    ];
  };

  environment.systemPackages =
    optionalPkgs [
      "hyprlock"
      "hypridle"
      "swww"
      "hyprpaper"
      "waybar"
      "rofi-wayland"
      "rofi"
      "mako"
      "wlogout"
      "ghostty"
      "kitty"
      "foot"
      "fish"
      "networkmanagerapplet"
      "blueman"
      "bluez"
      "power-profiles-daemon"
      "pavucontrol"
      "playerctl"
      "brightnessctl"
      "grim"
      "slurp"
      "wl-clipboard"
      "libnotify"
      "jq"
      "curl"
      "imagemagick"
      "file"
      "fastfetch"
      "cava"
      "qt5ct"
      "qt6ct"
      "nwg-look"
      "flatpak"
      "noto-fonts"
      "jetbrains-mono"
      "inter"
      "quickshell"
      "eww"
      "matugen"
      "nwg-bar"
      "nwg-dock-hyprland"
      "gpu-screen-recorder"
      "pywalfox-native"
    ]
    ++ optionalKdePkg "dolphin"
    ++ optionalKdePkg "kate"
    ++ optionalQt5Pkg "qtstyleplugin-kvantum";
}

