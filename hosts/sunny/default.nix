# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, sources, lib,  ... }:

let

  hostname = "sunny";
  # must be one of the .nix files in modules/platform
  platform = "laptop";

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
      # application suite
      (self + /modules/applications/graphical-full.nix)
      # secure boot
      (self + /modules/bootsecurity/secureboot.nix)
      # application specific inclusions/configurations
      (self + /modules/applications/configs/firefox-work.nix)
      (self + /modules/applications/configs/wireguard.nix)
    ];

  networking.hostName = "${hostname}"; # Define your hostname.

  boot.initrd.systemd.enable = true;

  boot.lanzaboote = {
      configurationLimit = 8;
      measuredBoot = {
      enable = true;
      pcrs = [
        0
        4
        7
      ];
    };
  };

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
    efi.canTouchEfiVariables = true;  # Usually true for most systems
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
