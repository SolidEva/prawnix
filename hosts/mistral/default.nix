# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ self, sources, pkgs, pkgs-mistral-firmware, ... }:

let

  hostname = "mistral";
  # must be one of the .nix files in modules/platform
  platform = "laptop";

  secrets = import "${sources.prawnix-secrets-mistral}/default.nix";

  # something in the linux-firmware bump in nixpkgs commit
  # "dd9633711ad69a86ba7771a3af9b21f453a2c707"
  # started causing system freezes due to nvme timeouts
  # these freezes usually show up by ~30 minutes after boot.
  # sometimes faster though
  # they look like:
  # Oct 03 15:29:12 mistral kernel: nvme nvme0: 16/0/0 default/read/poll queues
  # Oct 03 15:29:12 mistral kernel: nvme nvme0: Shutdown timeout set to 10 seconds
  # Oct 03 15:29:12 mistral kernel: nvme nvme0: I/O 26 QID 2 timeout, reset controller
  # Oct 03 15:28:42 mistral kernel: nvme nvme0: Abort status: 0x0
  # Oct 03 15:28:42 mistral kernel: nvme nvme0: I/O 26 (I/O Cmd) QID 2 timeout, aborting

  # pinning to the older linux-firmware package for now
  pkgs-mistral-firmware = import sources.nixpkgs-mistral-firmware {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.unfree = true;
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # base platform configuration
      (self + /modules/platform/${platform}.nix)
      # rb specific fixes
      (self + /modules/rb-fixes/default.nix)
      # disable the nvidia card
      "${sources.nixos-hardware}/common/gpu/nvidia/disable.nix"
      # use remote builders
      # "${sources.prawnix-secrets-mistral}/remote-builders.nix"
      # configure zswap as swap
      (self + /modules/swap/zswap.nix)
      # use sway
      (self + /modules/niri/${hostname}.nix)
      # use our wallpapers
      (self + /modules/wallpapers/default.nix)
      # use alacritty
      (self + /modules/alacritty/${platform}.nix)
      # application suite
      (self + /modules/applications/graphical-full.nix)
      # application specific inclusions/configurations
      (self + /modules/applications/configs/firefox-work.nix)
      (self + /modules/applications/configs/zoom.nix)
      (self + /modules/applications/configs/wireguard.nix)
    ];

  # Pin to an older version of linux-firmware
  # some firmware change between versions 20250917 and 20251011 causes nvme issues
  nixpkgs.overlays = [
    (self: super: {
      linux-firmware = pkgs-mistral-firmware.linux-firmware;
    })
  ];

  # eval and build arm64
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  environment.systemPackages = with pkgs; [
    android-studio
    bambu-studio
  ];

  networking.hostName = "${hostname}"; # Define your hostname.

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
