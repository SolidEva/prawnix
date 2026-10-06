# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, sources, lib,  ... }:

let

  hostname = "egg";
  # must be one of the .nix files in modules/platform
  platform = "laptop";

  apple-silicon-support = (import sources.apple-silicon-support {});

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # base platform configuration
      (self + /modules/platform/${platform}.nix)
      # configure zswap as swap
      (self + /modules/swap/zswap.nix)
      # use niri
      (self + /modules/niri/${hostname}.nix)
      # use our wallpapers
      (self + /modules/wallpapers/default.nix)
      # use alacritty
      (self + /modules/alacritty/${platform}.nix)
      (self + /modules/applications/graphical-full.nix)
      (self + /modules/applications/configs/wireguard.nix)

      (apple-silicon-support + /apple-silicon-support)
    ];

  networking.hostName = "${hostname}"; # Define your hostname.

  boot.initrd.systemd.enable = true;

  swapDevices = lib.mkForce [ {
    device = "/var/lib/swapfile";
    size = 8*1024; # 8GiB, in MiB
  } ];

  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = false; # apple silicon specialty
  };

  hardware.asahi.enable = true;
  networking.networkmanageer.wifi.backend = "iwd";

  

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
